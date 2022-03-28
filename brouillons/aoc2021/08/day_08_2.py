import sys

uniques_number_of_segments_to_numbers = {
    2: 1,
    3: 7,
    4: 4,
    7: 8
}


def process_line(line: str) -> int:
    splitted_lines = line.split('|')
    signal_patterns = list(
        map(lambda s: ''.join(sorted(s)), splitted_lines[0].strip().split(' ')))
    output_values = list(
        map(lambda s: ''.join(sorted(s)), splitted_lines[1].strip().split(' ')))
    values = signal_patterns + output_values

    length_to_values = {}
    for i in range(0, 8):
        length_to_values[i] = set()
    for value in values:
        length = len(value)
        length_to_values[length].add(value)

    for length in length_to_values.keys():
        length_to_values[length] = list(length_to_values[length])

    known_numbers = {}

    # 1, 4, 7, 8: only one per segment length
    for number, segments_to_numbers in uniques_number_of_segments_to_numbers.items():
        if len(length_to_values[number]) == 1:
            known_numbers[segments_to_numbers] = set(length_to_values[number][0])
            length_to_values[number].remove(length_to_values[number][0])

    # 6: 1 - 6 has one segment, 0 and 9 have two
    if 1 in known_numbers:
        for candidate in length_to_values[6]:
            candidate_set = set(candidate)
            if len(list(known_numbers[1] - candidate_set)) == 1:
                known_numbers[6] = candidate_set
                length_to_values[6].remove(candidate)

    # 9 & 0: 9 - (merging 4 and 7) has one segment, 0 has two
    if (4 in known_numbers) and (7 in known_numbers):
        four_seven = known_numbers[4] | known_numbers[7]
        for candidate in length_to_values[6]:
            candidate_set = set(candidate)
            if len(list(candidate_set - four_seven)) == 1:
                known_numbers[9] = candidate_set
                length_to_values[6].remove(candidate)
        for candidate in length_to_values[6]:
            candidate_set = set(candidate)
            if len(list(candidate_set - four_seven)) == 2:
                known_numbers[0] = candidate_set
                length_to_values[6].remove(candidate)

    # 3: 1 - 3 has zero segment, 2 and 5 have two
    if 1 in known_numbers:
        for candidate in length_to_values[5]:
            candidate_set = set(candidate)
            if len(list(known_numbers[1] - candidate_set)) == 0:
                known_numbers[3] = candidate_set
                length_to_values[5].remove(candidate)

    # 2 & 5: 5 - 6 has zero segment, 2 - 6 has one
    if 6 in known_numbers:
        for candidate in length_to_values[5]:
            candidate_set = set(candidate)
            if len(list(candidate_set - known_numbers[6])) == 0:
                known_numbers[5] = candidate_set
                length_to_values[5].remove(candidate)
        for candidate in length_to_values[5]:
            candidate_set = set(candidate)
            if len(list(candidate_set - known_numbers[6])) == 1:
                known_numbers[2] = candidate_set
                length_to_values[5].remove(candidate)

    known_numbers_reverse = dict((''.join(sorted(v)), k) for k, v in known_numbers.items())

    result = known_numbers_reverse[output_values[0]] * 1000 + \
             known_numbers_reverse[output_values[1]] * 100 + \
             known_numbers_reverse[output_values[2]] * 10 + \
             known_numbers_reverse[output_values[3]]
    return result


print(sum(map(lambda l: process_line(l), open(sys.argv[1]).readlines())))
