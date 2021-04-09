import strutils
import os
import sequtils
import tables
import sets

var input: seq[string] = readFile(paramStr(1)).splitLines()

proc decreaseMovement(path: TableRef[string, int], movement: string, value: int) =
  if path[movement] == value:
    path.del(movement)
  else:
    path[movement] -= value

proc removeCircles(path: TableRef[string, int], directions: seq[string]): bool =
  if directions.all(proc(direction: string): bool = path.hasKey(direction)):
    let value: int = directions.map(proc(direction: string): int = path[
        direction]).min()
    for direction in directions:
      decreaseMovement(path, direction, value)
    true
  else:
    false

proc simplifyDirections(path: TableRef[string, int], direction1: string,
    direction2: string, equivalentDirection: string): bool =
  if path.hasKey(direction1) and path.hasKey(direction2):
    let value: int = [path[direction1], path[direction2]].min()
    decreaseMovement(path, direction1, value)
    decreaseMovement(path, direction2, value)
    if path.hasKey(equivalentDirection):
      path[equivalentDirection] += value
    else:
      path[equivalentDirection] = value
    true
  else:
    false

var pathes: HashSet[string] = initHashSet[string]()

for line in input:
  var tile = newTable[string, int]()
  var cursorIndex = 0
  while cursorIndex < line.len():
    var currentDirection: string
    if (line[cursorIndex] == 'n') or (line[cursorIndex] == 's'):
      currentDirection = line[cursorIndex .. cursorIndex + 1]
      cursorIndex += 2
    else:
      currentDirection = line[cursorIndex .. cursorIndex]
      cursorIndex += 1
    if tile.hasKeyOrPut(currentDirection, 1):
      tile[currentDirection] += 1

  var s = true
  while(s):
    s = simplifyDirections(tile, "ne", "se", "e")
    s = s or simplifyDirections(tile, "nw", "sw", "w")
    s = s or simplifyDirections(tile, "se", "ne", "e")
    s = s or simplifyDirections(tile, "sw", "nw", "w")

    s = s or simplifyDirections(tile, "se", "w", "sw")
    s = s or simplifyDirections(tile, "sw", "e", "se")
    s = s or simplifyDirections(tile, "ne", "w", "nw")
    s = s or simplifyDirections(tile, "nw", "e", "ne")

    s = s or removeCircles(tile, @["e", "w"])
    s = s or removeCircles(tile, @["se", "nw"])
    s = s or removeCircles(tile, @["ne", "sw"])
  var path = ["e", "w", "se", "sw", "ne", "nw"].map(proc(
      direction: string): string = $ tile.getOrDefault(direction, 0)).join(",")
  if pathes.contains(path):
    pathes.excl(path)
  else:
    pathes.incl(path)
echo(pathes.len())
