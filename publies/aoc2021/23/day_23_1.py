import sys
from enum import Enum, auto
from typing import NewType, Tuple

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
Move = Tuple[
    ItemType, ItemType, ItemType, ItemType, ItemType, ItemType, ItemType, ItemType, ItemType, ItemType, ItemType, ItemType, ItemType, ItemType]


def slice_move(current_move: Move, min_position: Position, max_position: Position) -> Move:
    current_move = list(current_move)
    return tuple(
        current_move[:min_position] +
        current_move[max_position:(max_position + 1)] +
        current_move[(min_position + 1):max_position] +
        current_move[min_position:(min_position + 1)] +
        current_move[max_position + 1:]
    )


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

puzzle = open(sys.argv[1]).readlines()

initial_position: Move = tuple(
    list(
        map(
            lambda c: CHAR_TO_ITEM_TYPE[c],
            [
                puzzle[1][1],
                puzzle[1][2],
                puzzle[1][4],
                puzzle[1][6],
                puzzle[1][8],
                puzzle[1][10],
                puzzle[1][11],

                puzzle[2][3],
                puzzle[3][3],
                puzzle[2][5],
                puzzle[3][5],
                puzzle[2][7],
                puzzle[3][7],
                puzzle[2][9],
                puzzle[3][9]]
        )
    )

)
TARGET_POSITION: Move = tuple(
    ([ITEM_EMPTY] * 7) + ([ITEM_AMBER] * 2) + ([ITEM_BRONZE] * 2) + ([ITEM_COPPER] * 2) + ([ITEM_DESERT] * 2))

print(initial_position)

known_moves: dict[Move, int] = dict()
known_moves[initial_position] = 0

min_energy = 0
max_energy = 0
min_solution_energy: int | None = None

moves_to_explores: dict[int, list[Move]] = dict()
moves_to_explores[0] = [initial_position]


class CanMoveInStatus(Enum):
    TOP_ROOM = auto()
    BOTTOM_ROOM = auto()
    NO = auto()


