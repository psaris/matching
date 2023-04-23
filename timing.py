import timeit
import numpy as np
from matching.games import StableMarriage
from matching.games import StableRoommates
from matching.games import HospitalResident
import json
import sys
import pykx as kx  # requires QHOME to be set properly

# used to reload matching library if something changes
kx.q._register("matching")
np.random.seed(0)


# stable marriage (SM) problem

sys.setrecursionlimit(10000) # overcome call to copy.deepcopy
n = 200
sd = {s: np.argsort(np.random.random(size=n)) for s in range(n)}
rd = {r: np.argsort(np.random.random(size=n)) for r in range(n)}


def smq(sd, rd):
    d = kx.q.matching.sm(sd, rd)[0].pd()
    return d


def smp(sd, rd):
    g = StableMarriage.create_from_dictionaries(sd, rd)
    d = {k.name: v.name for (k, v) in g.solve().items()}
    return d

assert smq(sd, rd) == smp(sd, rd)  # assert equality
timeit.timeit('smq(sd,rd)', number=1, globals=globals())
timeit.timeit('smp(sd,rd)', number=1, globals=globals())



# stable roommates (SR) problem

def srq(rd):
    d = kx.q.matching.sr(rd)[0].pd()
    return d


def srp(rd):
    g = StableRoommates.create_from_dictionary(rd)
    d = {k.name: v.name for (k, v) in g.solve().items()}
    return d


rd = {k: [x for x in v if x != k] for (k, v) in rd.items()}
assert srq(rd) == srp(rd)     # assert equality
timeit.timeit('srq(rd)', number=1, globals=globals())
timeit.timeit('srp(rd)', number=1, globals=globals())



# hospital residents (HR) problem

with (open('capacities.json', 'r') as c,
      open('hospitals.json', 'r') as h,
      open('residents.json', 'r') as r):
    R = json.load(r)
    H = json.load(h)
    C = json.load(c)


#  convert lists to arrays for kdb+
R = {k: np.array(v) for (k, v) in R.items()}
H = {k: np.array(v) for (k, v) in H.items()}


def hrp(R, H, C, opt: str):
    g = HospitalResident.create_from_dictionaries(R, H, C)
    d = {k.name: [x.name for x in v]
         for (k, v) in g.solve(optimal=opt).items()}
    return d


def hrq(R, H, C, opt: str):
    if opt == 'hospital':
        d = kx.q.matching.hrh(C, H, R)[0].pd()
    elif opt == 'resident':
        d = kx.q.matching.hrr(C, H, R)[0].pd()
    else:
        d = None
    return d


assert hrq(R, H, C, opt='hospital') == hrp(R, H, C, opt='hospital')
# TODO q and python are not sorted the same
#assert hrq(R, H, C, opt='resident') == hrp(R, H, C, opt='resident')
timeit.timeit('hrq(R,H,C,opt="hospital")', number=10, globals=globals())
timeit.timeit('hrp(R,H,C,opt="hospital")', number=10, globals=globals())

timeit.timeit('hrq(R,H,C,opt="resident")', number=10, globals=globals())
timeit.timeit('hrp(R,H,C,opt="resident")', number=10, globals=globals())
