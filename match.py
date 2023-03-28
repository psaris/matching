from matching.games import StableMarriage
from matching.games import StableRoommates
from matching.games import HospitalResident
from matching.games import StudentAllocation

import yaml
import json
import urllib
import timeit

# import importlib
# importlib.reload(matching.games)

import pandas as pd


def f2d(f: str) -> dict:
    df = pd.read_csv(f, delimiter=' ', dtype=object, header=None)
    df.index = df.index.map(lambda x: str(1+x))
    d = df.transpose().to_dict(orient="list")
    return d


def smp(s: str, r: str) -> StableMarriage:
    return StableMarriage.create_from_dictionaries(f2d(s), f2d(r))


def srp(f: str) -> StableRoommates:
    return StableRoommates.create_from_dictionary(f2d(f))


def hrp(R: dict, H: dict, C: dict) -> StableMarriage:
    return HospitalResident.create_from_dictionaries(R, H, C)


# stable marriage

g = smp('suitor.txt', 'reviewer.txt')
s = g.solve()
print(list(s.values()))


# stable roommates

g = srp(f := 'mate.txt')
g.check_inputs()
s = g.solve()
g.check_stability()
g.check_validity()
print(list(s.values()))


# hospital resident

r = ['A', 'S', 'D', 'L', 'J']
h = ['M', 'C', 'G']
c = [2, 2, 2]

R = dict(zip(r,[['C'],['C','M'],
                ['C','M','G'],
                ['M','C','G'],
                ['C','G','M']
                ]))

H = dict(zip(h,[['D','L','S','J'],
                ['D','A','S','L','J'],
                ['D','J','L']
                ]))

C = dict( zip(h,c))

g = hrp(R, H, C)
print(g.solve(optimal = 'resident'))

g = hrp(R, H, C)

#print(g.solve(optimal = 'hospital'))

for f in ['capacities','hospitals','residents']:
    url = f"https://zenodo.org/record/3688091/files/{f}.yml"
    with urllib.request.urlopen(url) as yf, open(f+'.json','w') as jf:
        jf.write(json.dumps(yaml.full_load(yf),indent=1))

with (open('capacities.json','r') as c,
      open('hospitals.json','r') as h,
      open('residents.json','r') as r):
    R = json.load(r)
    H = json.load(h)
    C = json.load(c)


def solve(opt:str):
    g = hrp(R,H,C)
    s = g.solve(optimal=opt)
    return s

g.check_inputs()
s = g.solve(optimal='hospital')
s = g.solve(optimal='resident')
g.check_validity()
print(g.matching)
[len(v) for v in g.matching.values()]

timeit.timeit('solve("resident")', number=100,globals=globals())
timeit.timeit('solve("hospital")', number=100,globals=globals())



# student advisor

# hand-cleaning the data as demonstrated by
# https://matching.readthedocs.io/en/latest/tutorials/project_allocation/main.html
raw_students = pd.read_csv("students.csv")
raw_projects = pd.read_csv("projects.csv")
raw_supervisors = pd.read_csv("supervisors.csv")
# there are 25 columns in the data
n_choices = 25
choices = map(str, range(n_choices))

# students
students = raw_students.copy()
students = students.dropna(subset=choices, how="all").reset_index(drop=True)

# projects
projects = raw_projects.copy()
projects = projects.dropna()
projects = projects[projects["capacity"] > 0]
assert(len(raw_projects) == len(projects))

# supervisors
supervisors = raw_supervisors.copy()
supervisors = supervisors.dropna()
supervisors = supervisors[supervisors["capacity"] > 0]
assert(len(supervisors) == len(raw_supervisors))

supervisor_names = supervisors["name"].values
project_codes = projects["code"].values

# project maps
project_to_capacity, project_to_supervisor = {}, {}
for _, (project, capacity, supervisor) in projects.iterrows():
    if project in project_codes and supervisor in supervisor_names:
        project_to_supervisor[project] = supervisor
        project_to_capacity[project] = capacity

# project supervisor maps
supervisor_to_capacity = {}
for _, (supervisor, capacity) in supervisors.iterrows():
    if supervisor in project_to_supervisor.values():
        supervisor_to_capacity[supervisor] = capacity

# student preferences
student_to_preferences = {}
for _, (student, _, *prefs) in students.iterrows():
    student_preferences = []
    for project in prefs:
        if project in project_codes and project not in student_preferences:
            student_preferences.append(project)

    if student_preferences:
        student_to_preferences[student] = student_preferences

# student ranks (not performed by supervisors)
sorted_students = students.sort_values("rank", ascending=True)["name"].values

# supervisor preferences
supervisor_to_preferences = {}
for supervisor in supervisor_names:

    supervisor_preferences = []
    supervisor_projects = [
        p for p, s in project_to_supervisor.items() if s == supervisor
    ]

    for student in sorted_students:
        student_preferences = student_to_preferences[student]
        if set(student_preferences).intersection(supervisor_projects):
            supervisor_preferences.append(student)

    if supervisor_preferences:
        supervisor_to_preferences[supervisor] = supervisor_preferences

# remove unranked supervisors and projects

unranked_supervisors = set(supervisor_names).difference(
    supervisor_to_preferences.keys()
)


unranked_projects = set(project_codes).difference(
    (project for prefs in student_to_preferences.values() for project in prefs)
)

assert((set(), {'L1'}) == (unranked_supervisors, unranked_projects))

for supervisor in unranked_supervisors:
    del supervisor_to_capacity[supervisor]

for project in unranked_projects:
    del project_to_capacity[project]
    del project_to_supervisor[project]

# trim project capacities
for project, project_capacity in project_to_capacity.items():
    supervisor = project_to_supervisor[project]
    supervisor_capacity = supervisor_to_capacity[supervisor]

    if project_capacity > supervisor_capacity:
        print(
            f"{project} has a capacity of {project_capacity} but",
            f"{supervisor} has capacity {supervisor_capacity}.",
        )
        project_to_capacity[project] = supervisor_capacity

# trim supervisor capacities
for supervisor, supervisor_capacity in supervisor_to_capacity.items():

    supervisor_projects = [
        p for p, s in project_to_supervisor.items() if s == supervisor
    ]
    supervisor_project_capacities = [
        project_to_capacity[project] for project in supervisor_projects
    ]

    if supervisor_capacity > sum(supervisor_project_capacities):
        print(
            f"{supervisor} has capacity {supervisor_capacity} but their projects",
            f"{', '.join(supervisor_projects)} have a total capacity of",
            f"{sum(supervisor_project_capacities)}.",
        )
        supervisor_to_capacity[supervisor] = sum(supervisor_project_capacities)


g = StudentAllocation.create_from_dictionaries(
    student_to_preferences,
    supervisor_to_preferences,
    project_to_supervisor,
    project_to_capacity,
    supervisor_to_capacity,
)

matching = g.solve(optimal="student")
assert g.check_validity()
assert g.check_stability()
