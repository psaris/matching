import sys
import json
from matching.games import HospitalResident


def hrp(R: dict, H: dict, C: dict) -> HospitalResident:
    return HospitalResident.create_from_dictionaries(R, H, C)


with (open(sys.argv[1], 'r') as c,
      open(sys.argv[2], 'r') as h,
      open(sys.argv[3], 'r') as r):
    R = json.load(r)
    H = json.load(h)
    C = json.load(c)


def solve(opt: str):
    g = hrp(R, H, C)
    s = g.solve(optimal=opt)
    return s


optimal = sys.argv[4] if len(sys.argv) > 3 else "resident"

s = solve(optimal)              # solution
with open(f'{optimal}_solution.json', 'w') as f:
    d = {k.name: [x.name for x in v] for (k, v) in s.items()}
    json.dump(d, f, indent=1)
