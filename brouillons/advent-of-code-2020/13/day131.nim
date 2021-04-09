import strutils
import os
import sequtils

let input: seq[string] = readFile(paramStr(1)).splitLines()

let initialTimeStamp = input[0].parseInt()
let busses = input[1].split(",").filter(proc(s: string): bool = s !=
    "x").map(proc(s: string): int = s.parseInt())
var currentTimeStamp = initialTimeStamp
while(true):
  for bus in busses:
    if currentTimeStamp.mod(bus) == 0:
      let waitTime = currentTimeStamp - initialTimeStamp
      echo("Timestamp: ", currentTimeStamp, " bus ", bus, " wait time ",
          waitTime, " result ", (bus * waitTime))
      quit()
  currentTimeStamp += 1
