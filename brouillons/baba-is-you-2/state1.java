class State {

  private final @NotNull Level level;

  /**
   * Probably not the right format, just drafting
   */
  private final @NotNull int[] content;

  State(
      @NotNull Level level,
      @NotNull int[] content) {
    this.level = level;
    this.content = content;
  }

  /**
   * Process the current state
   *
   * @return true if we found a solution
   */
  boolean processState() {
    // @TODO probably add some code here
    return false;
  }
}
