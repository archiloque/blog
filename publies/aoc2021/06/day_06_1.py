import sys

line = open(sys.argv[1]).readlines()[0]

current_fishes = [0] * 9
for starting_fish in line.split(`',`'):
    starting_fish_int = int(starting_fish)
    current_fishes[starting_fish_int] += 1

print(current_fishes)

for day in range(0, 80):
    next_fishes = [0] * 9
    for index in range(1, 9):
        next_fishes[index - 1] = current_fishes[index]
    next_fishes[6] += current_fishes[0]
    next_fishes[8] = current_fishes[0]
    current_fishes = next_fishes
    print(f"{day + 1} {current_fishes} {sum(current_fishes)}")
