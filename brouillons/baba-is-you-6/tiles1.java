int TEXT_MASKS = 7610;

int SUBJECT_MASKS = 1162;

int DEFINITION_MASKS = 6432;

static int getTarget(int sourceMask) {
  switch (sourceMask) {
  case Tiles.WALL_TEXT_MASK:
    return WALL_MASK;
  case Tiles.BABA_TEXT_MASK:
    return BABA_MASK;
  case Tiles.FLAG_TEXT_MASK:
    return FLAG_MASK;
  case Tiles.ROCK_TEXT_MASK:
    return ROCK_MASK;
  default:
    throw new IllegalArgumentException(Integer.toString(sourceMask));
  }
}