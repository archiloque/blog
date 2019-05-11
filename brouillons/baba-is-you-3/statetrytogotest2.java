@Test
void testMoveRock() {
  checkMoveSimple(
      new int[]{Tiles.BABA, Tiles.ROCK},
      false,
      new int[0][]
  );

  checkMoveSimple(
      new int[]{Tiles.BABA, Tiles.ROCK, Tiles.ROCK},
      false,
      new int[0][]
  );

  checkMoveSimple(
      new int[]{Tiles.BABA, Tiles.ROCK, Tiles.EMPTY},
      false,
      new int[][]{new int[]{Tiles.EMPTY, Tiles.BABA, Tiles.ROCK}}
  );
}