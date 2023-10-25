import sys
from heapq import heappush, heappop
from typing import NewType, List, Any

puzzle = open(sys.argv[1]).readlines()

CHAMBER_SIZE = len(puzzle) - 3

# #############
# #01.2.3.4.56#
# ###7#9#1#3###
#   #8#0#2#4#
#   #########

ItemType = NewType(`'ItemType`', int)
ITEM_AMBER = ItemType(0)
ITEM_BRONZE = ItemType(1)
ITEM_COPPER = ItemType(2)
ITEM_DESERT = ItemType(3)
ITEM_EMPTY = ItemType(4)

Position = NewType(`'Position`', int)
Move: list[ItemType] = []


def move_to_key(move: Move) -> str:
    return `'`'.join(map(str, move))


def slice_move(current_move: Move, min_position: Position, max_position: Position) -> Move:
    return current_move[:min_position] + \
           current_move[max_position:(max_position + 1)] + \
           current_move[(min_position + 1):max_position] + \
           current_move[min_position:(min_position + 1)] + \
           current_move[max_position + 1:]


ITEM_TYPE_TO_ENERGY: dict[ItemType, int] = {
    ITEM_AMBER: 1,
    ITEM_BRONZE: 10,
    ITEM_COPPER: 100,
    ITEM_DESERT: 1000
}

CHAR_TO_ITEM_TYPE: dict[str, ItemType] = {
    `'A`': ITEM_AMBER,
    `'B`': ITEM_BRONZE,
    `'C`': ITEM_COPPER,
    `'D`': ITEM_DESERT,
    `'.`': ITEM_EMPTY,
}

initial_position_string = [
    puzzle[1][1],
    puzzle[1][2],
    puzzle[1][4],
    puzzle[1][6],
    puzzle[1][8],
    puzzle[1][10],
    puzzle[1][11],
]
for t in range(0, 4):
    for c in range(0, CHAMBER_SIZE):
        initial_position_string.append(puzzle[2 + c][3 + (t * 2)])

initial_position: Move = list(
    map(
        lambda c: CHAR_TO_ITEM_TYPE[c],
        initial_position_string
    )
)
TARGET_POSITION: Move = (
                                [ITEM_EMPTY] * 7) + \
                        ([ITEM_AMBER] * CHAMBER_SIZE) + \
                        ([ITEM_BRONZE] * CHAMBER_SIZE) + \
                        ([ITEM_COPPER] * CHAMBER_SIZE) + \
                        ([ITEM_DESERT] * CHAMBER_SIZE)

print(initial_position)

known_moves: dict[Move, int] = dict()
known_moves[move_to_key(initial_position)] = 0

min_solution_energy: int | None = None

moves_to_explores: list[tuple[int, Move]] = []
heappush(moves_to_explores, (0, initial_position))

TOP_ROOM_INDEX: dict[ItemType, Position] = {
    ITEM_AMBER: Position(7),
    ITEM_BRONZE: Position(7 + CHAMBER_SIZE),
    ITEM_COPPER: Position(7 + (2 * CHAMBER_SIZE)),
    ITEM_DESERT: Position(7 + (3 * CHAMBER_SIZE))
}

MOVE_RIGHT_TO_CHAMBER_MAX_POSITION: dict[ItemType, Position] = {
    ITEM_AMBER: Position(1),
    ITEM_BRONZE: Position(2),
    ITEM_COPPER: Position(3),
    ITEM_DESERT: Position(4)
}

MOVE_LEFT_TO_CHAMBER_MIN_POSITION: dict[ItemType, Position] = {
    ITEM_AMBER: Position(2),
    ITEM_BRONZE: Position(3),
    ITEM_COPPER: Position(4),
    ITEM_DESERT: Position(5)
}


def can_move_in_chamber(current_move: Move, item_type: ItemType) -> Position | None:
    for room_index in range(CHAMBER_SIZE - 1, -1, -1):
        room_content = current_move[TOP_ROOM_INDEX[item_type] + room_index]
        if room_content == ITEM_EMPTY:
            return Position(room_index)
        elif room_content != item_type:
            return None
    return None


NUMBER_OF_MOVE_TO_TOP_ROOM: dict[ItemType, list[Position]] = {
    ITEM_AMBER: [Position(3), Position(2), Position(2), Position(4), Position(6), Position(8), Position(9)],
    ITEM_BRONZE: [Position(5), Position(4), Position(2), Position(2), Position(4), Position(6), Position(7)],
    ITEM_COPPER: [Position(7), Position(6), Position(4), Position(2), Position(2), Position(4), Position(5)],
    ITEM_DESERT: [Position(9), Position(8), Position(6), Position(4), Position(2), Position(2), Position(3)],
}


def move_right_to_chamber(current_move: Move, item_type: ItemType) -> Position | None:
    for item_index in range(MOVE_RIGHT_TO_CHAMBER_MAX_POSITION[item_type], -1, -1):
        if current_move[item_index] == item_type:
            return Position(item_index)
        elif current_move[item_index] != ITEM_EMPTY:
            return None
    return None


def move_left_to_chamber(current_move: Move, item_type: ItemType) -> Position | None:
    for item_index in range(MOVE_LEFT_TO_CHAMBER_MIN_POSITION[item_type], 7):
        if current_move[item_index] == item_type:
            return Position(item_index)
        elif current_move[item_index] != ITEM_EMPTY:
            return None
    return None


def process_move(move: Move, energy: int) -> None:
    global max_energy
    global known_moves
    global moves_to_explores
    move_key = move_to_key(move)
    if (move_key not in known_moves) or (known_moves[move_key] > energy):
        print(f"\t\t\t\t\tNew move {move} for {energy}")
        known_moves[move_key] = energy
        heappush(moves_to_explores, (energy, move))


def try_to_move_in(current_move: Move, current_energy: int, item_type: ItemType):
    global min_solution_energy
    global max_energy
    move_in_index = can_move_in_chamber(current_move, item_type)
    if move_in_index is not None:
        move_right_index = move_right_to_chamber(current_move, item_type)
        if move_right_index is not None:
            number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][move_right_index] + move_in_index
            target_index = TOP_ROOM_INDEX[item_type] + move_in_index

            new_move = slice_move(current_move, move_right_index, target_index)
            new_energy = current_energy + (number_of_moves * ITEM_TYPE_TO_ENERGY[item_type])

            if new_move == TARGET_POSITION:
                if (min_solution_energy is None) or (min_solution_energy > new_energy):
                    min_solution_energy = new_energy
                    max_energy = new_energy
                    print(f"Found better solution for {new_energy}")
            else:
                process_move(new_move, new_energy)

        move_left_index = move_left_to_chamber(current_move, item_type)
        if move_left_index is not None:
            number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][move_left_index] + move_in_index
            target_index = TOP_ROOM_INDEX[item_type] + move_in_index

            new_move = slice_move(current_move, move_left_index, target_index)
            new_energy = current_energy + (number_of_moves * ITEM_TYPE_TO_ENERGY[item_type])

            if new_move == TARGET_POSITION:
                if (min_solution_energy is None) or (min_solution_energy > new_energy):
                    min_solution_energy = new_energy
                    max_energy = new_energy
                    print(f"Found better solution for {new_energy}")
            else:
                process_move(new_move, new_energy)


