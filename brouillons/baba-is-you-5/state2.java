/**
 * Try to go on a direction from a position
 * @return a list of {@link Direction} if a solution is found,
 * else null
 */
@Nullable byte[] tryToGo(
    int currentPosition,
    byte direction) {
  int targetPosition = calculatePosition(currentPosition, direction);
  int targetPositionContent = content[targetPosition];

  // target contains a wall
  if ((targetPositionContent & Tiles.WALL_MASK) != Tiles.EMPTY) {
    return null;
  }
  int[] newContent = content.clone();

  // target is empty
  if (targetPositionContent == Tiles.EMPTY) {
    newContent[targetPosition] |= Tiles.BABA_MASK;
    newContent[currentPosition] ^= Tiles.BABA_MASK;
    level.addState(newContent, addMovement(direction));
    return null;
  }
  
  if ((targetPositionContent & Tiles.ROCK_MASK) != Tiles.EMPTY) {
    // reached the border of the level?
    if (!canGoThere(targetPosition, direction)) {
      return null;
    }
    // the position behind the rock
    int behindTheRockPosition =
        calculatePosition(targetPosition, direction);
    int behindTheRockPositionContent =
        content[behindTheRockPosition];

    // does it block the move?
    int blockingMask = Tiles.ROCK_MASK | Tiles.WALL_MASK;
    if ((behindTheRockPositionContent & blockingMask) != Tiles.EMPTY) {
      return null;
    }

    // nice, build the new content
    // remove the rock
    targetPositionContent = newContent[targetPosition] ^ Tiles.ROCK_MASK;
    newContent[targetPosition] = targetPositionContent;
    // add a rock at the end
    newContent[behindTheRockPosition] =
        behindTheRockPositionContent | Tiles.ROCK_MASK;
  }

  if ((targetPositionContent & Tiles.FLAG_MASK) != Tiles.EMPTY) {
    return addMovement(direction);
  }

  // move Baba
  newContent[targetPosition] |= Tiles.BABA_MASK;
  newContent[currentPosition] ^= Tiles.BABA_MASK;
  level.addState(newContent, addMovement(direction));
  return null;
}