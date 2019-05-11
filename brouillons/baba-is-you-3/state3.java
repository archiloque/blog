boolean tryToGo(int position, int deltaLine, int deltaColumn) {
    int targetPosition = position + (deltaLine * level.width) + deltaColumn;
    int targetPositionContent = content[targetPosition];

    int[] newContent;
    switch (targetPositionContent) {
      case Tiles.WALL:
        return false;
      case Tiles.EMPTY:
        newContent = content.clone();
        newContent[targetPosition] = Tiles.BABA;
        newContent[position] = Tiles.EMPTY;
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