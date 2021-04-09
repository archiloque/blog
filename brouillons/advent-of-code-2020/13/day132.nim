import strutils
import os

var busses: seq[array[2, int]] = @[]

let input: seq[string] = readFile(paramStr(1)).splitLines()[1].split(",")

for busIndex, busId in input:
  if busId != "x":
    busses.add([busId.parseInt(), busIndex])

var currentStepSize = busses[0][0]
var currentTime = 0
for bus in busses[1 .. ^1]:
  let busIndex = bus[0]
  let busId = bus[1]
  while (currentTime + busId).mod(busIndex) != 0:
    currentTime += currentStepSize
  currentStepSize *= busIndex
echo(currentTime)
