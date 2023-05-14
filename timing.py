import sys
import timeit
import json
import numpy as np
from matching.games import StableMarriage
from matching.games import StableRoommates
from matching.games import HospitalResident
from matching.games import StudentAllocation
import sa
import hr
import util
import pykx as kx  # requires QHOME to be set properly

print("loading q matching library")
kx.q._register("matching")
np.random.seed(0)


print("* stable marriage (SM) problem *")

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

print("confirming equality of solutions")
assert smq(sd, rd) == smp(sd, rd)  # assert equality
print("timing q")
print(timeit.timeit('smq(sd,rd)', number=1, globals=globals()))
print("timing python")
print(timeit.timeit('smp(sd,rd)', number=1, globals=globals()))



print("* stable roommates (SR) problem *")

def srq(rd):
    d = kx.q.matching.sr(rd)[0].pd()
    return d


def srp(rd):
    g = StableRoommates.create_from_dictionary(rd)
    d = {k.name: v.name for (k, v) in g.solve().items()}
    return d


rd = {k: [x for x in v if x != k] for (k, v) in rd.items()}
print("confirming equality of solutions")
assert srq(rd) == srp(rd)     # assert equality
print("timing q")
print(timeit.timeit('srq(rd)', number=1, globals=globals()))
print("timing python")
print(timeit.timeit('srp(rd)', number=1, globals=globals()))



print("* hospital residents (HR) problem *")

(R, H, C) = hr.load('residents.json', 'hospitals.json', 'capacities.json')

#  convert lists to arrays for kdb+
R = util.l2a(R)
H = util.l2a(H)


def hrp(R, H, C, opt: str):
    g = HospitalResident.create_from_dictionaries(R, H, C)
    d = {k.name: [x.name for x in v]
         for (k, v) in g.solve(optimal=opt).items()}
    return d


def hrq(R, H, C, opt: str):
    if opt == 'hospital':
        f = kx.q.matching.hrh
    elif opt == 'resident':
        f = kx.q.matching.hrr
    else:
        return None
    d = f(C, H, R)[0].pd()
    return d

print("hospital-optimal")
print("confirming equality of solutions")
assert hrq(R, H, C, opt='hospital') == hrp(R, H, C, opt='hospital')
print("timing q")
print(timeit.timeit('hrq(R,H,C,opt="hospital")', number=10, globals=globals()))
print("timing python")
print(timeit.timeit('hrp(R,H,C,opt="hospital")', number=10, globals=globals()))

print("resident-optimal")
print("confirming equality of solutions")
assert {k : [x for x in H[k] if x in v]  for k, v in hrq(R, H, C, opt='resident').items()} == hrp(R, H, C, opt='resident')
print("timing q")
print(timeit.timeit('hrq(R,H,C,opt="resident")', number=10, globals=globals()))
print("timing python")
print(timeit.timeit('hrp(R,H,C,opt="resident")', number=10, globals=globals()))


print("* student allocation (SA) problem *")

(S, U, PU, PC, UC) = sa.load('students.csv', 'projects.csv', 'supervisors.csv')

#  convert lists to arrays for kdb+
S = util.l2a(S)
U = util.l2a(U)


def sap(S, U, PU, PC, UC, opt: str):
    g = StudentAllocation.create_from_dictionaries(S, U, PU, PC, UC)
    d = {k.name: [x.name for x in v]
         for (k, v) in g.solve(optimal=opt).items()}
    return d


def saq(S, U, PU, PC, UC, opt: str):
    if opt == 'supervisor':
        f = kx.q.matching.sau
    elif opt == 'student':
        f = kx.q.matching.sas
    else:
        return None
    d = f(PC, UC, PU, U, S)[1].pd()
    return d

print("supervisor-optimal")
print("confirming equality of solutions")
assert saq(S, U, PU, PC, UC, opt='supervisor') == sap(S, U, PU, PC, UC, opt='supervisor')
print("timing q")
print(timeit.timeit('saq(S, U, PU, PC, UC,opt="supervisor")', number=10, globals=globals()))
print("timing python")
print(timeit.timeit('sap(S, U, PU, PC, UC,opt="supervisor")', number=10, globals=globals()))

print("student-optimal")
print("confirming equality of solutions")
assert {k : [x for x in U[PU[k]] if x in v]  for k, v in saq(S, U, PU, PC, UC, opt='student').items()} == sap(S, U, PU, PC, UC, opt='student')
print("timing q")
print(timeit.timeit('saq(S, U, PU, PC, UC,opt="student")', number=10, globals=globals()))
print("timing python")
print(timeit.timeit('sap(S, U, PU, PC, UC,opt="student")', number=10, globals=globals()))
