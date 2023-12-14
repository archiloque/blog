import sys
import re

instructions = open(sys.argv[1]).readlines()

initial_value = instructions[0].strip()
possible_elements = set(initial_value)

rule_regex = re.compile(r"^(?P<from>[A-Z]{2}) -> (?P<to>[A-Z])$")

rules = {}

for rule in instructions[2:(len(instructions))]:
    match = rule_regex.search(rule)
    from_rule = match.group('from')
    to_rule = match.group('to')
    rules[from_rule] = to_rule
    possible_elements.update(from_rule)
    possible_elements.update(to_rule)


def insert_value(value, number, pairs):
    if value in pairs:
        pairs[value] += number
    else:
        pairs[value] = number


current_pairs = {}
current_cardinalities = {}
for char_index in range(0, len(initial_value) - 1):
    current_pair = initial_value[char_index:char_index + 2]
    insert_value(current_pair, 1, current_pairs)
    insert_value(initial_value[char_index], 1, current_cardinalities)
insert_value(initial_value[-1], 1, current_cardinalities)


def insert_value(value: str, number: int, pairs: dict) -> None:
    if value in pairs:
        pairs[value] += number
    else:
        pairs[value] = number


for step in range(0, 40):
    next_pairs = {}
    next_cardinalities = current_cardinalities.copy()
    for value, number in current_pairs.items():
        if value in rules:
            rule_target = rules[value]
            from_pair = f"{value[0]}{rule_target}"
            to_pair = f"{rule_target}{value[1]}"
            insert_value(rule_target, number, next_cardinalities)
            insert_value(from_pair, number, next_pairs)
            insert_value(to_pair, number, next_pairs)
        else:
            insert_value(value, number, next_pairs)
    current_pairs = next_pairs
    current_cardinalities = next_cardinalities

print(max(current_cardinalities.values()) - min(current_cardinalities.values()))
