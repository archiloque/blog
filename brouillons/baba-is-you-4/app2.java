private static final String SOLUTION_FILES = "solution.txt";

private static void processLevel(
    @NotNull Path path
) throws IOException {
  print(path, "Reading level");
  LevelReader.LevelReaderResult levelReaderResult =
      LevelReader.readLevel(path);
  Level level = new Level(
      levelReaderResult.width,
      levelReaderResult.height,
      levelReaderResult.content);
  level.createInitStates();
  Path solutionFile = path.resolve(SOLUTION_FILES);
  Files.deleteIfExists(solutionFile);
  print(path, "Solving level");
  long startTime = System.nanoTime();
  State solution = level.solve();
  long stopTime = System.nanoTime();
  String endTime =
      LocalTime.MIN.plusNanos((stopTime - startTime)).
          toString();
  if (solution != null) {
    print(
        path,
        "Solved in " + endTime);
    writeSolution(solution.previousMovements, solutionFile);
  } else {
    print(
        path,
        "Failed in " + endTime);
  }
}

private static void writeSolution(
    @NotNull byte[] solution,
    @NotNull Path solutionPath)
    throws IOException {
  List<String> steps = new ArrayList<>();
  byte currentMovement = -1;
  int numberOfMovesThisWay = 1;
  for (byte c : solution) {
    if (c != currentMovement) {
      if (currentMovement != -1) {
        steps.
            add("" +
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
    steps.
        add("" +
            numberOfMovesThisWay +
            Direction.VISUAL[currentMovement]);

  String content = String.join(" ", steps);
  Files.write(solutionPath, content.getBytes());
}