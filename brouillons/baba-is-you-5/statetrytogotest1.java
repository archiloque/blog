@Test
void testMoveEmpty() {
  // empty
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.EMPTY},
      null,
      new int[][]{new int[]{
          Tiles.EMPTY,
          Tiles.BABA_MASK}});
}

@Test
void testMoveWall() {
  // wall
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.WALL_MASK},
      null,
      new int[0][]);
}

@Test
void testMoveFlag() {
  // flag
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.FLAG_MASK},
      new byte[]{Direction.RIGHT},
      new int[0][]);
}

@Test
void testMoveRock() {
  // rock
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK},
      null,
      new int[0][]);

  // rock + flag
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK},
      null,
      new int[0][]);

  // rock | rock
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.ROCK_MASK},
      null,
      new int[0][]);

  // rock | wall
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.WALL_MASK},
      null,
      new int[0][]);

  // rock | empty
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.EMPTY},
      null,
      new int[][]{new int[]{
          Tiles.EMPTY,
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK}});

  // rock + flag | empty
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK,
          Tiles.EMPTY},
      new byte[]{Direction.RIGHT},
      new int[0][]);

  // rock | flag
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.FLAG_MASK},
      null,
      new int[][]{new int[]{
          Tiles.EMPTY,
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK}});

  // rock | rock | empty
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.ROCK_MASK,
          Tiles.EMPTY},
      null,
      new int[][]{new int[]{
          Tiles.EMPTY,
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.ROCK_MASK}});

  // rock | rock | wall | empty
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK,
          Tiles.ROCK_MASK,
          Tiles.WALL_MASK,
          Tiles.EMPTY},
      null,
      new int[0][]);

  // rock + flag | rock | empty
  checkMoveSimple(
      new int[]{
          Tiles.BABA_MASK,
          Tiles.ROCK_MASK | Tiles.FLAG_MASK,
          Tiles.ROCK_MASK,
          Tiles.EMPTY},
      new byte[]{Direction.RIGHT},
      new int[0][]);
}