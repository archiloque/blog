/**
 * Find the index of the baba position.
 *
 * @return the position or -1 if not found
 */
private int findBaba() {
	for (int i = 0; i < level.size; i++) {
	  if ((content[i] & Tiles.BABA_MASK) != 0) {
		return i;
	  }
	}
	return -1;
}