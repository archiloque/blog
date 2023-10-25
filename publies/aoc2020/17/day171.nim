import sets
import strutils
import os
import sequtils

type
  Cube = ref object
    elements: HashSet[string]
    minX: int
    maxX: int
    minY: int
    maxY: int
    minZ: int
    maxZ: int

proc toCoordinates(x: int, y: int, z: int): string =
  $x & " " & $y & " " & $z

proc contains(elements: HashSet[string], x: int, y: int, z: int): bool =
  elements.contains(toCoordinates(x, y, z))

proc cubeElementAsChar(c: bool): char =
  if c:
    `'#`'
  else:
    `'.`'

proc countAround(elements: HashSet[string], x: int, y: int, z: int): int =
  var count = 0
  for calcX in countup(x - 1, x + 1):
    for calcY in countup(y - 1, y + 1):
      for calcZ in countup(z - 1, z + 1):
        if ((x != calcX) or (y != calcY) or (z != calcZ)) and contains(elements,
            calcX, calcY, calcZ):
          count += 1
  count

proc printCube(cube: Cube) =
  for z in countup(cube.minZ, cube.maxZ):
    echo("z=", z)
    for x in countup(cube.minX, cube.maxX):
      let line = toSeq(cube.minY .. cube.maxY).map(proc(
          y: int): char = cubeElementAsChar(cube.elements.contains(x, y,
              z))).join("")
      echo(line)
    echo("")

var setup: seq[string] = readFile(paramStr(1)).splitLines()

var initElements = initHashSet[string]()

for lineIndex, line in setup:
  for columnIndex, columnValue in line:
    if columnValue == `'#`':
      initElements.incl(toCoordinates(lineIndex, columnIndex, 0))
echo(initElements)

var currentCube = Cube(elements: initElements, minX: 0, maxX: setup.len() - 1,
    minY: 0, maxY: setup[0].len() - 1, minZ: 0, maxZ: 0)

printCube(currentCube)

for roundIndex in countup(0, 5):
  var newElements = initHashSet[string]()
  for calcX in countup(currentCube.minX - 1, currentCube.maxX + 1):
    for calcY in countup(currentCube.minY - 1, currentCube.maxY + 1):
      for calcZ in countup(currentCube.minZ - 1, currentCube.maxZ + 1):
        let cubesAround = countAround(currentCube.elements, calcX, calcY, calcZ)
        if contains(currentCube.elements, calcX, calcY, calcZ):
          if (cubesAround == 2) or (cubesAround == 3):
            newElements.incl(toCoordinates(calcX, calcY, calcZ))
        else:
          if (cubesAround == 3):
            newElements.incl(toCoordinates(calcX, calcY, calcZ))
  currentCube = Cube(elements: newElements, minX: currentCube.minX - 1,
    maxX: currentCube.maxX + 1,
    minY: currentCube.minY - 1, maxY: currentCube.maxY + 1,
    minZ: currentCube.minZ - 1, maxZ: currentCube.maxZ + 1)
  printCube(currentCube)
echo(currentCube.elements.len())
