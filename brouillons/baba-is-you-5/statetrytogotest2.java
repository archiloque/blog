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