import strutils
import os
import re
import sequtils
import sets

var setup: seq[string] = readFile(paramStr(1)).splitLines()

let ruleRegex = re(r"^([^:]+): (\d+)-(\d+) or (\d+)-(\d+)$")
var values = initHashSet[int]()

var currentLineIndex = 0
var ruleMatch: array[5, string]

while setup[currentLineIndex].match(ruleRegex, ruleMatch):
  for i in countup(ruleMatch[1].parseInt(), ruleMatch[2].parseInt()):
    values.incl(i)
  for i in countup(ruleMatch[3].parseInt(), ruleMatch[4].parseInt()):
    values.incl(i)
  currentLineIndex += 1

while setup[currentLineIndex] != "nearby tickets:":
  currentLineIndex += 1
currentLineIndex += 1

var errorsSum = 0

while currentLineIndex < setup.len():
  for value in (setup[currentLineIndex].split(",").map(parseInt)):
    if not values.contains(value):
      errorsSum += value
  currentLineIndex += 1
echo(errorsSum)
