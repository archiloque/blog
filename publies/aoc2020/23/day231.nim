import strutils
import os
import sequtils

var cups: seq[int] = readFile(paramStr(1)).map(proc(s: char): int = (
    $s).parseInt())
var currentCupIndex = 0

for currentTurn in countup(1, 100):
  var pickedUpCups: seq[int] = @[]
  for pickedUpCupsIndex in countup(1, 3):
    if currentCupIndex == cups.len() - 1:
      pickedUpCups.add(cups[0])
      cups.delete(0)
      currentCupIndex -= 1
    else:
      pickedUpCups.add(cups[currentCupIndex + 1])
      cups.delete(currentCupIndex + 1)
  var destinationCupLabel = cups[currentCupIndex] - 1
  while not cups.contains(destinationCupLabel):
    destinationCupLabel -= 1
    if destinationCupLabel < 0:
      destinationCupLabel = cups.max()
  let destinationIndex = cups.find(destinationCupLabel)
  cups.insert(pickedUpCups, destinationIndex + 1)
  if destinationIndex < currentCupIndex:
    currentCupIndex += pickedUpCups.len()
  currentCupIndex += 1
  if currentCupIndex >= cups.len():
    currentCupIndex -= cups.len()

let index1 = cups.find(1)
var finalLabels = ""
if index1 != cups.len() - 1:
  finalLabels &= cups[index1 + 1 .. cups.len() - 1].map(proc(s: int): string = (
      $s)).join("")
if index1 != 0:
  finalLabels &= cups[0 .. index1 - 1].map(proc(s: int): string = ($s)).join("")
echo(finalLabels)
