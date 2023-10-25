import strutils
import os
import sequtils
import algorithm
import tables

var currentLayout: seq[seq[char]] = readFile(paramStr(1)).splitLines().map(proc(
    s: string): seq[char] = toSeq(s.items))

const EMPTY_SEAT = `'L`'
const OCCUPIED_SEAT = `'#`'
const FLOOR = `'.`'

let height = currentLayout.len()
let width = currentLayout[0].len()

proc hasOccupiedSeatInDirection(layout: seq[seq[char]], lineIndex: int,
    columnIndex: int, height: int, width: int, deltaLine: int,
        deltaColum: int): bool =
  var currentLine = lineIndex
  var currentColumn = columnIndex
  while(true):
    currentLine += deltaLine
    if (currentLine < 0) or (currentLine > (height - 1)):
      return false
    currentColumn += deltaColum
    if (currentColumn < 0) or (currentColumn > (width - 1)):
      return false
    let currentTile = currentLayout[currentLine][currentColumn]
    case currentTile:
      of FLOOR:
        discard
      of EMPTY_SEAT:
        return false
      of OCCUPIED_SEAT:
        return true
      else:
        raise newException(ValueError, "Unknown tile [" & currentTile & "]")

const directions: array[0..7, array[0..1, int]] = [
  [-1, -1],
  [-1, 0],
  [-1, 1],
  [0, -1],
  [0, 1],
  [1, -1],
  [1, 0],
  [1, 1],
]

proc countOccupiedAround(layout: seq[seq[char]], lineIndex: int,
    columnIndex: int, height: int, width: int): int =
  return directions.map(proc(s: array[0..1,
      int]): bool = hasOccupiedSeatInDirection(layout, lineIndex, columnIndex,
      height, width, s[0], s[1])).count(true)

var anythingChangedInLastIteration = true
while(anythingChangedInLastIteration):
  anythingChangedInLastIteration = false
  var newLayout: seq[seq[char]] = newSeq[seq[char]](height)
  for lineIndex in countup(0, height - 1):
    var newLine: seq[char] = newSeq[char](width)
    for columnIndex in countup(0, width - 1):
      let currentTile = currentLayout[lineIndex][columnIndex]
      case currentTile:
        of FLOOR:
          newLine[columnIndex] = FLOOR
        of EMPTY_SEAT:
          let occupiedAround = countOccupiedAround(currentLayout, lineIndex,
              columnIndex, height, width)
          if (lineIndex == 0) and (columnIndex == 8):
            echo("! ", occupiedAround)
          let result = if (occupiedAround == 0): OCCUPIED_SEAT else: EMPTY_SEAT
          if result == OCCUPIED_SEAT:
            anythingChangedInLastIteration = true
          newLine[columnIndex] = result
        of OCCUPIED_SEAT:
          let occupiedAround = countOccupiedAround(currentLayout, lineIndex,
              columnIndex, height, width)
          let result = if (occupiedAround >= 5): EMPTY_SEAT else: OCCUPIED_SEAT
          if result == EMPTY_SEAT:
            anythingChangedInLastIteration = true
          newLine[columnIndex] = result
        else:
          raise newException(ValueError, "Unknown tile [" & currentTile & "]")
      newLayout[lineIndex] = newLine
  echo(newLayout.map(proc(
    s: seq[char]): string = s.join()))
  currentLayout = newLayout
let occupiedSeatCount = currentLayout.map(proc(
    s: seq[char]): int = s.count(OCCUPIED_SEAT)).foldl(a + b)
echo(occupiedSeatCount)
