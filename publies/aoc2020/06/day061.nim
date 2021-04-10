import strutils
import os
import sets

let input: seq[string] = readFile(paramStr(1)).splitLines()

var sumCounts = 0
var currentGroupLetters = initHashSet[char]()
for line in input:
  if line.len == 0:
    sumCounts += currentGroupLetters.len()
    currentGroupLetters = initHashSet[char]()
  else:
    for c in line:
      currentGroupLetters.incl(c)

sumCounts += currentGroupLetters.len()
echo(sumCounts)
