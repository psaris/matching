import sys
import json
from matching.games import HospitalResident


def hrp(R: dict, H: dict, C: dict) -> HospitalResident:
    return HospitalResident.create_from_dictionaries(R, H, C)

def load(rfile: str, hfile: str, cfile: str):
    with (open(rfile, 'r') as r,
          open(hfile, 'r') as h,
          open(cfile, 'r') as c):
        R = json.load(r)
        H = json.load(h)
        C = json.load(c)
        return (R, H, C)

def solve(rfile:str, hfile:str, cfile:str, opt: str):
    (R, H, C) = load(rfile, hfile, cfile)
    g = hrp(R, H, C)
    s = g.solve(optimal=opt)
    return s


if __name__ == '__main__':
    s = solve(*sys.argv[1:])    # solution
    with open(f'{sys.argv[4]}_solution.json', 'w') as f:
        d = {k.name: [x.name for x in v] for (k, v) in s.items()}
        json.dump(d, f, indent=1)
