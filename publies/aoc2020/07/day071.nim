import strutils
import os
import re
import tables
import sets

let noBagContainRegex = re(r"^([a-z ]+) bags contain no other bags\.$")
let bagContain = re(r"^([a-z ]+) bags contain (.+)\.$")
let bagContained = re(r"^(\d+) ([a-z ]+) bag(|s)$")

let input: seq[string] = readFile(paramStr(1)).splitLines()
let targetColor = paramStr(2)

var bagsColorToContainers = initTable[string, seq[string]]()

for line in input:
  if line.match(noBagContainRegex):
    discard
  else:
    var bagContainerMatch: array[2, string]
    if line.match(bagContain, bagContainerMatch):
      let containerBagColor: string = bagContainerMatch[0]
      for contineedBag in bagContainerMatch[1].split(", "):
        var bagContainedMatch: array[3, string]
        if contineedBag.match(bagContained, bagContainedMatch):
          let containedBagColor: string = bagContainedMatch[1]
          if bagsColorToContainers.hasKey(containedBagColor):
            bagsColorToContainers[containedBagColor].add(containerBagColor)
          else:
            bagsColorToContainers[containedBagColor] = @[containerBagColor]
        else:
          raise newException(ValueError, "Can`'t parse [" & contineedBag & "]")
    else:
      raise newException(ValueError, "Can`'t parse [" & line & "]")

echo(bagsColorToContainers)

var alreadyKnowColors = initHashSet[string]()

var knewlyKnowColors: HashSet[string] = bagsColorToContainers[
    targetColor].toHashSet()

while (knewlyKnowColors.len() != 0):
  var knewlyKnewlyKnowColors = initHashSet[string]()
  for knewlyKnowColor in knewlyKnowColors:
    if bagsColorToContainers.hasKey(knewlyKnowColor):
      for colorCandidate in bagsColorToContainers[knewlyKnowColor]:
        if (not alreadyKnowColors.contains(colorCandidate)):
          knewlyKnewlyKnowColors.incl(colorCandidate)
    alreadyKnowColors.incl(knewlyKnowColors)
  knewlyKnowColors = knewlyKnewlyKnowColors

echo(alreadyKnowColors.len, " ", alreadyKnowColors)
