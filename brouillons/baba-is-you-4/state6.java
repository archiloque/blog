/**
 * Process the current state
 * @return a list of {@link Direction} if we found a solution,
 * else null
 */
@Nullable byte[] processState() {
  int babaPosition = findBaba();
  int babaLine = babaPosition / level.width;
  int babaColumn = babaPosition % level.width;

  byte[] result;
  // Up
  if (babaLine > 0) {
    result = tryToGo(babaPosition, Direction.UP);
    if (result != null) {
      return result;
    }
  }
  // same for other directions
  return null;
}
  
/**
 * Try to go on a direction from a position
 * @return a list of {@link Direction} if we found a solution,
 * else null
 */
@Nullable byte[] tryToGo(
    int currentPosition,
    byte direction) {
  int targetPosition = calculatePosition(currentPosition, direction);
  int targetPositionContent = content[targetPosition];

  int[] newContent;
  switch (targetPositionContent) {
    case Tiles.WALL:
      return null;
    case Tiles.EMPTY:
      newContent = content.clone();
      newContent[targetPosition] = Tiles.BABA;
      newContent[currentPosition] = Tiles.EMPTY;
      level.addState(newContent, addMovement(direction));
      return null;
    case Tiles.ROCK:
      // did we reach the border of the level ?
      if (!canGoThere(targetPosition, direction)) {
        return null;
      }
      // the position behind  the rock
      int behindTheRockPosition = calculatePosition(targetPosition, direction);
      int behindTheRockPositionContent = content[behindTheRockPosition];
      // it it empty?
      if (behindTheRockPositionContent != Tiles.EMPTY) {
        return null;
      }
      // nice, we build the new content
      newContent = content.clone();
      newContent[targetPosition] = Tiles.BABA;
      newContent[currentPosition] = Tiles.EMPTY;
      newContent[behindTheRockPosition] = Tiles.ROCK;
      level.addState(newContent, addMovement(direction));
      return null;
    case Tiles.FLAG:
      return addMovement(direction);
    default:
      throw new IllegalArgumentException("" + targetPositionContent);
  }
}