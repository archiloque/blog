@Nullable byte[] process() {
  processRules();
  if((youTilesMask & Tiles.BABA_MASK) == Tiles.EMPTY) {
    return null;
  }
