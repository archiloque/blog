import functools
import sys

input = list(map(lambda l: int(l.strip().split(' ')[-1]), open(sys.argv[1]).readlines()))

starting_positions = [input[0], input[1]]

DICES_THROWS = [3, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 9]

@functools.cache
def solve_situation(player_score_1, player_score_2, player_position_1, player_position_2):
    player_wins_1 = 0
    player_wins_2 = 0
    for player_move_1 in DICES_THROWS:
        new_player_position_1 = player_position_1 + player_move_1
        while new_player_position_1 > 10:
            new_player_position_1 -= 10
        new_player_score_1 = player_score_1 + new_player_position_1
        if new_player_score_1 >= 21:
            player_wins_1 += 1
        else:
            solved_situation = solve_situation(
                player_score_2,
                new_player_score_1,
                player_position_2,
                new_player_position_1,
            )
            player_wins_1 += solved_situation[1]
            player_wins_2 += solved_situation[0]
    return player_wins_1, player_wins_2


print(max(solve_situation(0, 0, starting_positions[0], starting_positions[1])))
