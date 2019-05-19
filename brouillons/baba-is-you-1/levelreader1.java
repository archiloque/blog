final class LevelReader {

  private LevelReader() {
  }

  private static final String TILES_FILES = "tiles.txt";
  private static final String CONTENT_FILES = "content.txt";

  /**
   * Read a level from a directory.
   */
  static @NotNull LevelReaderResult readLevel(
      @NotNull Path levelDirectory)
      throws IOException {
    return readContent(levelDirectory, readTiles(levelDirectory));
  }

  private final static Pattern TILES_REGEX =
      Pattern.compile("^(.{1}) (.+)$");
    // Je me demande à quoi sert ce {1}.
    // Je le lis comme « 1 répétition du caractère précédent ».
    // Mais ça me semble redondant.

  /**
   * Read the tiles declaration
   * from the {@link LevelReader#TILES_FILES} file
   */
  static @NotNull Map<Character, Integer> readTiles(
      @NotNull Path levelDirectory) throws IOException {
    // @TODO probably add some code here
    return new HashMap<>();
  }

  /**
   * Read the file content
   * from the {@link LevelReader#CONTENT_FILES} file
   * relying the declared tiles
   */
  static @NotNull LevelReaderResult readContent(
      @NotNull Path levelDirectory,
      @NotNull Map<Character,
          Integer> tiles) throws IOException {
    // @TODO probably add some code here
    return null;
  }


  static final class LevelReaderResult {

    final int width;
    final int height;
    final @NotNull int[] content;

    LevelReaderResult(
        int width,
        int height,
        @NotNull int[] content) {
      this.width = width;
      this.height = height;
      this.content = content;
    }
  }
}
