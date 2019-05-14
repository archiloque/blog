final @NotNull byte[] previousMovements;

State(
    @NotNull Level level,
    @NotNull int[] content,
    @NotNull byte[] movements) {
  this.level = level;
  this.content = content;
  this.previousMovements = movements;
}

boolean tryToGo(
    int currentPosition,
    byte direction) {
  int targetPosition = calculatePosition(currentPosition, direction);
  int targetPositionContent = content[targetPosition];

  int[] newContent;
  switch (targetPositionContent) {
    case Tiles.WALL:
      return false;
    case Tiles.EMPTY:
      newContent = content.clone();
      newContent[targetPosition] = Tiles.BABA;
      newContent[currentPosition] = Tiles.EMPTY;
      level.addState(newContent, addMovement(direction));
      return false;
    case Tiles.ROCK:
      // did we reach the border of the level ?
      if (!canGoThere(targetPosition, direction)) {
        return false;
      }
      // the position behind  the rock
      int behindTheRockPosition = calculatePosition(targetPosition, direction);
      int behindTheRockPositionContent = content[behindTheRockPosition];
      // it it empty?
      if (behindTheRockPositionContent != Tiles.EMPTY) {
        return false;
      }
      // nice, we build the new content
      newContent = content.clone();
      newContent[targetPosition] = Tiles.BABA;
      newContent[currentPosition] = Tiles.EMPTY;
      newContent[behindTheRockPosition] = Tiles.ROCK;
      level.addState(newContent, addMovement(direction));
      return false;
    case Tiles.FLAG:
      return true;
    default:
      throw new IllegalArgumentException("" + targetPositionContent);
  }
}

/**
 * Add a new movement at the end of the array
 */
private @NotNull byte[] addMovement(byte movement) {
  int previousLength = previousMovements.length;
  byte[] result = new byte[previousLength + 1];
  System.arraycopy(previousMovements, 0, result, 0, previousLength);
  result[previousLength] = movement;
  return result;
}