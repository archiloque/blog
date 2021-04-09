import strutils
import os

var player1Deck: seq[int] = @[]
var player2Deck: seq[int] = @[]

var input: seq[string] = readFile(paramStr(1)).splitLines()

var lineIndex = 1
while input[lineIndex] != "":
  player1Deck.add(input[lineIndex].parseInt())
  lineIndex += 1

lineIndex += 2

while lineIndex < input.len():
  player2Deck.add(input[lineIndex].parseInt())
  lineIndex += 1

while (player1Deck.len() != 0) and (player2Deck.len() != 0):
  let player1Card = player1Deck[0]
  player1Deck.delete(0)
  let player2Card = player2Deck[0]
  player2Deck.delete(0)
  if player1Card > player2Card:
    player1Deck.add([player1Card, player2Card])
  elif player2Card > player1Card:
    player2Deck.add([player2Card, player1Card])
  else:
    raise newException(ValueError, "Both players have a [" & $player1Card & "]")

var score = 0
for cardIndex in countup(1, player1Deck.len()):
  score += cardIndex * player1Deck[ ^ cardIndex]
for cardIndex in countup(1, player2Deck.len()):
  score += cardIndex * player2Deck[ ^ cardIndex]
echo(score)
