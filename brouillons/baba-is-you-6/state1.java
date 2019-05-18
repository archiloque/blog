private int pushTiles = Tiles.TEXT_MASKS;

private int stopTiles = 0;

private int youTiles = 0;

private int winTiles = 0;

void processRules() {
  // locate the "IS"
  for (int i = 0; i < level.size; i++) {
    if ((content[i] & Tiles.IS_TEXT_MASK) != 0) {
      // any room to make an horizontal sentence ?
      int isLine = i / level.width;
      if ((isLine > 0) && (isLine < (level.height - 1))) {
        checkRule(
            i - level.width,
            i + level.width);
      }

      // any room to make a vertical sentence ?
      int isColumn = i % level.width;
      if ((isColumn > 0) && (isColumn < (level.width - 1))) {
        checkRule(
            i - 1,
            i + 1);
      }
    }
  }
}

private void checkRule(
    int beforeCellIndex, 
    int afterCellIndex) {
  // validate it's a rule
  int subject = content[beforeCellIndex] &
      Tiles.SUBJECT_MASKS;
  if (subject == 0) {
    return;
  }
  int definition = content[afterCellIndex] &
      Tiles.DEFINITION_MASKS;
  if (definition == 0) {
    return;
  }

  // apply the result
  switch (definition) {
    case Tiles.PUSH_TEXT_MASK:
      pushTiles = pushTiles | subject;
      return;
    case Tiles.STOP_TEXT_MASK:
      stopTiles = stopTiles | subject;
      return;
    case Tiles.WIN_TEXT_MASK:
      winTiles = winTiles | subject;
      return;
    case Tiles.YOU_TEXT_MASK:
      youTiles = youTiles | subject;
      return;
    default:
      throw new IllegalArgumentException(Integer.toString(definition));
  }
}