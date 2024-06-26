import sys
import re

page = open(sys.argv[1]).readlines()

dots = set()

last_dot_line_index = 0
for dot_line in page:
    last_dot_line_index += 1
    if dot_line == "\n":
        break
    dot_coordinates = list(map(int, dot_line.split(',')))
    dots.add((dot_coordinates[0], dot_coordinates[1]))

fold_regex = re.compile(r"^fold along (?P<axis>[xy])=(?P<value>\d+)$")


def fold_y(fold_value: int, dots):
    result = set()
    for dot in dots:
        dot_column, dot_line = dot
        if dot_line < fold_value:
            result.add(dot)
        elif dot_line > fold_value:
            result.add((dot_column, (2 * fold_value) - dot_line))
    return result


def fold_x(fold_value: int, dots):
    result = set()
    for dot in dots:
        dot_column, dot_line = dot
        if dot_column < fold_value:
            result.add(dot)
        elif dot_column > fold_value:
            result.add(((2 * fold_value) - dot_column, dot_line))
    return result


for fold_index in range(last_dot_line_index, len(page)):
    fold_line = page[fold_index]
    match = fold_regex.search(fold_line)
    fold_axis = match.group('axis')
    fold_value = int(match.group('value'))
    match fold_axis:
        case 'x':
            dots = fold_x(fold_value, dots)
        case 'y':
            dots = fold_y(fold_value, dots)
        case _:
            raise Exception(fold_axis)

max_column = max(map(lambda dot: dot[0], dots))
max_line = max(map(lambda dot: dot[1], dots))
for line_index in range(0, max_line + 1):
    for column_index in range(0, max_column + 1):
        print('#' if (column_index, line_index) in dots else ' ', sep=' ', end='')
    print()
