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

type
  ContainedBag = ref object
    bag: Bag
    quantity: int
  Bag = ref object
    name: string
    containedBags: ref seq[ContainedBag]
    containedQuantity: int

var bagsColorToBag = initTable[string, Bag]()

for line in input:
  var noBagContainMatch: array[1, string]
  if line.match(noBagContainRegex, noBagContainMatch):
    let containerBagColor: string = noBagContainMatch[0]
    if bagsColorToBag.hasKey(containerBagColor):
      bagsColorToBag[containerBagColor].containedQuantity = 0
    else:
      bagsColorToBag[containerBagColor] = Bag(name: containerBagColor,
          containedQuantity: 0, containedBags: new seq[ContainedBag])
  else:
    var bagContainerMatch: array[2, string]
    if line.match(bagContain, bagContainerMatch):
      let containerBagColor: string = bagContainerMatch[0]
      var containerBag: Bag
      if bagsColorToBag.hasKey(containerBagColor):
        containerBag = bagsColorToBag[containerBagColor]
      else:
        containerBag = Bag(name: containerBagColor, containedQuantity: -1,
            containedBags: new seq[ContainedBag])
        bagsColorToBag[containerBagColor] = containerBag

      let containedBags: ref seq[ContainedBag] = containerBag.containedBags

      for containedBag in bagContainerMatch[1].split(", "):
        var bagContainedMatch: array[3, string]
        if containedBag.match(bagContained, bagContainedMatch):
          let containedBagColor: string = bagContainedMatch[1]
          let containedBagQuantity: int = bagContainedMatch[0].parseInt()
          var containedBag: Bag
          if bagsColorToBag.hasKey(containedBagColor):
            containedBag = bagsColorToBag[containedBagColor]
          else:
            containedBag = Bag(name: containedBagColor, containedQuantity: -1,
                containedBags: new seq[ContainedBag])
            bagsColorToBag[containedBagColor] = containedBag
          containedBags[].add(ContainedBag(bag: containedBag,
              quantity: containedBagQuantity))
        else:
          raise newException(ValueError, "Can`'t parse [" & containedBag & "]")
    else:
      raise newException(ValueError, "Can`'t parse [" & line & "]")

var bagsColorsToExplore: seq[string] = @[targetColor]
while bagsColorsToExplore.len() != 0:
  let lastColorToExplore = bagsColorsToExplore[ ^ - 1]
  let lastBagToExplore: Bag = bagsColorToBag[lastColorToExplore]
  var canComputeBag = true
  var numberOfBags = 0
  for containedBag in lastBagToExplore.containedBags[]:
    if containedBag.bag.containedQuantity == -1:
      bagsColorsToExplore.add(containedBag.bag.name)
      canComputeBag = false
    else:
      numberOfBags = numberOfBags + (containedBag.bag.containedQuantity + 1) *
          containedBag.quantity
  if canComputeBag:
    lastBagToExplore.containedQuantity = numberOfBags
    bagsColorsToExplore.delete(bagsColorsToExplore.len() - 1)
echo(bagsColorToBag[targetColor].containedQuantity)
