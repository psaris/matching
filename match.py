from matching.games import StableMarriage
from matching.games import StableRoommates
from matching.games import HospitalResident
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
