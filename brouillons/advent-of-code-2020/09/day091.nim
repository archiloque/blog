import strutils
import os
import sequtils

let input: seq[int] = readFile(paramStr(1)).splitLines().map(parseInt)
let preambleSize = paramStr(2).parseInt()

proc findNumber(input: seq[int], preambleSize: int,
    currentNumberIndex: int): bool =
  let currentNumber = input[currentNumberIndex]
  for firstIndex in countup(currentNumberIndex - preambleSize,
      currentNumberIndex - 1):
    for secondIndex in countup(currentNumberIndex - preambleSize,
        currentNumberIndex - 1):
      if (firstIndex != secondIndex) and ((input[firstIndex] + input[
          secondIndex]) == currentNumber):
        return true
  return false

for currentNumberIndex in countup(preambleSize, input.len() - 1):
  let currentNumber = input[currentNumberIndex]
  if(not findNumber(input, preambleSize, currentNumberIndex)):
    echo("Failed to find value for ", currentNumber)
    quit()

