@Nullable byte[] processState() {
  processRules();
  if((youTilesMask & Tiles.BABA_MASK) == Tiles.EMPTY) {
    return null;
  }
