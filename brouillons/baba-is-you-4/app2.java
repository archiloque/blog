  if (solution != null) {
    print(
        path,
        "Solved in " +
            LocalTime.MIN.plusNanos(
                (stopTime - startTime)).toString() +
            " " +
            prettyPrintSolution(solution.previousMovements));
  } else {
    print(
        path,
        "Failed in " +
            LocalTime.MIN.plusNanos((stopTime - startTime)).toString());
  }
}

private static @NotNull String prettyPrintSolution(char[] solution) {
  List<String> solutionString = new ArrayList<>();
  char currentMovement = '0';
  int numberOfMovesThisWay = 1;
  for (char c : solution) {
    if (c != currentMovement) {
      if (currentMovement != '0') {
        solutionString.
            add("" + numberOfMovesThisWay + currentMovement);
      }
      currentMovement = c;
      numberOfMovesThisWay = 1;
    } else {
      numberOfMovesThisWay += 1;
    }
  }
  // complete with last move
  solutionString.
      add("" + numberOfMovesThisWay + currentMovement);

  return String.join(" ", solutionString);
}