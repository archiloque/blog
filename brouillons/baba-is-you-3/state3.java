/**
 * Try to go on a direction from a position
 * @return true if a solution has been found
 */
boolean tryToGo(int currentPosition, byte direction) {
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
      level.addState(newContent);
      return false;
    case Tiles.ROCK:
      // @TODO implements this
      return false;
    case Tiles.FLAG:
      return true;
    default:
      throw new IllegalArgumentException("" + targetPositionContent);
  }
}

/**
 * Calculate the index of a position after a move
 */
private int calculatePosition(int position, byte direction) {
  // Content is stored as a single array one line after another
  switch (direction) {
    case Direction.UP:
      // up: go back one row
      return position - level.width;
    case Direction.DOWN:
      // down: go further one row
      return position + level.width;
    case Direction.LEFT:
      // left : go back one item
      return position - 1;
    case Direction.RIGHT:
      // left : go further one item
      return position + 1;
    default:
      throw new IllegalArgumentException("" + direction);
  }
}