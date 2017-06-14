Movie cam;
PImage img;

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
  String []args2 = {"Game window"};

  cam.read();
  img = cam.get();
  img.loadPixels();
  PApplet.runSketch(args, imgProcessing);
  PApplet.runSketch(args2, my_game);
  imgProcessing.getSurface().setVisible(false);
  this.getSurface().setVisible(false);
}