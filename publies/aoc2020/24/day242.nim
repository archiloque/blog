import strutils
import os
import sequtils
import sets
import hashes

type Direction = enum
  east, southeast, southwest, west, northwest, northeast

type
  Path = ref object
    elements: seq[int]
proc hash(path: Path): Hash =
  var h: Hash = 0
  h = h !& hash(path.elements)
  result = !$h
proc `==`(a, b: Path): bool =
  a.elements == b.elements

proc removeCircles(path: Path, directions: seq[Direction]): bool =
  let value: int = directions.map(proc(direction: Direction): int = path.elements[
      direction.ord]).min()
  if value > 0:
    for direction in directions:
      path.elements[direction.ord] -= value
    true
  else:
    false

proc simplifyDirections(path: Path, direction1: Direction,
    direction2: Direction, equivalentDirection: Direction): bool =
  let value: int = [path.elements[direction1.ord], path.elements[
      direction2.ord]].min()
  if value > 0:
    path.elements[direction1.ord] -= value
    path.elements[direction2.ord] -= value
    path.elements[equivalentDirection.ord] += value
    true
  else:
    false

proc simplify(path: Path) =
  var s = true
  while(s):
    s = path.simplifyDirections(Direction.northeast, Direction.southeast,
        Direction.east)
    s = s or path.simplifyDirections(Direction.northwest, Direction.southwest,
        Direction.west)
    s = s or path.simplifyDirections(Direction.southeast, Direction.northeast,
        Direction.east)
    s = s or path.simplifyDirections(Direction.southwest, Direction.northwest,
        Direction.west)

    s = s or path.simplifyDirections(Direction.southeast, Direction.west,
        Direction.southwest)
    s = s or path.simplifyDirections(Direction.southwest, Direction.east,
        Direction.southeast)
    s = s or path.simplifyDirections(Direction.northeast, Direction.west,
        Direction.northwest)
    s = s or path.simplifyDirections(Direction.northwest, Direction.east,
        Direction.northeast)

    s = s or path.removeCircles(@[Direction.east, Direction.west])
    s = s or path.removeCircles(@[Direction.southeast, Direction.northwest])
    s = s or path.removeCircles(@[Direction.northeast, Direction.southwest])

proc toDirection(s: string): Direction =
  case s:
    of "e":
      Direction.east
    of "se":
      Direction.southeast
    of "sw":
      Direction.southwest
    of "w":
      Direction.west
    of "nw":
      Direction.northwest
    of "ne":
      Direction.northeast
    else:
      raise newException(ValueError, "Unknown value [" & s & "]")

var input: seq[string] = readFile(paramStr(1)).splitLines()

var pathes: HashSet[Path] = initHashSet[Path]()

for line in input:
  var path = Path(elements: newSeq[int](Direction.high.ord + 1))
  var cursorIndex = 0
  while cursorIndex < line.len():
    var currentDirection: string
    if (line[cursorIndex] == `'n`') or (line[cursorIndex] == `'s`'):
      currentDirection = line[cursorIndex .. cursorIndex + 1]
      cursorIndex += 2
    else:
      currentDirection = line[cursorIndex .. cursorIndex]
      cursorIndex += 1
    path.elements[currentDirection.toDirection().ord] += 1
  path.simplify()

  if pathes.contains(path):
    pathes.excl(path)
  else:
    pathes.incl(path)

proc createPath(path: Path, direction: Direction): Path =
  var newPath = Path(elements: path.elements)
  newPath.elements[direction.ord] += 1
  newPath.simplify()
  newPath

proc neighbour(path: Path, direction: Direction, pathes: HashSet[Path]): bool =
  pathes.contains(createPath(path, direction))

proc neighbours(path: Path, pathes: HashSet[Path]): int =
  toSeq(Direction).filter(proc(direction: Direction): bool = neighbour(path,
      direction, pathes)).len()

for day in countup(1, 100):
  var newPathes: HashSet[Path] = initHashSet[Path]()
  var processedPathes: HashSet[Path] = initHashSet[Path]()
  for path in pathes:
    let n1 = neighbours(path, pathes)
    if (n1 == 1) or (n1 == 2):
      newPathes.incl(path)
    else:
      discard
    processedPathes.incl(path)
  for path in pathes:
    for direction in Direction:
      var newPath = createPath(path, direction)
      if not processedPathes.containsOrIncl(newPath):
        let n2 = neighbours(newPath, pathes)
        if n2 == 2:
          newPathes.incl(newPath)
  echo("Day ", day, " ", newPathes.len())
  pathes = newPathes
