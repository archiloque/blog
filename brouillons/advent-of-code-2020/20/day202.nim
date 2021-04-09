import strutils
import sequtils
import os

var input: seq[string] = readFile(paramStr(1)).splitLines()
var photoLength = (input.len() / 11).toInt()

var picture: seq[string] = @[]
for pictureLineIndex in countup(0, photoLength - 1):
  for lineIndex in countup(0, 7):
    var sourceLine: int
    if pictureLineIndex == 0:
      sourceLine = lineIndex + 1
    else:
      sourceLine = (pictureLineIndex * 11) + 1 + lineIndex

    var currentLine = ' '.repeat(8 * photoLength)

    for pictureColumnIndex in countup(0, photoLength - 1):
      for columnIndex in countup(0, 7):
        var sourceColumn: int
        if pictureColumnIndex == 0:
          sourceColumn = columnIndex + 1
        else:
          sourceColumn = (pictureColumnIndex * 11) + 1 + columnIndex
        currentLine[(8 * pictureColumnIndex) + columnIndex] = input[sourceLine][sourceColumn]
    picture.add(currentLine)
echo(picture.join("\n"))

const seaMonster = """                  # 
#    ##    ##    ###
 #  #  #  #  #  #   """.split("\n")

echo("")

proc paintSeaMonster(picture: var seq[string], pictureLineIndex: int,
    pictureColumnIndex: int) =
  for monsterLineIndex in countup(0, seaMonster.len() - 1):
    for monsterColumnIndex in countup(0, seaMonster[0].len() - 1):
      if (seaMonster[monsterLineIndex][monsterColumnIndex] == '#'):
        picture[pictureLineIndex + monsterLineIndex][pictureColumnIndex +
          monsterColumnIndex] = 'O'

proc checkSeaMonster(picture: seq[string], pictureLineIndex: int,
    pictureColumnIndex: int): bool =
  for monsterLineIndex in countup(0, seaMonster.len() - 1):
    for monsterColumnIndex in countup(0, seaMonster[0].len() - 1):
      if (seaMonster[monsterLineIndex][monsterColumnIndex] == '#') and (
          picture[pictureLineIndex + monsterLineIndex][pictureColumnIndex +
          monsterColumnIndex] == '.'):
        return false
  return true

proc tileContentAt(picture: seq[string], line: int, column: int,
    position: int): char =
  case position:
    of 0:
      picture[line][column]
    of 1:
      picture[picture.len() - 1 - column][line]
    of 2:
      picture[picture.len() - 1 - line][picture.len() - 1 - column]
    of 3:
      picture[column][picture.len() - 1 - line]
    of 4:
      picture[line][picture.len() - 1 - column]
    of 5:
      picture[picture.len() - 1 - column][picture.len() - 1 - line]
    of 6:
      picture[picture.len() - 1 - line][column]
    of 7:
      picture[column][line]
    else:
      raise newException(ValueError, "Unknown position [" & $position & "]")

for position in countup(0, 7):
  var positionedPicture: seq[string] = @[]
  for lineIndex in countup(0, picture.len() - 1):
    var positionedPictureLine = ' '.repeat(picture.len())
    for columnIndex in countup(0, picture.len() - 1):
      positionedPictureLine[columnIndex] = tileContentAt(picture, lineIndex,
          columnIndex, position)
    positionedPicture.add(positionedPictureLine)

  var monsterFound = false
  for pictureLineIndex in countup(0, picture.len() - seaMonster.len()):
    for pictureColumnIndex in countup(0, picture[0].len() - seaMonster[0].len()):
      if checkSeaMonster(positionedPicture, pictureLineIndex,
          pictureColumnIndex):
        monsterFound = true
        paintSeaMonster(positionedPicture, pictureLineIndex, pictureColumnIndex)
        echo("Found monster at (", pictureLineIndex, ", ", pictureColumnIndex, ")")
  if monsterFound:
    echo(positionedPicture.join("\n"))
    var hashes = positionedPicture.map(proc (l: string): int = l.count(
        '#')).foldl(a + b)
    echo(hashes)
    quit()
