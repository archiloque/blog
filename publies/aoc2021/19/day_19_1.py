import re
import sys


class Scanner:
    def __init__(self, index):
        self.index = index
        self.beacons = []
        self.distances = []

    def compute_distances(self):
        permutations = self.beacons_permutations()
        for permutation_index in range(0, len(permutations)):
            permutation_value = permutations[permutation_index]
            for index_1 in range(0, len(self.beacons)):
                starting_beacon = permutation_value[index_1]
                calculated_values = set()
                for index_2 in range(0, len(self.beacons)):
                    if index_1 != index_2:
                        target_beacon = permutation_value[index_2]
                        calculated_values.add(
                            (
                                target_beacon[0] - starting_beacon[0],
                                target_beacon[1] - starting_beacon[1],
                                target_beacon[2] - starting_beacon[2]
                            )
                        )
                self.distances.append((starting_beacon, permutation_index, calculated_values))

    def __repr__(self) -> str:
        return f"{self.index} {self.beacons}"

    def beacons_permutations(self) -> [[tuple]]:
        if self.index == 0:
            self.beacons.sort()
            return [self.beacons]
        result = []
        for i in range(0, 24):
            result.append([])
        for beacon in self.beacons:
            x, y, z = beacon
            values = [
                (x, y, z),
                (z, y, -x),
                (-x, y, -z),
                (-z, y, x),
                (-x, -y, z),
                (-z, -y, -x),
                (x, -y, -z),
                (z, -y, x),
                (x, -z, y),
                (y, -z, -x),
                (-x, -z, -y),
                (-y, -z, x),
                (x, z, -y),
                (-y, z, -x),
                (-x, z, y),
                (y, z, x),
                (z, x, y),
                (y, x, -z),
                (-z, x, -y),
                (-y, x, z),
                (-z, -x, y),
                (y, -x, z),
                (z, -x, -y),
                (-y, -x, -z)
            ]
            for i in range(0, 24):
                result[i].append(values[i])
        for i in range(0, 24):
            result[i].sort()
        return result


scanners = []

scanner_regex = re.compile(r"^--- scanner (?P<scanner_id>\d+) ---$")
beacon_regex = re.compile(r"^(?P<x>-?\d+),(?P<y>-?\d+),(?P<z>-?\d+)$")

for line in open(sys.argv[1]).readlines():
    line = line.strip()
    scanner_match = scanner_regex.search(line)
    if scanner_match:
        scanners.append(Scanner(int(scanner_match.group(`'scanner_id`'))))
    else:
        beacon_match = beacon_regex.search(line)
        if beacon_match:
            scanners[-1].beacons.append(
                (int(beacon_match.group(`'x`')), int(beacon_match.group(`'y`')), int(beacon_match.group(`'z`')))
            )
for scanner in scanners:
    scanner.compute_distances()


def check_pair(scanner_0, target_permutation_index_0, scanner_1):
    for distance_0 in scanner_0.distances:
        starting_beacon_0, permutation_index_0, calculated_values_0 = distance_0
        if target_permutation_index_0 == permutation_index_0:
            for distance_1 in scanner_1.distances:
                starting_beacon_1, permutation_index_1, calculated_values_1 = distance_1
                if len(calculated_values_0.intersection(calculated_values_1)) >= 11:
                    return distance_0, distance_1
    return None


def search_match(scanners, found_scanners, beacons):
    for found_scanner in found_scanners:
        for searched_scanner_index in range(0, len(scanners)):
            searched_scanner = scanners[searched_scanner_index]
            check_pair_result = check_pair(found_scanner[1], found_scanner[2], searched_scanner)
            if check_pair_result is not None:
                distance_0, distance_1 = check_pair_result
                origin = (
                             distance_0[0][0] - distance_1[0][0] + found_scanner[0][0],
                             distance_0[0][1] - distance_1[0][1] + found_scanner[0][1],
                             distance_0[0][2] - distance_1[0][2] + found_scanner[0][2],
                         )
                beacons.add((distance_1[0][0] + origin[0],distance_1[0][1] + origin[1], distance_1[0][2] + origin[2]))
                for beacon in distance_1[2]:
                    beacons.add((beacon[0] + distance_1[0][0] + origin[0], beacon[1] + distance_1[0][1] + origin[1], beacon[2] + distance_1[0][2] + origin[2]))
                found_scanners.append(
                    (
                        origin,
                        searched_scanner,
                        distance_1[1])
                )
                scanners.pop(searched_scanner_index)
                return True
    return False


scanner_0 = scanners.pop(0)
found_scanners = [((0, 0, 0), scanner_0, 0)]
beacons = set(scanner_0.beacons)
while search_match(scanners, found_scanners, beacons):
    pass

print(len(beacons))
