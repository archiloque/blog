package net.archiloque.babaisyousolver;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

class Level {

  final int width;

  final int height;

  @NotNull
  final int[] content;

  Level(
      int width,
      int height,
      @NotNull int[] content) {
    this.width = width;
    this.height = height;
    this.content = content;
  }

}
