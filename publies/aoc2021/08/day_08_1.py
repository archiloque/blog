import sys

interesting_digits = [2, 3, 4, 7]


def process_line(line: str) -> int:
    output_values = line.split(`'|`')[1].strip().split(`' `')
    return len(list(filter(lambda v: len(v) in interesting_digits, output_values)))


print(sum(map(lambda l: process_line(l), open(sys.argv[1]).readlines())))
