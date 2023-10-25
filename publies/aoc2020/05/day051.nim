import strutils
import sequtils
import os
import math

proc calculateSeatId(boardingPass: string): int =
  var value: int = 0
  for index, c in boardingPass:
    case c:
      of `'F`', `'L`':
        discard
      of `'B`', `'R`':
        value += 2 ^ (9 - index)
      else:
        raise newException(ValueError, "Unknown value [" & c & "]")
  return value

let input: seq[string] = readFile(paramStr(1)).splitLines()
var max = input.map(calculateSeatId).max
echo(max)
