import strutils
import os
import sequtils
import algorithm
import tables

var input: seq[int] = readFile(paramStr(1)).splitLines().map(parseInt)
input.sort(system.cmp[int])

var joltsDelta: Table[int, int] = initTable[int, int]()
for adapterIndex in countup(0, input.len() - 2):
  var delta = input[adapterIndex + 1] - input[adapterIndex]
  if joltsDelta.contains(delta):
    joltsDelta[delta] += 1
  else:
    joltsDelta[delta] = 1

joltsDelta[input[0]] += 1
joltsDelta[3] += 1
echo(joltsDelta[1], " ", joltsDelta[3], " ", joltsDelta[1] * joltsDelta[3])
