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

  // target contains a wall
  if((targetPositionContent & Tiles.WALL_MASK) != 0) {
    return null;
  }
  int[] newContent = content.clone();

  // target is empty
  if(targetPositionContent == 0) {
    newContent[targetPosition] =
        newContent[targetPosition] | Tiles.BABA_MASK;
    newContent[currentPosition] =
        newContent[currentPosition] ^ Tiles.BABA_MASK;
    level.addState(newContent, addMovement(direction));
    return null;
  }
  
  if((targetPositionContent & Tiles.ROCK_MASK) != 0) {
    // did we reach the border of the level ?
    if (!canGoThere(targetPosition, direction)) {
      return null;
    }
    // the position behind  the rock
    int behindTheRockPosition =
        calculatePosition(targetPosition, direction);
    int behindTheRockPositionContent =
        content[behindTheRockPosition];

    // it it a rock ?
    int rockOrWallMask = Tiles.ROCK_MASK | Tiles.WALL_MASK;
    if ((behindTheRockPositionContent & rockOrWallMask) != 0) {
      return null;
    }

    // nice, we build the new content
    // remove the rock
    targetPositionContent = newContent[targetPosition] ^ Tiles.ROCK_MASK;
    newContent[targetPosition] = targetPositionContent;
    // add a rock at the end
    newContent[behindTheRockPosition] =
        newContent[behindTheRockPosition] | Tiles.ROCK_MASK;
  }

  if((targetPositionContent & Tiles.FLAG_MASK) != 0) {
    return addMovement(direction);
  }

  // move Baba
  newContent[targetPosition] =
      newContent[targetPosition] | Tiles.BABA_MASK;
  newContent[currentPosition] =
      newContent[currentPosition] ^ Tiles.BABA_MASK;
  level.addState(newContent, addMovement(direction));
  return null;
}