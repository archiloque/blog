import strutils
import os
import re
import math

const NORTH = `'N`'
const SOUTH = `'S`'
const EAST = `'E`'
const WEST = `'W`'
const RIGHT = `'R`'
const LEFT = `'L`'
const FORWARD = `'F`'

let input: seq[string] = readFile(paramStr(1)).splitLines()

let instructionRegex = re(r"^([" & NORTH & SOUTH & EAST & WEST & LEFT & RIGHT &
    FORWARD & r"])(\d+)$")

var waypointLine: int = 1
var waypointColumn: int = 10
var boatLine: int = 0
var boatColumn: int = 0

proc newColumn(line: int, column: int, angle: float): int =
  return column * (angle.degToRad().cos()).toInt() - line * angle.degToRad().sin().toInt()
proc newLine(line: int, column: int, angle: float): int =
  return column * (angle.degToRad().sin()).toInt() + line * angle.degToRad().cos().toInt()

for line in input:
  var instructionMatch: array[2, string]
  if line.match(instructionRegex, instructionMatch):
    var action: char = instructionMatch[0][0]
    var value: int = instructionMatch[1].parseInt()
    case action:
      of NORTH:
        waypointLine += value
      of SOUTH:
        waypointLine -= value
      of EAST:
        waypointColumn += value
      of WEST:
        waypointColumn -= value
      of LEFT:
        if value.mod(90) != 0:
          raise newException(ValueError, "Unknown angle [" & $value & "]")
        var oldWaypointLine = waypointLine
        var oldWaypointColumn = waypointColumn
        waypointColumn = newColumn(oldWaypointLine, oldWaypointColumn,
            value.toFloat())
        waypointLine = newLine(oldWaypointLine, oldWaypointColumn,
            value.toFloat())
      of RIGHT:
        if value.mod(90) != 0:
          raise newException(ValueError, "Unknown angle [" & $value & "]")
        var oldWaypointLine = waypointLine
        var oldWaypointColumn = waypointColumn
        waypointColumn = newColumn(oldWaypointLine, oldWaypointColumn, -
            value.toFloat())
        waypointLine = newLine(oldWaypointLine, oldWaypointColumn, -
            value.toFloat())
      of FORWARD:
        boatLine += waypointLine * value
        boatColumn += waypointColumn * value
      else:
        raise newException(ValueError, "Unknown action [" & action & "]")
  else:
    raise newException(ValueError, "Can`'t parse [" & line & "]")
  echo("Boat: (", boatLine, ", ", boatColumn, ") waypoint (", waypointLine,
      ", ", waypointColumn, ")")
echo(boatLine.abs() + boatColumn.abs())
