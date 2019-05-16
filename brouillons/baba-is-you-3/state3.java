case Tiles.ROCK:
  // did we reach the border of the level ?
  if(!canGoThere(targetPosition, direction)) {
    return false;
  }
  // the position behind the rock
  int behindTheRockPosition = calculatePosition(targetPosition, direction);
  int behindTheRockPositionContent = content[behindTheRockPosition];
  // it it empty?
  if(behindTheRockPositionContent != Tiles.EMPTY) {
    return false;
  }
  // nice, we build the new content
  newContent = content.clone();
  newContent[targetPosition] = Tiles.BABA;
  newContent[currentPosition] = Tiles.EMPTY;
  newContent[behindTheRockPosition] = Tiles.ROCK;
  level.addState(newContent);
  return false;