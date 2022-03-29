import sys


class Board:
    def __init__(self, data: [str]):
        self.data = []
        self.checked_items = []
        for line in data:
            parsed_line = []
            for index in range(0, 5):
                value = line[index * 3:(index * 3 + 2)]
                parsed_line.append(int(value))
            self.data.append(parsed_line)
            self.checked_items.append([False] * 5)

    def draw_number(self, value: int) -> bool:
        for line_index in range(0, 5):
            line = self.data[line_index]
            try:
                column_index = line.index(value)
                self.checked_items[line_index][column_index] = True
                return True
            except ValueError:
                pass
        return False

    def win(self) -> bool:
        for index in range(0, 5):
            if self.win_line(index):
                return True
            if self.win_column(index):
                return True
        return False

    def win_line(self, line_index: int) -> bool:
        for i in range(0, 5):
            if not self.checked_items[line_index][i]:
                return False
        return True

    def win_column(self, column_index: int) -> bool:
        for i in range(0, 5):
            if not self.checked_items[i][column_index]:
                return False
        return True

    def score(self) -> int:
        result = 0
        for index_line in range(0, 5):
            for index_column in range(0, 5):
                if not self.checked_items[index_line][index_column]:
                    result += self.data[index_line][index_column]
        return result


lines = open(sys.argv[1]).readlines()

number_of_boards = int((len(lines) - 1) / 6)
current_boards = []
for board_index in range(0, number_of_boards):
    current_boards.append(Board(lines[(2 + (board_index * 6)):(7 + (board_index * 6))]))

for move in map(int, lines[0].split(',')):
    next_boards = []
    for current_board in current_boards:
        current_board.draw_number(move)
        if current_board.win():
            if len(current_boards) == 1:
                print(current_board.score() * move)
                exit(0)
        else:
            next_boards.append(current_board)
    current_boards = next_boards
