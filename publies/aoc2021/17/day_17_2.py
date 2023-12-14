import re
import sys
from enum import Enum, auto

input = open(sys.argv[1]).readlines()[0].strip()

line_regex = re.compile(r"^target area: x=(?P<x_min>-?\d+)..(?P<x_max>-?\d+), y=(?P<y_min>-?\d+)..(?P<y_max>-?\d+)$")
match = line_regex.search(input)

x_min = int(match.group('x_min'))
x_max = int(match.group('x_max'))
y_min = int(match.group('y_min'))
y_max = int(match.group('y_max'))


class Status(Enum):
    IN_FLY = auto()
    IN_TARGET_AREA = auto()
    LOST = auto()


def calculate_trajectory(launch_x: int, launch_y: int):
    current_x_velocity = launch_x
    current_y_velocity = launch_y
    current_x_position = 0
    current_y_position = 0
    while True:
        status = check_position(current_x_position, current_y_position)
        if status != Status.IN_FLY:
            return status
        current_x_position += current_x_velocity
        current_y_position += current_y_velocity
        if current_x_velocity > 0:
            current_x_velocity -= 1
        elif current_x_velocity < 0:
            current_x_velocity += 1
        current_y_velocity -= 1

def check_position(x: int, y: int) -> Status:
    if y < y_min:
        return Status.LOST
    elif y > y_max:
        return Status.IN_FLY
    elif x_min <= x <= x_max:
        return Status.IN_TARGET_AREA
    else:
        return Status.IN_FLY

total = 0
for x in range(1, x_max + 1):
    for y in range(-1000, 1000):
        current_status = calculate_trajectory(x, y)
        if current_status == Status.IN_TARGET_AREA:
            total += 1

print(total)
