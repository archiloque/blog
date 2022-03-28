import sys

last_depth = None
deeper = 0

for line in open(sys.argv[1], 'r'):
    current_depth = int(line)
    if last_depth is not None:
        if current_depth > last_depth:
            deeper += 1
    last_depth = current_depth
print(deeper)
