import sys

octopus_map = list(map(lambda line: list(map(int, line.strip())), open(sys.argv[1]).readlines()))
map_height = len(octopus_map)
map_width = len(octopus_map[0])

total_flashes = 0


def process_flashed(octopus_map: [[int]], flashed_line: int, flashed_column: int, new_flashes_to_process) -> None:
    current_value = octopus_map[flashed_line][flashed_column]
    octopus_map[flashed_line][flashed_column] += 1
    if current_value == 9:
        new_flashes_to_process.append((flashed_line, flashed_column))


def process_flash(octopus_map: [[int]], flash_line: int, flash_column: int, map_height: int, map_width: int,
                  new_flashes_to_process) -> None:
    north_available = flash_line > 0
    south_available = flash_line < (map_height - 1)
    west_available = flash_column > 0
    east_available = flash_column < (map_width - 1)
    if north_available:
        process_flashed(octopus_map, flash_line - 1, flash_column, new_flashes_to_process)
    if south_available:
        process_flashed(octopus_map, flash_line + 1, flash_column, new_flashes_to_process)
    if west_available:
        process_flashed(octopus_map, flash_line, flash_column - 1, new_flashes_to_process)
    if east_available:
        process_flashed(octopus_map, flash_line, flash_column + 1, new_flashes_to_process)

    if north_available and west_available:
        process_flashed(octopus_map, flash_line - 1, flash_column - 1, new_flashes_to_process)
    if north_available and east_available:
        process_flashed(octopus_map, flash_line - 1, flash_column + 1, new_flashes_to_process)
    if south_available and west_available:
        process_flashed(octopus_map, flash_line + 1, flash_column - 1, new_flashes_to_process)
    if south_available and east_available:
        process_flashed(octopus_map, flash_line + 1, flash_column + 1, new_flashes_to_process)


def process_step(octopus_map: [[int]], map_height: int, map_width: int) -> int:
    flashes_to_process = []
    for line_index in range(0, map_height):
        for column_index in range(0, map_width):
            octopus_map[line_index][column_index] += 1
            if octopus_map[line_index][column_index] == 10:
                flashes_to_process.append((line_index, column_index))

    while len(flashes_to_process) > 0:
        new_flashes_to_process = []
        for flash_to_process in flashes_to_process:
            process_flash(octopus_map, flash_to_process[0], flash_to_process[1], map_height, map_width,
                          new_flashes_to_process)
        flashes_to_process = new_flashes_to_process

    flashes_number = 0
    for line_index in range(0, map_height):
        for column_index in range(0, map_width):
            if octopus_map[line_index][column_index] > 9:
                flashes_number += 1
                octopus_map[line_index][column_index] = 0
    return flashes_number == (map_height * map_width)


current_step = 1
while True:
    if process_step(octopus_map, map_height, map_width):
        print(current_step)
        exit(0)
    current_step+= 1
