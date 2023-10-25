import sys

matching_symbols = {
    `')`': `'(`',
    `']`': `'[`',
    `'}`': `'{`',
    `'>`': `'<`',
}

opening_symbols = list(matching_symbols.values())
closing_symbols = list(matching_symbols.keys())


def pop_valid(stack, char):
    if stack[-1] == char:
        stack.pop()
        return True
    else:
        return False


def process_line(line: str):
    stack = []
    for char in line:
        if char in opening_symbols:
            stack.append(char)
        elif char in closing_symbols:
            if not pop_valid(stack, matching_symbols[char]):
                return None
        elif char == "\n":
            return stack
        else:
            raise Exception(char)
    return stack


symbol_to_value = {
    `'(`': 1,
    `'[`': 2,
    `'{`': 3,
    `'<`': 4,
}

scores = []
for line in open(sys.argv[1]).readlines():
    line_result = process_line(line)
    if line_result is not None:
        line_total = 0
        for char in reversed(line_result):
            line_total = (line_total * 5) + symbol_to_value[char]
        scores.append(line_total)

scores.sort()
print(scores[int(len(scores) / 2)])
