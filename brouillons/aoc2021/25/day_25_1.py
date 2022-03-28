import copy
import sys

puzzle = list(map(lambda l: list(l.strip()), open(sys.argv[1]).readlines()))
puzzle_width = len(puzzle[0])
puzzle_height = len(puzzle)

step_index = 0
while True:
    step_index += 1
    number_of_moves = 0
    new_puzzle = copy.deepcopy(puzzle)
    for line in range(0, puzzle_height):
        for column in range(0, puzzle_width - 1):
            current_cell_content = puzzle[line][column]
            target_cell_content = puzzle[line][column + 1]
            if (current_cell_content == '>') and (target_cell_content == '.'):
                new_puzzle[line][column] = '.'
                new_puzzle[line][column + 1] = '>'
                number_of_moves += 1
        
        current_cell_content = puzzle[line][puzzle_width - 1]
        target_cell_content = puzzle[line][0]
        if (current_cell_content == '>') and (target_cell_content == '.'):
            new_puzzle[line][puzzle_width - 1] = '.'
            new_puzzle[line][0] = '>'
            number_of_moves += 1

    puzzle = new_puzzle
    new_puzzle = copy.deepcopy(puzzle)

    for line in range(0, puzzle_height - 1):
        for column in range(0, puzzle_width):
            current_cell_content = puzzle[line][column]
            target_cell_content = puzzle[line + 1][column]
            if (current_cell_content == 'v') and (target_cell_content == '.'):
                new_puzzle[line][column] = '.'
                new_puzzle[line + 1][column] = 'v'
                number_of_moves += 1
                
    for column in range(0, puzzle_width):
        current_cell_content = puzzle[puzzle_height - 1][column]
        target_cell_content = puzzle[0][column]
        if (current_cell_content == 'v') and (target_cell_content == '.'):
            new_puzzle[puzzle_height - 1][column] = '.'
            new_puzzle[0][column] = 'v'
            number_of_moves += 1

    if number_of_moves == 0:
        print(step_index)
        exit(0)
    puzzle = new_puzzle
