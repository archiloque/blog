import strutils
import os
import tables
import re

const NORTH = 'N'
const SOUTH = 'S'
const EAST = 'E'
const WEST = 'W'
const RIGHT = 'R'
const LEFT = 'L'
const FORWARD = 'F'

const TURN_RIGHT = {
  NORTH: WEST,
  WEST: SOUTH,
  SOUTH: EAST,
  EAST: NORTH
}.toTable

const TURN_LEFT = {
  NORTH: EAST,
  WEST: NORTH,
  SOUTH: WEST,
  EAST: SOUTH
}.toTable

let input: seq[string] = readFile(paramStr(1)).splitLines()

let instructionRegex = re(r"^([" & NORTH & SOUTH & EAST & WEST & LEFT & RIGHT &
    FORWARD & r"])(\d+)$")

var facing: char = EAST
var linePosition: int = 0
var columnPosition: int = 0

for line in input:
  var instructionMatch: array[2, string]
  if line.match(instructionRegex, instructionMatch):
    var action: char = instructionMatch[0][0]
    var value: int = instructionMatch[1].parseInt()
    case action:
      of NORTH:
        linePosition += value
      of SOUTH:
        linePosition -= value
      of EAST:
        columnPosition += value
      of WEST:
        columnPosition -= value
      of LEFT:
        if value.mod(90) != 0:
          raise newException(ValueError, "Unknown angle [" & $value & "]")
        for i in countup(1, value.div(90)):
          facing = TURN_LEFT[facing]
      of RIGHT:
        if value.mod(90) != 0:
          raise newException(ValueError, "Unknown angle [" & $value & "]")
        for i in countup(1, value.div(90)):
          facing = TURN_RIGHT[facing]
      of FORWARD:
        case facing:
          of NORTH:
            linePosition -= value
          of SOUTH:
            linePosition += value
          of EAST:
            columnPosition += value
          of WEST:
            columnPosition -= value
          else:
            raise newException(ValueError, "Unknown action [" & facing & "]")
      else:
        raise newException(ValueError, "Unknown action [" & action & "]")
  else:
    raise newException(ValueError, "Can't parse [" & line & "]")
echo(linePosition.abs() + columnPosition.abs())
