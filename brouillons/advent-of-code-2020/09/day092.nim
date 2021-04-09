import strutils
import os
import sequtils
import options

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
  false

proc findSum(input: seq[int], numberToFind: int, setSize: int): Option[seq[int]] =
  for index in countup(0, input.len() - (1 + setSize)):
    let sequence: seq[int] = input[index .. (index + setSize - 1)]
    if sequence.foldl(a + b) == numberToFind:
      return some(sequence)
  none(seq[int])

for currentNumberIndex in countup(preambleSize, input.len() - 1):
  let currentNumber = input[currentNumberIndex]
  if(not findNumber(input, preambleSize, currentNumberIndex)):
    echo("Failed to find value for ", currentNumber)
    for setSize in countup(2, input.len):
      let possibleSeq = findSum(input, currentNumber, setSize)
      if possibleSeq.isSome():
        echo("Found sum ", possibleSeq)
        echo(possibleSeq.get().min() + possibleSeq.get().max())
        quit()

