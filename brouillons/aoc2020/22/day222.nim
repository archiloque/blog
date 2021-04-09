import strutils
import os
import sets

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

proc calculateScore(player1Deck: seq[int], player2Deck: seq[int]) =
  var score = 0
  for cardIndex in countup(1, player1Deck.len()):
    score += cardIndex * player1Deck[ ^ cardIndex]
  for cardIndex in countup(1, player2Deck.len()):
    score += cardIndex * player2Deck[ ^ cardIndex]
  echo(score)

proc playCombat(player1Deck: seq[int], player2Deck: seq[int], depth: int): int =
  var player1Deck = player1Deck
  var player2Deck = player2Deck
  var playedDecks = initHashSet[string]()
  while true:
    if playedDecks.containsOrIncl($player1Deck & $player2Deck):
      if depth == 1:
        calculateScore(player1Deck, player2Deck)
      return 1
    let player1Card = player1Deck[0]
    player1Deck.delete(0)
    let player2Card = player2Deck[0]
    player2Deck.delete(0)

    var winner: int
    if (player1Deck.len() >= player1Card) and (player2Deck.len() >= player2Card):
      winner = playCombat(player1Deck[0 .. player1Card - 1], player2Deck[0 ..
          player2Card - 1], depth + 1)
    else:
      if player1Card > player2Card:
        winner = 1
      elif player2Card > player1Card:
        winner = 2
      else:
        raise newException(ValueError, "Both players have a [" &
            $player1Card & "]")
    if winner == 1:
      player1Deck.add([player1Card, player2Card])
    elif winner == 2:
      player2Deck.add([player2Card, player1Card])
    else:
      raise newException(ValueError, "Unknown player " & $winner)
    if (player1Deck.len() == 0) or (player2Deck.len() == 0):
      if depth == 1:
        calculateScore(player1Deck, player2Deck)
      return winner

discard playCombat(player1Deck, player2Deck, 1)
