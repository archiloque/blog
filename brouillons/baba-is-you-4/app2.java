byte[] solution = level.solve();
long stopTime = System.nanoTime();
String endTime =
  LocalTime.MIN.plusNanos((stopTime - startTime)).
      toString();
if (solution != null) {
  print(
    path,
    "Solved in " + endTime);
  writeSolution(solution, solutionFile);
