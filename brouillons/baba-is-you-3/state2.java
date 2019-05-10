  /**
   * Process the current state
   *
   * @return true if we found a solution
   */
  boolean processState() {
    int babaPosition = findBaba();
    int babaLine = babaPosition / level.width;
    int babaColumn = babaPosition % level.width;

    // Up
    if (babaLine > 0) {
      if (tryToGo(-1, 0)) {
        return true;
      }
    }

    // Down
    if (babaLine < (level.height - 1)) {
      if (tryToGo(1, 0)) {
        return true;
      }
    }

    // Left
    if (babaColumn > 0) {
      if (tryToGo(0, -1)) {
        return true;
      }
    }

    // Right
    if (babaColumn < (level.width - 1)) {
      if (tryToGo(0, +1)) {
        return true;
      }
    }

    return false;
  }

  boolean tryToGo(int deltaLine, int deltaColumn) {
    // @TODO probably add some code here
    return false;
  }

  /**
   * Find the index of the baba position.
   *
   * @return the position or -1 if not found
   */
  int findBaba() {
    for (int i = 0; i < content.length; i++) {
      if (content[i] == Tiles.BABA) {
        return i;
      }
    }
    return -1;
  }