def try_to_move_out(current_move: Move, current_energy: int, item_type: ItemType):
    top_room_index = TOP_ROOM_INDEX[item_type]
    lower_item_want_to_get_out = False
    for room_index in range(CHAMBER_SIZE - 1, -1, -1):
        room_content = current_move[top_room_index + room_index]
        if (room_content == item_type) and (not lower_item_want_to_get_out):
            pass
        elif room_content == ITEM_EMPTY:
            return
        else:
            lower_item_want_to_get_out = True
            can_move_out = True
            for over_room_index in range(0, room_index):
                if current_move[top_room_index + over_room_index] != ITEM_EMPTY:
                    can_move_out = False
            if can_move_out:
                print(f"\t\tCan move from room index {room_index}")

                target_index: Position
                for target_index in range(MOVE_RIGHT_TO_CHAMBER_MAX_POSITION[item_type], -1, -1):
                    if current_move[target_index] != ITEM_EMPTY:
                        break
                    print(f"\t\t\t\tCan move left to {target_index}")
                    number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][target_index] + room_index
                    new_energy = current_energy + (number_of_moves * ITEM_TYPE_TO_ENERGY[room_content])
                    new_move = slice_move(current_move, target_index, top_room_index + room_index)
                    process_move(new_move, new_energy)
                for target_index in range(MOVE_LEFT_TO_CHAMBER_MIN_POSITION[item_type], 7):
                    if current_move[target_index] != ITEM_EMPTY:
                        break
                    print(f"\t\t\t\tCan move right to {target_index}")
                    number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][target_index] + room_index
                    new_energy = current_energy + (number_of_moves * ITEM_TYPE_TO_ENERGY[room_content])
                    new_move = slice_move(current_move, target_index, top_room_index + room_index)
                    process_move(new_move, new_energy)


def next_move() -> None:
    global moves_to_explores
    global min_solution_energy
    while len(moves_to_explores) > 0:
        current_energy, current_move = heappop(moves_to_explores)
        if (min_solution_energy is not None) and (current_energy >= min_solution_energy):
            print(f"Solution found: {min_solution_energy}")
            exit(0)
        print(f"Process {current_move} for {current_energy}")
        for item_type in [ITEM_AMBER, ITEM_BRONZE, ITEM_COPPER, ITEM_DESERT]:
            print(f"\tTrying to move in chamber {item_type}")
            try_to_move_in(current_move, current_energy, item_type)
            print(f"\tTrying to move out from chamber {item_type}")
            try_to_move_out(current_move, current_energy, item_type)


while True:
    next_move()

# 43815 too high
# 43814 ?!
