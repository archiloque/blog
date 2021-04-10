import strutils
import os
import sequtils
import lists
import tables

var initialCups: seq[int] = readFile(paramStr(1)).map(proc(s: char): int = (
    $s).parseInt())

var maxCupNumber = 0
var cupsRing = initSinglyLinkedRing[int]()
var nodesByValue = initTable[int, SinglyLinkedNode[int]]()
for cupValue in initialCups:
  let node = newSinglyLinkedNode[int](cupValue)
  cupsRing.append(node)
  nodesByValue[cupValue] = node
  if cupValue > maxCupNumber:
    maxCupNumber = cupValue

for cupValue in (maxCupNumber + 1 .. 1_000_000):
  let node = newSinglyLinkedNode[int](cupValue)
  cupsRing.append(node)
  nodesByValue[cupValue] = node

maxCupNumber = 1_000_000

var currentCup: SinglyLinkedNode[int] = cupsRing.head
for currentTurn in countup(1, 10000000):
  let pickedOne = currentCup.next
  let pickedTwo = pickedOne.next
  let pickedThree = pickedTwo.next

  currentCup.next = pickedThree.next

  var foundDestination = false
  var label = currentCup.value - 1
  while not foundDestination:
    if label == 0:
      label = maxCupNumber
    if (pickedOne.value == label) or (pickedTwo.value == label) or (
        pickedThree.value == label):
      label -= 1
    else:
      foundDestination = true
  let destinationCup = nodesByValue[label]
  pickedThree.next = destinationCup.next
  destinationCup.next = pickedOne
  currentCup = currentCup.next

echo(nodesByValue[1].next.value * nodesByValue[1].next.next.value)
