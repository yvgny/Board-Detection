Movie cam;

void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT, P3D);
}

void setup() {
  cam = new Movie(this, "testvideo.avi");
  cam.loop();
  snowman = loadShape("snowman.obj");
  imgProcessing = new ImageProcessing();
  my_game = new Game();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgProcessing);
  PApplet.runSketch(args, my_game);
  imgProcessing.getSurface().setVisible(false);
  this.getSurface().setVisible(false);
}