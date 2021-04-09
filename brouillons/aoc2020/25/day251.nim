import strutils
import os
import tables

var cardPublicKey: int = paramStr(1).parseInt()
var doorPublicKey: int = paramStr(2).parseInt()

var tranformationsResults = initTable[int, int]()

proc calculateLoopSize(publicKey: int): int =
  var loopIndex = 0
  var currentValue = 1
  while true:
    loopIndex += 1
    if tranformationsResults.hasKey(loopIndex):
      currentValue = tranformationsResults[loopIndex]
    else:
      currentValue = (currentValue * 7).mod(20201227)
      tranformationsResults[loopIndex] = currentValue
    if currentValue == publicKey:
      return loopIndex

proc transform(subjectNumber: int, times: int): int =
  var currentValue = 1
  for loopIndex in countup(0, times - 1):
    currentValue = (currentValue * subjectNumber).mod(20201227)
  currentValue

var cardLoopSize = calculateLoopSize(cardPublicKey)
var doorLoopSize = calculateLoopSize(doorPublicKey)
echo("cardLoopSize ", cardLoopSize)
echo("doorLoopSize ", doorLoopSize)

var cardEncryptionKey = transform(doorPublicKey, cardLoopSize)
var doorEncryptionKey = transform(cardPublicKey, doorLoopSize)
echo("cardEncryptionKey ", cardEncryptionKey)
echo("doorEncryptionKey ", doorEncryptionKey)