TOP_ROOM_INDEX: dict[ItemType, Position] = {
    ITEM_AMBER: Position(7), ITEM_BRONZE: Position(9), ITEM_COPPER: Position(11), ITEM_DESERT: Position(13)
}
BOTTOM_ROOM_INDEX: dict[ItemType, Position] = {
    ITEM_AMBER: Position(8), ITEM_BRONZE: Position(10), ITEM_COPPER: Position(12), ITEM_DESERT: Position(14)
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


def can_move_in(current_move: Move, item_type: ItemType) -> CanMoveInStatus:
    top_content = current_move[TOP_ROOM_INDEX[item_type]]
    bottom_content = current_move[BOTTOM_ROOM_INDEX[item_type]]
    if top_content != ITEM_EMPTY:
        return CanMoveInStatus.NO
    elif bottom_content == ITEM_EMPTY:
        return CanMoveInStatus.BOTTOM_ROOM
    elif bottom_content == item_type:
        return CanMoveInStatus.TOP_ROOM
    else:
        return CanMoveInStatus.NO


NUMBER_OF_MOVE_TO_TOP_ROOM: dict[ItemType, list[Position]] = {
    ITEM_AMBER: [Position(3), Position(2), Position(2), Position(4), Position(6), Position(8), Position(9)],
    ITEM_BRONZE: [Position(5), Position(4), Position(2), Position(2), Position(4), Position(6), Position(7)],
    ITEM_COPPER: [Position(7), Position(6), Position(4), Position(2), Position(2), Position(4), Position(5)],
    ITEM_DESERT: [Position(9), Position(9), Position(6), Position(4), Position(2), Position(2), Position(3)],
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
    if (move not in known_moves) or (known_moves[move] > energy):
        print(f"\t\t\t\t\tNew move {move} for {energy}")
        known_moves[move] = energy
        if energy in moves_to_explores:
            moves_to_explores[energy].append(move)
        else:
            moves_to_explores[energy] = [move]
    max_energy = max(max_energy, energy)


def try_to_move_in(current_move: Move, current_energy: int, item_type: ItemType):
    global min_solution_energy
    global max_energy
    move_in_status = can_move_in(current_move, item_type)
    if move_in_status != CanMoveInStatus.NO:
        move_right_index = move_right_to_chamber(current_move, item_type)
        if move_right_index is not None:
            number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][move_right_index]
            target_index = TOP_ROOM_INDEX[item_type] if (move_in_status == CanMoveInStatus.TOP_ROOM) else \
                BOTTOM_ROOM_INDEX[item_type]

            new_move = slice_move(current_move, move_right_index, target_index)
            if move_in_status == CanMoveInStatus.BOTTOM_ROOM:
                number_of_moves += 1
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
            number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][move_left_index]
            target_index = TOP_ROOM_INDEX[item_type] if (move_in_status == CanMoveInStatus.TOP_ROOM) else \
                BOTTOM_ROOM_INDEX[item_type]

            new_move = slice_move(current_move, move_left_index, target_index)
            if move_in_status == CanMoveInStatus.BOTTOM_ROOM:
                number_of_moves += 1
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
    top_room_item_type = current_move[top_room_index]
    bottom_room_index = BOTTOM_ROOM_INDEX[item_type]
    bottom_room_item_type = current_move[bottom_room_index]
    if ((top_room_item_type != ITEM_EMPTY) and (top_room_item_type != item_type)) or \
            ((top_room_item_type == item_type) and (bottom_room_item_type != item_type)):
        print(f"\t\tCan move from top room")
        target_index: Position
        for target_index in range(MOVE_RIGHT_TO_CHAMBER_MAX_POSITION[item_type], -1, -1):
            if current_move[target_index] != ITEM_EMPTY:
                break
            print(f"\t\t\t\tCan move left to {target_index}")
            number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][target_index]
            new_energy = current_energy + (number_of_moves * ITEM_TYPE_TO_ENERGY[top_room_item_type])
            new_move = slice_move(current_move, target_index, top_room_index)
            process_move(new_move, new_energy)
        for target_index in range(MOVE_LEFT_TO_CHAMBER_MIN_POSITION[item_type], 7):
            if current_move[target_index] != ITEM_EMPTY:
                break
            print(f"\t\t\t\tCan move right to {target_index}")
            number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][target_index]
            new_energy = current_energy + (number_of_moves * ITEM_TYPE_TO_ENERGY[top_room_item_type])
            new_move = slice_move(current_move, target_index, top_room_index)
            process_move(new_move, new_energy)
    else:
        if (top_room_item_type == ITEM_EMPTY) and (bottom_room_item_type != ITEM_EMPTY) and (
                bottom_room_item_type != item_type):
            print(f"\t\tCan move from bottom room")
            target_index: Position
            for target_index in range(MOVE_RIGHT_TO_CHAMBER_MAX_POSITION[item_type], -1, -1):
                if current_move[target_index] != ITEM_EMPTY:
                    break
                print(f"\t\t\t\tCan move left to {target_index}")
                number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][target_index] + 1
                new_energy = current_energy + (number_of_moves * ITEM_TYPE_TO_ENERGY[bottom_room_item_type])
                new_move = slice_move(current_move, target_index, bottom_room_index)
                process_move(new_move, new_energy)
            for target_index in range(MOVE_LEFT_TO_CHAMBER_MIN_POSITION[item_type], 7):
                if current_move[target_index] != ITEM_EMPTY:
                    break
                print(f"\t\t\t\tCan move right to {target_index}")
                number_of_moves = NUMBER_OF_MOVE_TO_TOP_ROOM[item_type][target_index] + 1
                new_energy = current_energy + (number_of_moves * ITEM_TYPE_TO_ENERGY[bottom_room_item_type])
                new_move = slice_move(current_move, target_index, bottom_room_index)
                process_move(new_move, new_energy)


def next_move() -> None:
    global min_energy
    global max_energy
    global moves_to_explores
    global min_solution_energy
    for current_energy in range(min_energy, max_energy + 1):
        #print(f"Trying {current_energy}")
        min_energy = current_energy
        if (min_solution_energy is not None) and (current_energy >= min_solution_energy):
            print(f"Solution found: {min_solution_energy}")
            exit(0)
        if current_energy in moves_to_explores:
            moves_with_right_cost = moves_to_explores[current_energy]
            for current_move in moves_with_right_cost:
                print(f"Process {current_move} for {current_energy}")
                for item_type in [ITEM_AMBER, ITEM_BRONZE, ITEM_COPPER, ITEM_DESERT]:
                    print(f"\tTrying to move in {item_type}")
                    try_to_move_in(current_move, current_energy, item_type)
                for item_type in [ITEM_AMBER, ITEM_BRONZE, ITEM_COPPER, ITEM_DESERT]:
                    print(f"\tTrying to move out from {item_type}")
                    try_to_move_out(current_move, current_energy, item_type)
            moves_to_explores.pop(current_energy)


while True:
    next_move()
