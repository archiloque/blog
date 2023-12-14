import re
import sys

grid = set()

instruction_regex = re.compile(
    r"^(?P<status>on|off) x=(?P<x_min>-?\d+)..(?P<x_max>-?\d+),y=(?P<y_min>-?\d+)..(?P<y_max>-?\d+),z=(?P<z_min>-?\d+)..(?P<z_max>-?\d+)$")


class Cuboid:
    def __init__(self, x_min: int, x_max: int, y_min: int, y_max: int, z_min: int, z_max: int, status: bool):
        self.x_min = x_min
        self.x_max = x_max

        self.y_min = y_min
        self.y_max = y_max

        self.z_min = z_min
        self.z_max = z_max

        self.status = status

    def intersect(self, other) -> bool:
        if not (self.x_min <= other.x_max and self.x_max >= other.x_min):
            return False
        if not (self.y_min <= other.y_max and self.y_max >= other.y_min):
            return False
        if not (self.z_min <= other.z_max and self.z_max >= other.z_min):
            return False
        return True

    def intersection(self, other):
        return Cuboid(
            max(self.x_min, other.x_min),
            min(self.x_max, other.x_max),
            max(self.y_min, other.y_min),
            min(self.y_max, other.y_max),
            max(self.z_min, other.z_min),
            min(self.z_max, other.z_max),
            not other.status)

    def volume(self) -> int:
        return (self.x_max - self.x_min + 1) * (self.y_max - self.y_min + 1) * (self.z_max - self.z_min + 1)

known_cuboids = []

for instruction in open(sys.argv[1]).readlines():
    parsed_instruction = instruction_regex.search(instruction)
    status = parsed_instruction.group('status')
    x_min = int(parsed_instruction.group('x_min'))
    x_max = int(parsed_instruction.group('x_max'))

    y_min = int(parsed_instruction.group('y_min'))
    y_max = int(parsed_instruction.group('y_max'))

    z_min = int(parsed_instruction.group('z_min'))
    z_max = int(parsed_instruction.group('z_max'))

    current_cuboid = Cuboid(x_min, x_max, y_min, y_max, z_min, z_max, status == 'on')
    current_intersections = []

    for cuboid in known_cuboids:
        if current_cuboid.intersect(cuboid):
            intersection = current_cuboid.intersection(cuboid)
            current_intersections.append(intersection)

    known_cuboids += current_intersections
    if status == 'on':
        known_cuboids.append(current_cuboid)

result = 0

for current_cuboid in known_cuboids:
    current_volume = current_cuboid.volume()
    result += current_volume * (1 if current_cuboid.status else -1)
print(result)
