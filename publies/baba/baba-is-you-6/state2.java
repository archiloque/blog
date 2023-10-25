void processRules() {
  // locate the "IS"
  for (int i = 0; i < level.size; i++) {
    if ((content[i] & Tiles.IS_TEXT_MASK) != Tiles.EMPTY) {
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
  // validate it`'s a rule
  int subject = content[beforeCellIndex] &
      Tiles.SUBJECT_MASKS;
  if (subject == Tiles.EMPTY) {
    return;
  }
  int definition = content[afterCellIndex] &
      Tiles.DEFINITION_MASKS;
  if (definition == Tiles.EMPTY) {
    return;
  }

  // apply the result
  int targetMask = Tiles.TARGET_MASKS[subject];
  switch (definition) {
    case Tiles.PUSH_TEXT_MASK:
      pushTilesMask |= targetMask;
      return;
    case Tiles.STOP_TEXT_MASK:
      stopTilesMask |= targetMask;
      return;
    case Tiles.WIN_TEXT_MASK:
      winTilesMask |= targetMask;
      return;
    case Tiles.YOU_TEXT_MASK:
      youTilesMask |= targetMask;
      return;
    default:
      throw new IllegalArgumentException(Integer.toString(definition));
  }
}