import sys

last_depth = None
deeper = 0

lines = list(map(int, open(sys.argv[1]).readlines()))
for line_index in range(2, len(lines)):
    current_depth = lines[line_index - 2] + lines[line_index - 1] + lines[line_index]
    if last_depth is not None:
        if current_depth > last_depth:
            deeper += 1
    last_depth = current_depth
print(deeper)
