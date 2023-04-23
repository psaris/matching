from matching.games import StableRoommates
from util import f2d


def srp(f: str) -> StableRoommates:
    return StableRoommates.create_from_dictionary(f2d(f))


g = srp(f := 'mate.txt')
g.check_inputs()
s = g.solve()
g.check_stability()
g.check_validity()
print(list(s.values()))
