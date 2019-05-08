  final @NotNull FiFoQueue<State> states = new FiFoQueue<>();

  void createInitStates() {
    State state = new State(this, content);
    states.add(state);
  }

  @Nullable State solve() {
    while (!states.isEmpty()) {
      State state = states.pop();
      if (state.processState()) {
        return state;
      }
    }
    return null;
  }