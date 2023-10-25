import sys

caves_map = {}

for path in open(sys.argv[1]).readlines():
    caves = path.strip().split(`'-`')
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

pathes_reaching_the_end = 0
pathes_to_visit = [[`'start`']]

while len(pathes_to_visit) != 0:
    next_pathes_to_visit = []
    for current_path in pathes_to_visit:
        for target in caves_map[current_path[-1]]:
            if target == `'end`':
                pathes_reaching_the_end += 1
            elif target.islower():
                if target not in current_path:
                    next_pathes_to_visit.append(current_path + [target])
            elif target.isupper():
                next_pathes_to_visit.append(current_path + [target])
            else:
                raise Exception(target)
    pathes_to_visit = next_pathes_to_visit

print(pathes_reaching_the_end)
