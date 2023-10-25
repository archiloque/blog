import sys
import re

lines = open(sys.argv[1]).readlines()

line_regex = re.compile(r"^(?P<x1>\d+),(?P<y1>\d+) -> (?P<x2>\d+),(?P<y2>\d+)$")

checked_values = {}


def process_value(x: int, y: int, checked_values):
    key = f"{x}-{y}"
    if key in checked_values:
        checked_values[key] += 1
    else:
        checked_values[key] = 1


for line in lines:
    match = line_regex.search(line)
    x1 = int(match.group(`'x1`'))
    y1 = int(match.group(`'y1`'))
    x2 = int(match.group(`'x2`'))
    y2 = int(match.group(`'y2`'))
    if x1 == x2:
        r = range(y1, y2 + 1) if y2 > y1 else range(y2, y1 + 1)
        for y in r:
            process_value(x1, y, checked_values)
    elif y1 == y2:
        r = range(x1, x2 + 1) if x2 > x1 else range(x2, x1 + 1)
        for x in r:
            process_value(x, y1, checked_values)

print(len(list(filter(lambda x: x > 1, checked_values.values()))))
