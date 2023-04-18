import json
import urllib.request
import yaml
from matching.games import HospitalResident


def hrp(R: dict, H: dict, C: dict) -> HospitalResident:
    return HospitalResident.create_from_dictionaries(R, H, C)


r = ['A', 'S', 'D', 'L', 'J']
h = ['M', 'C', 'G']
c = [2, 2, 2]


R = dict(zip(r, [['C'], ['C', 'M'],
                 ['C', 'M', 'G'],
                 ['M', 'C', 'G'],
                 ['C', 'G', 'M']
                 ]))

H = dict(zip(h, [['D', 'L', 'S', 'J'],
                 ['D', 'A', 'S', 'L', 'J'],
                 ['D', 'J', 'L']
                 ]))

C = dict(zip(h, c))

g = hrp(R, H, C)
hs = {k.name:[x.name for x in v] for (k,v) in  g.solve(optimal='resident').items()}

g = hrp(R, H, C)
rs = {k.name:[x.name for x in v] for (k,v) in g.solve(optimal='hospital').items()}
assert(hs == rs)

for f in ['capacities', 'hospitals', 'residents']:
    url = f"https://zenodo.org/record/3688091/files/{f}.yml"
    with urllib.request.urlopen(url) as yf, open(f+'.json', 'w') as jf:
        jf.write(json.dumps(yaml.full_load(yf), indent=1))

with (open('capacities.json', 'r') as c,
      open('hospitals.json', 'r') as h,
      open('residents.json', 'r') as r):
    R = json.load(r)
    H = json.load(h)
    C = json.load(c)

def solve(opt: str):
    g = hrp(R, H, C)
    s = g.solve(optimal=opt)
    return s


hps = solve('hospital')         # hospital python solution
with open('hospital_solution.json','w') as f:
    d = {k.name:[x.name for x in v] for (k,v) in hps.items()}
    json.dump(d,f,indent=1)

rps = solve('resident')         # resident python solution
with open('resident_solution.json','w') as f:
    d = {k.name:[x.name for x in v] for (k,v) in rps.items()}
    json.dump(d,f,indent=1)
