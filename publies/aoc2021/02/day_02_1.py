import sys
import binascii

horizontal_position = 0
depth = 0

for line in open(sys.argv[1], `'r`'):
    splitted_line = line.split(`' `')
    value = int(splitted_line[1])
    instruction = splitted_line[0]
    match instruction:
        case `'forward`':
            horizontal_position += value
        case `'down`':
            depth += value
        case `'up`':
            depth -= value

print(horizontal_position * depth)
