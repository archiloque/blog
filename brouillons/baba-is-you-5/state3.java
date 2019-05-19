if ((targetPositionContent & Tiles.ROCK_MASK) != Tiles.EMPTY) {
  boolean foundCellAfterRocks = false;
  int candidatePosition = targetPosition;
  // explore the next cells until we find the right stop
  // or until we find a wall or the end of the level
  while (!foundCellAfterRocks) {
    // did we reach the border of the level?
    if (!canGoThere(candidatePosition, direction)) {
      return null;
    }
    // the position behind the current position
    int behindCandidatePosition =
        calculatePosition(candidatePosition, direction);
    int behindCandidatePositionContent =
        content[behindCandidatePosition];

    // is it a wall?
    if ((behindCandidatePositionContent & Tiles.WALL_MASK) != Tiles.EMPTY) {
      return null;
    }

    // is it another rock?
    if ((behindCandidatePositionContent & Tiles.ROCK_MASK) != Tiles.EMPTY) {
      // yes another rock, next step of the loop
      candidatePosition = behindCandidatePosition;
    } else {
      // no rock, we found a solution!
      foundCellAfterRocks = true;
      // we build the new content
      // remove the rock near Baba
      targetPositionContent =
          newContent[targetPosition] ^ Tiles.ROCK_MASK;
      newContent[targetPosition] = targetPositionContent;
      // add a rock at the end
      newContent[behindCandidatePosition] =
          behindCandidatePositionContent | Tiles.ROCK_MASK;
    }
  }
}