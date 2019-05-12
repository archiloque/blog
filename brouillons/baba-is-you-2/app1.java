/**
 * Entry point
 */
public class App {

  private static final SimpleDateFormat DATE_FORMAT =
      new SimpleDateFormat("yyyy-MM-dd kk:mm:ss.SSS");

  public static void main(String[] args) 
      throws IOException {
    if (args.length == 0) {
      throw new IllegalArgumentException(
          "A level path should be specified");
    }
    processLevel(Path.of(args[0]));

  }

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
    } else {
      print(
          path,
          "Failed in " + endTime);
    }
  }

  private static void print(
      @NotNull Path path,
      @NotNull String message) {
    System.out.println(
        DATE_FORMAT.format(new Date()) +
            " " +
            path.toAbsolutePath() +
            " " +
            message);
  }

}
