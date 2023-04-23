from matching.games import StableMarriage
from util import f2d


def smp(s: str, r: str) -> StableMarriage:
    return StableMarriage.create_from_dictionaries(f2d(s), f2d(r))


g = smp('suitor.txt', 'reviewer.txt')
s = g.solve()
print(list(s.values()))
