from matching.games import StudentAllocation
import pandas as pd
# import timeit

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
# assert(len(raw_projects) == len(projects))

# supervisors
supervisors = raw_supervisors.copy()
supervisors = supervisors.dropna()
supervisors = supervisors[supervisors["capacity"] > 0]
# assert(len(supervisors) == len(raw_supervisors))

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

sorted_students = [s for s in sorted_students if s in student_to_preferences]

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

# assert((set(), {'L1'}) == (unranked_supervisors, unranked_projects))

for supervisor in unranked_supervisors:
    if supervisor in supervisor_to_capacity:
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


def solve(opt: str):
    g = StudentAllocation.create_from_dictionaries(
        student_to_preferences,
        supervisor_to_preferences,
        project_to_supervisor,
        project_to_capacity,
        supervisor_to_capacity,
    )
    s = g.solve(optimal=opt)
    return s

import json

sps = solve(opt="student")      # student python solution
with open('student_solution.json','w') as f:
    d = {str(k):[int(str(x)) for x in v] for (k,v) in sps.items()}
    json.dump(d,f,indent=1)

sus = solve(opt="supervisor")   # supervisor python solution
with open('supervisor_solution.json','w') as f:
    d = {str(k):[int(str(x)) for x in v] for (k,v) in sus.items()}
    json.dump(d,f,indent=1)

