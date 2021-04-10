import strutils
import os
import re
import tables
import sets
import math
import algorithm
import sequtils

var input: seq[string] = readFile(paramStr(1)).splitLines()

type
  Tile = ref object
    id: int
    position: int
    bottomBorder: int
    rightBorder: int

proc countPixels(pixels: HashSet[int], initValue: int, delta: int): int =
  result = 0
  for index in countup(0, 9):
    if pixels.contains(initValue + (index * delta)):
      result += 2 ^ (9 - index)

proc initTile(pixels: HashSet[int]): seq[seq[int]] =
  let top = countPixels(pixels, 0, 1)
  let iTop = countPixels(pixels, 9, -1)

  let bottom = countPixels(pixels, 90, 1)
  let iBottom = countPixels(pixels, 99, -1)

  let left = countPixels(pixels, 0, 10)
  let iLeft = countPixels(pixels, 90, -10)

  let right = countPixels(pixels, 9, 10)
  let iRight = countPixels(pixels, 99, -10)

  @[
    @[top, right, bottom, left],
    @[iLeft, top, iRight, bottom],
    @[iBottom, iLeft, iTop, iRight],
    @[right, iBottom, left, iTop],

    @[iTop, left, iBottom, right],
    @[iRight, iTop, iLeft, iBottom],
    @[bottom, iRight, top, iLeft],
    @[left, bottom, right, top],
  ]

var tilesContents = initTable[int, seq[string]]()

var allTiles: seq[Tile] = @[]
var tilesByTopBorder = initTable[int, seq[Tile]]()
var tilesByLeftBorder = initTable[int, seq[Tile]]()
var tilesByTopAndLeftBorder = initTable[string, seq[Tile]]()

let tileIdRegex = re(r"^Tile (\d+):$")
var tileIdMatch: array[1, string]

var tilesNumber = (input.len() / 12).toInt()
for tileIndex in countup(0, tilesNumber - 1):
  if input[tileIndex * 12].match(tileIdRegex, tileIdMatch):
    let tileId = tileIdMatch[0].parseInt()
    var pixels = initHashSet[int]()
    for lineIndex in countup(0, 9):
      let line = input[tileIndex * 12 + lineIndex + 1]
      for pixelIndex, pixel in line:
        case pixel:
        of '#':
          pixels.incl(lineIndex * 10 + pixelIndex)
        of '.':
          discard
        else:
          raise newException(ValueError, "Unknown value [" & pixel & "]")
    for position, border in initTile(pixels):
      let topBorder = border[0]
      let leftBorder = border[3]
      let leftTopBorder = $topBorder & "x" & $leftBorder
      let tile = Tile(id: tileId, bottomBorder: border[2],
          rightBorder: border[1], position: position)
      allTiles.add(tile)

      if tilesByTopBorder.hasKeyOrPut(topBorder, @[tile]):
        tilesByTopBorder[topBorder].add(tile)

      if tilesByLeftBorder.hasKeyOrPut(leftBorder, @[tile]):
        tilesByLeftBorder[leftBorder].add(tile)

      if tilesByTopAndLeftBorder.hasKeyOrPut(leftTopBorder, @[tile]):
        tilesByTopAndLeftBorder[leftTopBorder].add(tile)
    tilesContents[tileId] = input[(tileIndex * 12 + 1) .. (tileIndex * 12 + 10)]
  else:
    raise newException(ValueError, "Unknown operation [" & input[tileIndex *
        12] & "]")

let photoLength = tilesNumber.toFloat.sqrt().toInt()

proc exploreSolutions(tiles: seq[Tile])

proc tileContentAt(tileContent: seq[string], line: int, column: int,
    position: int): char =
  case position:
    of 0:
      tileContent[line][column]
    of 1:
      tileContent[9 - column][line]
    of 2:
      tileContent[9 - line][9 - column]
    of 3:
      tileContent[column][9 - line]
    of 4:
      tileContent[line][9 - column]
    of 5:
      tileContent[9 - column][9 - line]
    of 6:
      tileContent[9 - line][column]
    of 7:
      tileContent[column][line]
    else:
      raise newException(ValueError, "Unknown position [" & $position & "]")

proc printResult(tiles: seq[Tile]) =
  for line in countup(0, photoLength - 1):
    echo(tiles[(line * photoLength) .. ((line + 1) * photoLength -
        1)].map(proc (t: Tile): string = $t.id & " (" & $t.position & ")").join(" "))
  var resultDisplay: seq[string] = @[]
  for i in countup(0, (11 * photoLength) - 1):
    resultDisplay.add(' '.repeat((11 * photoLength) - 1))

  for lineGroup in countup(0, photoLength - 1):
    for columnGroup in countup(0, photoLength - 1):
      let tile = tiles[(lineGroup * photoLength) + columnGroup]
      let tileContent: seq[string] = tilesContents[tile.id]
      for line in countup(0, 9):
        let resultLine = (11 * lineGroup) + line
        let resultColumn = (11 * columnGroup)
        for column in countup(0, 9):
          resultDisplay[resultLine][resultColumn + column] = tileContentAt(
              tileContent, line, column, tile.position)
  for line in resultDisplay:
    echo(line)
  quit()

proc exploreNext(tiles: seq[Tile], tile: Tile) =
  if not tiles.any(proc (t: Tile): bool = t.id == tile.id):
    var newTiles = tiles
    newTiles.add(tile)
    if newTiles.len() == tilesNumber:
      printResult(newTiles)
    else:
      exploreSolutions(newTiles)

proc exploreSolutions(tiles: seq[Tile]) =
  let tileNumber = tiles.len()
  var firstColumn = tileNumber.mod(photoLength) == 0
  var firstLine = tileNumber < photoLength
  if firstLine:
    if firstColumn:
      for tile in allTiles:
        exploreSolutions(@[tile])
    else:
      let previousRight = tiles[tileNumber - 1].rightBorder
      for tile in tilesByLeftBorder.getOrDefault(previousRight, @[]):
        exploreNext(tiles, tile)
  else:
    if firstColumn:
      let previousBottom = tiles[tileNumber - photoLength].bottomBorder
      for tile in tilesByTopBorder.getOrDefault(previousBottom, @[]):
        exploreNext(tiles, tile)
    else:
      let previousBottom = tiles[tileNumber - photoLength].bottomBorder
      let previousRight = tiles[tileNumber - 1].rightBorder
      let bottomRightKey = $previousBottom & "x" & $previousRight
      for tile in tilesByTopAndLeftBorder.getOrDefault(
          bottomRightKey, @[]):
        exploreNext(tiles, tile)

exploreSolutions(@[])
