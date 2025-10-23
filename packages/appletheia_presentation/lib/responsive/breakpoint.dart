enum Breakpoint {
  compact(0),
  medium(600),
  expanded(840),
  large(1200),
  extraLarge(1600);

  final int width;

  const Breakpoint(this.width);
}
