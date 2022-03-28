import re

puzzle = open('input.txt').readlines()

input_index = 0

constants_values = {
    'w': 0,
    'x': 0,
    'y': 0,
    'z': 0,
}


def has_constant(variable):
    return (variable in constants_values) and (constants_values[variable] is not None)


def flush_constant(f, variable):
    if has_constant(variable):
        f.write(f"{variable} = {constants_values[variable]}  # Flush\n")
        constants_values[variable] = None


line_index = 1


def write(f, content):
    f.write(f"{content}\n")


with open('input.txt.py', 'w') as f:
    f.write('import sys\n')
    f.write('import math\n')
    f.write('\n')
    f.write('input_number = sys.argv[1]\n')
    f.write('\n')

    for line in puzzle:
        f.write(f'# {line_index}: {line.strip()}  {constants_values}\n')
        line = line.strip().split(' ')
        if len(line) == 0:
            continue
        match line[0]:
            case 'inp':
                constants_values[line[1]] = f'int(input_number[{input_index}])'
                input_index += 1
            case 'add':
                if line[2] == '0':
                    pass
                elif has_constant(line[2]):
                    if has_constant(line[1]):
                        if constants_values[line[1]] == 0:
                            constants_values[line[1]] = constants_values[line[2]]
                        else:
                            constants_values[line[1]] = f"({constants_values[line[1]]} + {constants_values[line[2]]})"
                    else:
                        write(f, f"{line[1]} = {constants_values[line[1]]} + {constants_values[line[2]]}")
                        constants_values[line[1]] = None
                elif has_constant(line[1]) and line[2].isnumeric():
                    if constants_values[line[1]] == 0:
                        if line[2].isnumeric():
                            constants_values[line[1]] = int(line[2])
                        else:
                            constants_values[line[1]] = line[2]
                    else:
                        constants_values[line[1]] = f"({constants_values[line[1]]} + {line[2]})"
                elif constants_values[line[1]] == 0:
                    constants_values[line[1]] = None
                    flush_constant(f, line[2])
                    write(f, f"{line[1]} = {line[2]}")
                    constants_values[line[1]] = None
                else:
                    flush_constant(f, line[1])
                    flush_constant(f, line[2])
                    write(f, f"{line[1]} += {line[2]}")
                    constants_values[line[1]] = None
            case 'mul':
                if has_constant(line[1]) and (constants_values[line[1]] == 0):
                    pass
                elif has_constant(line[2]) and (constants_values[line[2]] == 1):
                    pass
                elif line[2] == '0':
                    constants_values[line[1]] = 0
                elif has_constant(line[1]) and isinstance(constants_values[line[1]], int) and has_constant(line[2]) and isinstance(constants_values[line[2]], int):
                    constants_values[line[1]] = constants_values[line[1]] * constants_values[line[2]]
                elif has_constant(line[1]):
                    flush_constant(f, line[2])
                    write(f, f"{line[1]} = {constants_values[line[1]]} * {line[2]}")
                    constants_values[line[1]] = None
                else:
                    flush_constant(f, line[1])
                    flush_constant(f, line[2])
                    write(f, f"{line[1]} *= {line[2]}")
            case 'div':
                if line[2] != '1':
                    flush_constant(f, line[1])
                    flush_constant(f, line[2])
                    if line[2] != '1':
                        write(f, f"{line[1]} = math.ceil({line[1]} / {line[2]})")
            case 'mod':
                if line[2] == '1':
                    pass
                elif has_constant(line[1]):
                    if isinstance(constants_values[line[1]], int) and line[2].isnumeric():
                        constants_values[line[1]] = int(constants_values[line[1]]) % int(line[2])
                    else:
                        write(f, f"{line[1]} = {constants_values[line[1]]} % {line[2]}")
                        constants_values[line[1]] = None
                else:
                    flush_constant(f, line[1])
                    flush_constant(f, line[2])
                    write(f, f"{line[1]} = {line[1]} % {line[2]}")
            case 'eql':
                if has_constant(line[1]):
                    if has_constant(line[2]):
                        if (re.compile(r"^int\(input_number\[(\d+)\]\)$").match(constants_values[line[2]]) is not None) \
                                and isinstance(constants_values[line[1]], int) \
                                and (constants_values[line[1]] > 10):
                            constants_values[line[1]] = 0
                        else:
                            write(f,
                                  f"{line[1]} = 1 if ({constants_values[line[1]]} == {constants_values[line[2]]}) else 0")
                            constants_values[line[1]] = None
                    else:
                        if line[2].isnumeric() and (constants_values[line[1]] == int(line[2])):
                            constants_values[line[1]] = 1
                        else:
                            write(f, f"{line[1]} = 1 if ({constants_values[line[1]]} == {line[2]}) else 0")
                            constants_values[line[1]] = None
                else:
                    if has_constant(line[2]):
                        write(f, f"{line[1]} = 1 if ({line[1]} == {constants_values[line[2]]}) else 0")
                    else:
                        write(f, f"{line[1]} = 1 if ({line[1]} == {line[2]}) else 0")
                    constants_values[line[1]] = None
            case _:
                raise Exception(line)
        line_index += 1
    f.write('\n')
    f.write('print(z)\n')
