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


height_map = list(map(lambda line: list(map(int, line.strip())),  open(sys.argv[1]).readlines()))

map_height = len(height_map)
map_width = len(height_map[0])

result = 0

for line_index in range(0, map_height):
    for column_index in range(0, map_width):
        if is_low_point(height_map, map_height, map_width, line_index, column_index):
            point_value = height_map[line_index][column_index]
            result += 1 + point_value
print(result)
