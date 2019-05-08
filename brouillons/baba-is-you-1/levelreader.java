package net.archiloque.babaisyousolver;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

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

    @NotNull
    final int[] content;

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