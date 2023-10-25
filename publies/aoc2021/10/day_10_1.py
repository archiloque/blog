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
                return char
        elif char == "\n":
            return None
        else:
            raise Exception(char)
    return None


symbol_to_value = {
    `')`': 3,
    `']`': 57,
    `'}`': 1197,
    `'>`': 25137,
}

result = 0
for line in open(sys.argv[1]).readlines():
    line_result = process_line(line)
    if line_result is not None:
        result += symbol_to_value[line_result]
print(result)
