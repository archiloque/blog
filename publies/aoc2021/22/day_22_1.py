import re
import sys

grid = set()

instruction_regex = re.compile(
    r"^(?P<status>on|off) x=(?P<x_min>-?\d+)..(?P<x_max>-?\d+),y=(?P<y_min>-?\d+)..(?P<y_max>-?\d+),z=(?P<z_min>-?\d+)..(?P<z_max>-?\d+)$")
for instruction in open(sys.argv[1]).readlines():
    parsed_instruction = instruction_regex.search(instruction)
    status = parsed_instruction.group(`'status`')
    x_min = int(parsed_instruction.group(`'x_min`'))
    x_max = int(parsed_instruction.group(`'x_max`'))

    y_min = int(parsed_instruction.group(`'y_min`'))
    y_max = int(parsed_instruction.group(`'y_max`'))

    z_min = int(parsed_instruction.group(`'z_min`'))
    z_max = int(parsed_instruction.group(`'z_max`'))

    for x in range(-50, 51):
        if x_min <= x <= x_max:
            for y in range(-50, 51):
                if y_min <= y <= y_max:
                    for z in range(-50, 51):
                        if z_min <= z <= z_max:
                            if status == `'on`':
                                grid.add((x, y, z))
                            else:
                                if (x, y, z) in grid:
                                    grid.remove((x, y, z))

print(len(grid))
