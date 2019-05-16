@Test
void testMoveWall() {
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.WALL_MASK},
      null,
      new int[0][]
  );
}

@Test
void testMoveFlag() {
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.FLAG_MASK},
      new byte[]{Direction.RIGHT},
      new int[0][]
  );
}

@Test
void testMoveRock() {
  // rock against a wall
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK},
      null,
      new int[0][]
  );

  // rock and flag against a wall
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK},
      null,
      new int[0][]
  );

  // rock against a rock against a wall
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.ROCK_MASK},
      null,
      new int[0][]
  );

  // rock against an empty cell
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

  // rock and flag against an empty cell
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK,
          Tiles.EMPTY},
      new byte[]{Direction.RIGHT},
      new int[0][]
  );

  // rock and flag against an flag
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