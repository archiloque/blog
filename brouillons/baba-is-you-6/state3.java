/**
 * Try to go on a direction from a position
 *
 * @return a list of {@link Direction} if a solution is found,
 * else null
 */
@Nullable byte[] tryToGo(
    int currentPosition,
    byte direction) {
  int targetPosition = calculatePosition(currentPosition, direction);
  int targetPositionContent = content[targetPosition];

  // target contains something that stops me
  if ((targetPositionContent & stopTilesMask) != Tiles.EMPTY) {
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

  int currentPushingMask = targetPositionContent & pushTilesMask;
  if (currentPushingMask != Tiles.EMPTY) {
    // remove the pushed elements
    targetPositionContent &= (~pushTilesMask);

    int candidatePosition = targetPosition;
    // explore the next cells until the right stop,
    // a wall or the end of the level
    while (currentPushingMask != Tiles.EMPTY) {
      // reached the border of the level?
      if (!canGoThere(candidatePosition, direction)) {
        return null;
      }
      // the position behind the current position
      int behindCandidatePosition =
          calculatePosition(candidatePosition, direction);
      int behindCandidatePositionContent =
          newContent[behindCandidatePosition];

      // is it something that stop me
      if ((behindCandidatePositionContent & stopTilesMask) != Tiles.EMPTY) {
        return null;
      }

      // is it another thing that should be pushed?
      int behindCandidatePushingMask = behindCandidatePositionContent & pushTilesMask;
      if ((behindCandidatePushingMask) != Tiles.EMPTY) {
        // yes another thing to push

        // remove the pushed thing from next cell
        // and add the thing that was being pushed
        behindCandidatePositionContent =
            behindCandidatePositionContent &
                (~behindCandidatePushingMask) |
                currentPushingMask;
        newContent[behindCandidatePosition] = behindCandidatePositionContent;
        currentPushingMask = behindCandidatePushingMask;
        candidatePosition = behindCandidatePosition;
      } else {
        // found a cell that suits us!
        // add the thing that was being pushed

        // build the new content
        newContent[targetPosition] = targetPositionContent;
        // add a rock at the end
        newContent[behindCandidatePosition] |= currentPushingMask;
        currentPushingMask = Tiles.EMPTY;
      }
    }
  }

  if ((targetPositionContent & winTilesMask) != Tiles.EMPTY) {
    return addMovement(direction);
  }

  // move Baba
  newContent[targetPosition] |= Tiles.BABA_MASK;
  newContent[currentPosition] ^= Tiles.BABA_MASK;
  level.addState(newContent, addMovement(direction));
  return null;
}