import strutils
import os
import sequtils
import algorithm
import tables

var input: seq[int] = readFile(paramStr(1)).splitLines().map(parseInt)
input.sort(system.cmp[int])

var pathes: Table[int, int] = initTable[int, int]()

pathes[input[ ^ -1]] = 1
for currentAdapterIndex in countdown(input.len() - 2, 0):
  let currentAdapterValue = input[currentAdapterIndex]
  var pathesToCurrentAdapter = 0
  for possibleTargetValue in countup(currentAdapterValue + 1,
      currentAdapterValue + 3):
    if pathes.hasKey(possibleTargetValue):
      pathesToCurrentAdapter += pathes[possibleTargetValue]
  pathes[currentAdapterValue] = pathesToCurrentAdapter

var totalPathes = 0
for possibleFirstStep in countup(1, 3):
  if pathes.hasKey(possibleFirstStep):
    totalPathes += pathes[possibleFirstStep]

echo(totalPathes)
