/**
 * This set will be able to handle duplication of {@link State}
 * The custom {@link Comparator} is required to avoid
 * only comparing the arrays' addresses
 */
private final Set<int[]> pastStates =
  new TreeSet<>(new Comparator<>() {
    @Override
    public int compare(int[] o1, int[] o2) {
      for (int i = 0; i < size; i++) {
        int cmp = o2[i] - o1[i];
        if (cmp != 0) {
          return cmp;
        }
      }
      return 0;
    }
  });

void addState(@NotNull int[] content) {
  // only add if not already visited
  if (pastStates.add(content)) {
    states.add(new State(this, content));
  }
}