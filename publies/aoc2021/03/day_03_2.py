import sys

lines = open(sys.argv[1]).readlines()


def finder(current_lines: [str], current_bit_index: int, comparator) -> str:
    one_values = sum(map(lambda line: 1 if line[current_bit_index] == '1' else 0, current_lines))
    value_to_find = '1' if comparator(one_values, (len(current_lines) / 2)) else '0'
    new_lines = list(filter(lambda line: line[current_bit_index] == value_to_find, current_lines))
    if len(new_lines) == 1:
        return new_lines[0]
    else:
        return finder(new_lines, current_bit_index + 1, comparator)


oxygen = finder(lines, 0, lambda x, y: x >= y)
print(oxygen)
oxygen_int = int(''.join(oxygen), 2)
co2 = finder(lines, 0, lambda x, y: x < y)
print(co2)
co2_int = int(''.join(co2), 2)
print(oxygen_int * co2_int)
