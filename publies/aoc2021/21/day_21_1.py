import sys

input = list(map(lambda l: int(l.strip().split(`' `')[-1]), open(sys.argv[1]).readlines()))

player_positions = [input[0], input[1]]
player_scores = [0, 0]


def next_move(player_index: int, move_size: int):
    player_positions[player_index] += move_size
    while player_positions[player_index] > 10:
        player_positions[player_index] -= 10
    player_scores[player_index] += player_positions[player_index]


dice_number = 0
while True:
    move_size = ((dice_number + 1) * 3) + 3
    next_move(0, move_size)
    dice_number += 3
    if player_scores[0] >= 1000:
        print(player_scores[1] * dice_number)
        exit(0)
    move_size = ((dice_number + 1) * 3) + 3
    next_move(1, move_size)
    dice_number += 3
    if player_scores[1] >= 1000:
        print(player_scores[0] * dice_number)
        exit(0)
    print(f"{player_positions} {player_scores} {dice_number}")
