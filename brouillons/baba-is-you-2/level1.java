class Level {

  final int width;

  final int height;

  final @NotNull int[] content;

  Level(
      int width,
      int height,
      @NotNull int[] content) {
    this.width = width;
    this.height = height;
    this.content = content;
  }

}
