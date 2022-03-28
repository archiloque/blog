import sys

input = open(sys.argv[1]).readlines()

algorithm = list(map(lambda c: False if (c == '#') else True, input[0].strip()))

data = dict()

initial_points = set()
initial_columns = len(input[2].strip())
initial_lines = len(input) - 2
for c in range(0, initial_columns):
    for l in range(0, initial_lines):
        data[(0, l, c)] = True if (input[2 + l][c] == '#') else False


def calculate_point(generation: int, line: int, column: int):
    if not (generation, line, column) in data:
        if generation == 0:
            return False
        else:
            output_pixel_value = 0
            for line_index in [line - 1, line, line + 1]:
                for column_index in [column - 1, column, column + 1]:
                    output_pixel_value *= 2
                    if calculate_point(generation - 1, line_index, column_index):
                        output_pixel_value += 1
            result = False if algorithm[output_pixel_value] else True
            data[(generation, line, column)] = result
            return result
    else:
        return data[(generation, line, column)]


generations = 2

result = 0
for l in range (-generations, initial_lines + generations + 1):
    for c in range (-generations, initial_columns + generations + 1):
        if calculate_point(generations, l, c):
            result += 1
print(result)
