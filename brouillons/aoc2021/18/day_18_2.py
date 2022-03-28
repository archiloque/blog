import math
import sys
import json
import copy
from enum import Enum, auto

lines = list(map(lambda l: json.loads(l), open(sys.argv[1]).readlines()))


class ExplosionStatus(Enum):
    NO = auto()
    JUST_EXPLODED = auto()
    EXPLODED = auto()


def explode(values: [], level: int):
    if isinstance(values, int):
        return False, None, None
    elif (level > 4) \
            and isinstance(values, list) \
            and isinstance(values[0], int) \
            and isinstance(values[1], int):
        return ExplosionStatus.JUST_EXPLODED, values[0], values[1]
    else:
        for value_index in range(0, len(values)):
            value = values[value_index]
            status, left_value, right_value = explode(value, level + 1)
            if (status == ExplosionStatus.JUST_EXPLODED) or (status == ExplosionStatus.EXPLODED):
                if status == ExplosionStatus.JUST_EXPLODED:
                    values[value_index] = 0
                if (left_value is not None) and (value_index > 0):
                    if isinstance(values[value_index - 1], int):
                        values[value_index - 1] += left_value
                    else:
                        left_values = values[value_index - 1]
                        while not isinstance(left_values[- 1], int):
                            left_values = left_values[- 1]
                        left_values[-1] += left_value
                    left_value = None
                if (right_value is not None) and (value_index < (len(values) - 1)):
                    if isinstance(values[value_index + 1], int):
                        values[value_index + 1] += right_value
                    else:
                        right_values = values[value_index + 1]
                        while not isinstance(right_values[0], int):
                            right_values = right_values[0]
                        right_values[0] += right_value
                    right_value = None
                return ExplosionStatus.EXPLODED, left_value, right_value
    return ExplosionStatus.NO, None, None


def split(values: []) -> bool:
    for value_index in range(0, len(values)):
        value = values[value_index]
        if isinstance(value, int):
            if value >= 10:
                values[value_index] = [math.floor(value / 2), math.ceil(value / 2)]
                return True
        elif split(value):
            return True
    return False


def process(values: []):
    while True:
        status, _, _ = explode(values, 1)
        if status != ExplosionStatus.NO:
            return True
        else:
            return split(values)


def magniture(values: []):
    left_value = values[0]
    if isinstance(left_value, list):
        left_value = magniture(left_value)
    right_value = values[1]
    if isinstance(right_value, list):
        right_value = magniture(right_value)
    return (left_value * 3) + (2 * right_value)


max_magniture = 0
for line_index_1 in range(0, len(lines) - 1):
    for line_index_2 in range(line_index_1 + 1, len(lines)):
        current_values = [copy.deepcopy(lines[line_index_1]), copy.deepcopy(lines[line_index_2])]
        while process(current_values):
            pass
        current_magniture = magniture(current_values)

        current_values = [copy.deepcopy(lines[line_index_2]), copy.deepcopy(lines[line_index_1])]
        while process(current_values):
            pass
        current_magniture = magniture(current_values)
        max_magniture = max(max_magniture, current_magniture)
print(max_magniture)
