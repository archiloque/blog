char[] solution = level.solve();
long stopTime = System.nanoTime();
if (solution != null) {
  print(
      path,
      "Solved in " +
          LocalTime.MIN.plusNanos(
              (stopTime - startTime)).toString() +
          " " +
          prettyPrintSolution(solution));
