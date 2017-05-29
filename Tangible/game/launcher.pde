void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT, P3D);
}

void setup() {
  imgProcessing = new ImageProcessing();
  my_game = new Game();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgProcessing);
  PApplet.runSketch(args, my_game);
}