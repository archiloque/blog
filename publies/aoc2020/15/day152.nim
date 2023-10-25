import strutils
import os
import sequtils
import tables

var initialNumbers: seq[int] = readFile(paramStr(1)).split(`',`').map(parseInt)

var game = newTable[int, int]()

for index in countup(0, initialNumbers.len() - 2):
  let number = initialNumbers[index]
  game[number] = index + 1

proc nextNumber(game: ref Table[int, int], turnNumber: int,
    lastNumber: int): int =
  if game.hasKey(lastNumber):
    result = turnNumber - game[lastNumber]
  else:
    result = 0
  game[lastNumber] = turnNumber

var turnNumber = initialNumbers.len()
var lastNumber = initialNumbers[initialNumbers.len() - 1]
while (turnNumber < 30000000):
  lastNumber = nextNumber(game, turnNumber, lastNumber)
  turnNumber += 1

echo(lastNumber)
