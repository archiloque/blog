import strutils
import sets
import os

let input: seq[string] = readFile(paramStr(1)).splitLines()

var sumCounts = 0
var newGroup = true
var currentGroupLetters = initHashSet[char]()
for line in input:
  if line.len == 0:
    sumCounts += currentGroupLetters.len()
    var currentGroupLetters = initHashSet[char]()
    newGroup = true
  elif newGroup:
    newGroup = false
    currentGroupLetters = toHashSet(line)
  else:
    currentGroupLetters = currentGroupLetters * toHashSet(line)

sumCounts += currentGroupLetters.len()
echo(sumCounts)
