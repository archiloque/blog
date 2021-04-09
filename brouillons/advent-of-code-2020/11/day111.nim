import strutils
import os
import sequtils
import algorithm
import tables

var currentLayout: seq[seq[char]] = readFile(paramStr(1)).splitLines().map(proc(
    s: string): seq[char] = toSeq(s.items))

const EMPTY_SEAT = 'L'
const OCCUPIED_SEAT = '#'
const FLOOR = '.'

let height = currentLayout.len()
let width = currentLayout[0].len()

proc countOccupiedAround(layout: seq[seq[char]], lineIndex: int,
    columnIndex: int, height: int, width: int): int =
  result = 0
  for l in countup([0, lineIndex - 1].max(), [lineIndex + 1, height - 1].min()):
    for c in countup([0, columnIndex - 1].max(), [columnIndex + 1, width -
        1].min()):
      if ((l != lineIndex) or (c != columnIndex)) and (layout[l][c] ==
          OCCUPIED_SEAT):
        result += 1

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
          let result = if (occupiedAround == 0): OCCUPIED_SEAT else: EMPTY_SEAT
          if result == OCCUPIED_SEAT:
            anythingChangedInLastIteration = true
          newLine[columnIndex] = result
        of OCCUPIED_SEAT:
          let occupiedAround = countOccupiedAround(currentLayout, lineIndex,
              columnIndex, height, width)
          let result = if (occupiedAround >= 4): EMPTY_SEAT else: OCCUPIED_SEAT
          if result == EMPTY_SEAT:
            anythingChangedInLastIteration = true
          newLine[columnIndex] = result
        else:
          raise newException(ValueError, "Unknown tile [" & currentTile & "]")
      newLayout[lineIndex] = newLine
  currentLayout = newLayout
let occupiedSeatCount = currentLayout.map(proc(
    s: seq[char]): int = s.count(OCCUPIED_SEAT)).foldl(a + b)
echo(occupiedSeatCount)
