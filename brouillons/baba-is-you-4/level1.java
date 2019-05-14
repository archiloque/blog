@Nullable char[] solve() {
    char[] result;
    while (!states.isEmpty()) {
      State state = states.pop();
      result = state.processState();
      if (result != null) {
        return result;
      }
    }
    return null;
  }