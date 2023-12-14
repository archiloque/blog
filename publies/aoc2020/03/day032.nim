import strutils
import os

let input: seq[string] = readFile(paramStr(1)).splitLines()
let boardWidth = input[0].len()
let boardHeight = input.len()

type Slope = tuple
  slopeLine, slopeColumn: int

const slopeLine = 1
const slopeColumn = 3

const slopes: array[5, Slope] = [
  (slopeLine: 1, slopeColumn: 1),
  (slopeLine: 1, slopeColumn: 3),
  (slopeLine: 1, slopeColumn: 5),
  (slopeLine: 1, slopeColumn: 7),
  (slopeLine: 2, slopeColumn: 1),
]

var totalTreesNumber = 1
for slope in slopes:
  echo("Slope ", slope)
  var treesNumberCurrentSlope = 0
  var currentLine = 0
  var currentColumn = 0
  while(currentLine < (boardHeight - 1)):
    currentLine += slope.slopeLine
    currentColumn = (currentColumn + slope.slopeColumn).mod(boardWidth)
    let currentPositionContent = input[currentLine][currentColumn]
    echo("(", currentLine, ",", currentColumn, ") ", currentPositionContent)
    if currentPositionContent == '#':
      treesNumberCurrentSlope += 1
  totalTreesNumber *= treesNumberCurrentSlope

echo(totalTreesNumber)
