import pykx as kx
import timeit
import random
import numpy as np
from matching.games import StableMarriage
from matching.games import StableRoommates
from matching.games import HospitalResident
import json
import os
os.environ["QHOME"] = "/Users/nick/miniconda3/lib/python3.9/site-packages/pykx/lib"

# used to reload matching library if something changes
kx.q._register("matching")


# stable marriage problem

n = 20                        # prevent exceeding python recursion limit
sd = {i: random.sample(range(1, n+1), n) for i in range(1, n+1)}
rd = {i: random.sample(range(1, n+1), n) for i in range(1, n+1)}


def smpq(sd, rd):
    d = kx.q.matching.smp(sd, rd)[0].pd()
    return d


def smpp(sd, rd):
    g = StableMarriage.create_from_dictionaries(sd, rd)
    d = {k.name: v.name for (k, v) in g.solve().items()}
    return d


assert smpq(sd, rd) == smpp(sd, rd)  # assert equality
timeit.timeit('smpq(sd,rd)', number=100, globals=globals())
timeit.timeit('smpp(sd,rd)', number=100, globals=globals())



# stable roommates problem

def srpq(rd):
    d = kx.q.matching.srp(rd)[0].pd()
    return d


def srpp(rd):
    g = StableRoommates.create_from_dictionary(rd)
    d = {k.name: v.name for (k, v) in g.solve().items()}
    return d


rd = {k: [x for x in v if x != k] for (k, v) in rd.items()}
assert srpq(rd) == srpp(rd)     # assert equality
timeit.timeit('srpq(rd)', number=1, globals=globals())
timeit.timeit('srpp(rd)', number=1, globals=globals())



# hospital residents problem

with (open('capacities.json', 'r') as c,
      open('hospitals.json', 'r') as h,
      open('residents.json', 'r') as r):
    R = json.load(r)
    H = json.load(h)
    C = json.load(c)


#  convert lists to arrays for kdb+
R = {k: np.array(v) for (k, v) in R.items()}
H = {k: np.array(v) for (k, v) in H.items()}


def hrpp(R, H, C, opt: str):
    g = HospitalResident.create_from_dictionaries(R, H, C)
    d = {k.name: [x.name for x in v]
         for (k, v) in g.solve(optimal=opt).items()}
    return d


def hrpq(R, H, C, opt: str):
    if opt == 'hospital':
        d = kx.q.matching.hrph(C, H, R)[0].pd()
    elif opt == 'resident':
        d = kx.q.matching.hrpr(C, H, R)[0].pd()
    else:
        d = None
    return d


assert hrpq(R, H, C, opt='hospital') == hrpp(R, H, C, opt='hospital')
assert hrpq(R, H, C, opt='resident') == hrpp(R, H, C, opt='resident')
timeit.timeit('hrpq(R,H,C,opt="hospital")', number=10, globals=globals())
timeit.timeit('hrpp(R,H,C,opt="hospital")', number=10, globals=globals())

timeit.timeit('hrpq(R,H,C,opt="resident")', number=10, globals=globals())
timeit.timeit('hrpp(R,H,C,opt="resident")', number=10, globals=globals())
