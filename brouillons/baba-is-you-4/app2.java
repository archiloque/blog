  if (solution != null) {
    print(
        path,
        "Solved in " +
            endTime +
            " " +
            prettyPrintSolution(solution.previousMovements));
  } else {
    print(
        path,
        "Failed in " +
            endTime);
  }
}

private static @NotNull String prettyPrintSolution(
  @NotNull byte[] solution) {
  List<String> solutionString = new ArrayList<>();
  byte currentMovement = -1;
  int numberOfMovesThisWay = 1;
  for (byte c : solution) {
    if (c != currentMovement) {
      if (currentMovement != -1) {
        solutionString.
            add(
              "" +
               numberOfMovesThisWay + 
               Direction.VISUAL[currentMovement]);
      }
      currentMovement = c;
      numberOfMovesThisWay = 1;
    } else {
      numberOfMovesThisWay += 1;
    }
  }
  // complete with last move
  solutionString.
      add("" +
       numberOfMovesThisWay + 
       Direction.VISUAL[currentMovement]);

  return String.join(" ", solutionString);
}