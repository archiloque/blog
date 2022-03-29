import sys


def is_low_point(height_map: [[int]], map_height: int, map_width: int, line_index: int, column_index: int) -> bool:
    point_value = height_map[line_index][column_index]
    if (line_index > 0) and (height_map[line_index - 1][column_index] <= point_value):
        return False
    elif (column_index > 0) and (height_map[line_index][column_index - 1] <= point_value):
        return False
    if (line_index < (map_height - 1)) and (height_map[line_index + 1][column_index] <= point_value):
        return False
    elif (column_index < (map_width - 1)) and (height_map[line_index][column_index + 1] <= point_value):
        return False
    else:
        return True


def check_point(height_map, current_point_value, target_point, visited_points, next_points_to_visit) -> None:
    target_value = height_map[target_point[0]][target_point[1]]
    if (target_point not in visited_points) \
            and (target_point not in next_points_to_visit) \
            and (target_value < 9) \
            and (target_value > current_point_value):
        next_points_to_visit.append(target_point)


def calculate_bassin(height_map: [[int]], map_height: int, map_width: int, line_index: int, column_index: int) -> int:
    visited_points = []
    past_points_to_visit = [(line_index, column_index)]
    while len(past_points_to_visit) != 0:
        next_points_to_visit = []
        for current_point in past_points_to_visit:
            current_point_line_index, current_point_column_index = current_point
            current_point_value = height_map[current_point_line_index][current_point_column_index]
            if current_point_line_index > 0:
                target_point = (current_point_line_index - 1, current_point_column_index)
                check_point(height_map, current_point_value, target_point, visited_points, next_points_to_visit)
            if current_point_column_index > 0:
                target_point = (current_point_line_index, current_point_column_index - 1)
                check_point(height_map, current_point_value, target_point, visited_points, next_points_to_visit)
            if current_point_line_index < (map_height - 1):
                target_point = (current_point_line_index + 1, current_point_column_index)
                check_point(height_map, current_point_value, target_point, visited_points, next_points_to_visit)
            if current_point_column_index < (map_width - 1):
                target_point = (current_point_line_index, current_point_column_index + 1)
                check_point(height_map, current_point_value, target_point, visited_points, next_points_to_visit)
            visited_points.append(current_point)

        past_points_to_visit = next_points_to_visit
    return len(visited_points)


height_map = list(map(lambda line: list(map(int, line.strip())), open(sys.argv[1]).readlines()))

map_height = len(height_map)
map_width = len(height_map[0])

bassins = []

for line_index in range(0, map_height):
    for column_index in range(0, map_width):
        if is_low_point(height_map, map_height, map_width, line_index, column_index):
            bassins.append(calculate_bassin(height_map, map_height, map_width, line_index, column_index))

bassins.sort()
print(bassins[-1] * bassins[-2] * bassins[-3])
