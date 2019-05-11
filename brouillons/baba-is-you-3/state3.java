boolean tryToGo(int position, char direction) {
  int targetPosition;
  switch (direction) {
    case Direction.UP:
      targetPosition = position - level.width;
      break;
    case Direction.DOWN:
      targetPosition = position + level.width;
      break;
    case Direction.LEFT:
      targetPosition = position - 1;
      break;
    case Direction.RIGHT:
      targetPosition = position + 1;
      break;
    default:
      throw new IllegalArgumentException("" + direction);
  }

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