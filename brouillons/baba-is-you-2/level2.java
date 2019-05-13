private final @NotNull FiFoQueue<State> states =
    new FiFoQueue<>();

void createInitStates() {
  addState(content);
}

void addState(@NotNull int[] content) {
  states.add(new State(this, content));
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