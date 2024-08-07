import sys

chiton_map = list(map(lambda line: list(map(int, line.strip())), open(sys.argv[1]).readlines()))
map_height = len(chiton_map)
map_width = len(chiton_map[0])

visited_positions = {(0, 0): 0}

current_positions = set()
current_positions.add((0, 0))

minimal_risk = 0

def check_position(current_risk, target_line, target_column, next_positions):
    target_position = (target_line, target_column)
    target_risk = current_risk + chiton_map[target_line][target_column]
    if target_position in visited_positions:
        if target_risk < visited_positions[target_position]:
            visited_positions[target_position] = target_risk
            next_positions.add(target_position)
    else:
        visited_positions[target_position] = target_risk
        next_positions.add(target_position)


while len(current_positions) > 0:
    next_positions = set()
    for current_position in current_positions:
        current_line, current_column = current_position
        current_risk = visited_positions[current_position]
        if current_line > 0:
            check_position(current_risk, current_line - 1, current_column, next_positions)
        if current_column > 0:
            check_position(current_risk, current_line, current_column - 1, next_positions)
        if current_line < (map_height - 1):
            check_position(current_risk, current_line + 1, current_column, next_positions)
        if current_column < (map_width - 1):
            check_position(current_risk, current_line, current_column + 1, next_positions)
    current_positions = next_positions

print(visited_positions[(map_height - 1, map_width - 1)])
