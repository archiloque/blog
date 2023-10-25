import sys
import re

instructions = open(sys.argv[1]).readlines()

current_value = instructions[0].strip()
possible_elements = set(current_value)

rule_regex = re.compile(r"^(?P<from>[A-Z]{2}) -> (?P<to>[A-Z])$")

rules = {}

for rule in instructions[2:(len(instructions))]:
    match = rule_regex.search(rule)
    from_rule = match.group(`'from`')
    to_rule = match.group(`'to`')
    rules[from_rule] = to_rule
    possible_elements.update(from_rule)
    possible_elements.update(to_rule)

print(current_value)

for step in range(0,2):
    next_value = []
    for char_index in range(0, len(current_value) - 1):
        current_pair = `'`'.join(current_value[char_index:char_index+2])
        next_value.append(current_value[char_index])
        applied_rule = rules[current_pair]
        if applied_rule is not None:
            next_value.append(applied_rule)
    next_value.append(current_value[-1])
    current_value = next_value
    print(current_value)

cardinalities = list(map(lambda e: current_value.count(e), possible_elements))
print(max(cardinalities) - min(cardinalities))
