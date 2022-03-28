import sys

positions_list = list(map(int, open(sys.argv[1]).readlines()[0].split(',')))
print(positions_list)
min_pos = min(positions_list)
max_pos = max(positions_list)
delta = max_pos - min_pos + 1
initial_positions = [0] * delta
for position in positions_list:
    initial_positions[position - min_pos] += 1


def calculate_fuel(positions: [int], target_index: int) -> int:
    result = 0
    for index in range(0, len(positions)):
        result += abs(target_index - index) * positions[index]
    return result


print(initial_positions)

print(min(map(lambda i: calculate_fuel(initial_positions, i), range(0, len(initial_positions)))))
