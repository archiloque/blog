@Nullable byte[] solve() {
    while (true) {
      State state = states.pop();
      if (state == null) {
        return null;
      }
      byte[] result = state.process();
      if (result != null) {
        return result;
      }
    }
  }