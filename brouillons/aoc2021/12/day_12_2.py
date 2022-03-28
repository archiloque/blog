import sys

caves_map = {}

for path in open(sys.argv[1]).readlines():
    caves = path.strip().split('-')
    from_cave = caves[0]
    to_cave = caves[1]
    if from_cave in caves_map:
        caves_map[from_cave].append(to_cave)
    else:
        caves_map[from_cave] = [to_cave]
    if to_cave in caves_map:
        caves_map[to_cave].append(from_cave)
    else:
        caves_map[to_cave] = [from_cave]

class Path:
    def __init__(self, path: [str], small_cave_double_visit: str|None):
        self.path = path
        self.small_cave_double_visit = small_cave_double_visit


pathes_reaching_the_end = 0
pathes_to_visit = [Path(['start'], None)]

while len(pathes_to_visit) != 0:
    next_pathes_to_visit = []
    for current_path in pathes_to_visit:
        for target in caves_map[current_path.path[-1]]:
            if target == 'end':
                pathes_reaching_the_end += 1
            elif target == 'start':
                pass
            elif target.islower():
                if target not in current_path.path:
                    next_pathes_to_visit.append(Path(current_path.path + [target], current_path.small_cave_double_visit))
                elif current_path.small_cave_double_visit is not None:
                    pass
                elif current_path.path.count(target) == 1:
                    next_pathes_to_visit.append(Path(current_path.path + [target], target))
            elif target.isupper():
                next_pathes_to_visit.append(Path(current_path.path + [target], current_path.small_cave_double_visit))
            else:
                raise Exception(target)
    pathes_to_visit = next_pathes_to_visit

print(pathes_reaching_the_end)
