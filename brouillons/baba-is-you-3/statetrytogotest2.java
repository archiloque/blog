void testMoveRock() {
  // rock
  checkMoveSimple(
      new int[]{
          Tiles.BABA,
          Tiles.ROCK},
      false,
      new int[0][]);

  // rock | rock
  checkMoveSimple(
      new int[]{
          Tiles.BABA,
          Tiles.ROCK,
          Tiles.ROCK},
      false,
      new int[0][]);

  // rock | wall
  checkMoveSimple(
      new int[]{
          Tiles.BABA,
          Tiles.ROCK,
          Tiles.WALL},
      false,
      new int[0][]);

  // rock | empty
  checkMoveSimple(
      new int[]{
          Tiles.BABA,
          Tiles.ROCK,
          Tiles.EMPTY},
      false,
      new int[][]{new int[]{
          Tiles.EMPTY,
          Tiles.BABA,
          Tiles.ROCK}});
}