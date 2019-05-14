@Test
void testMoveRock() {
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK},
      null,
      new int[0][]
  );

  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK},
      null,
      new int[0][]
  );

  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.ROCK_MASK},
      null,
      new int[0][]
  );

  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.EMPTY},
      null,
      new int[][]{new int[]{
          Tiles.EMPTY,
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK}}
  );


  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK,
          Tiles.EMPTY},
      new byte[]{Direction.RIGHT},
      new int[0][]
  );

  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.FLAG_MASK},
      null,
      new int[][]{new int[]{
          Tiles.EMPTY,
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK}}
  );
}