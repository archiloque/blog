import sys

number_of_lines = 0
one_bits_numbers = None

for line in open(sys.argv[1], `'r`'):
    number_of_lines += 1
    if one_bits_numbers is None:
        one_bits_numbers = [0] * (len(line) - 1)
    for i in range(len(line)):
        bit = line[i]
        if bit == `'1`':
            one_bits_numbers[i] += 1

gamma_rate = 0

gamma_rate = list(map(lambda b: `'1`' if (b > number_of_lines / 2) else `'0`', one_bits_numbers))
epsilon = list(map(lambda b: `'1`' if (b < number_of_lines / 2) else `'0`', one_bits_numbers))

print(one_bits_numbers)
gamma_rate_int = int(`'`'.join(gamma_rate), 2)
print(gamma_rate_int)
epsilon_int = int(`'`'.join(epsilon), 2)
print(epsilon_int)
print(gamma_rate_int * epsilon_int)
