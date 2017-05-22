import processing.video.*; //<>//
import java.util.function.*;

PImage img;
PImage img_test;
HScrollbar thresholdBar1;
HScrollbar thresholdBar2;
HScrollbar thresholdBar3;
HScrollbar thresholdBar4;
HScrollbar thresholdBar5;
HScrollbar thresholdBar6;

BlobDetection blob;
QuadGraph graph;
PImage houghImg;
PImage hough_test;
Capture cam;
HoughComparator compare;

void settings() {
  size(1600, 900);
}

void setup() {
  img = loadImage("board1.jpg");
  hough_test = loadImage("hough_test.bmp");
  //img_test = loadImage("board1Scharr.bmp");
  thresholdBar1 = new HScrollbar(0, 480, 800, 20);
  thresholdBar2 = new HScrollbar(0, 520, 800, 20);
  thresholdBar3 = new HScrollbar(0, 580, 800, 20);
  thresholdBar4 = new HScrollbar(0, 620, 800, 20);
  thresholdBar5 = new HScrollbar(0, 680, 800, 20);
  thresholdBar6 = new HScrollbar(0, 720, 800, 20);
  blob = new BlobDetection();
  graph = new QuadGraph();
  //noLoop();
  /*
  String[] cameras = Capture.list();
   if (cameras.length == 0) {
   println("There are no cameras available for capture.");
   exit();
   } else {
   println("Available cameras:");
   for (int i = 0; i < cameras.length; i++) {
   println(cameras[i]);
   }
   cam = new Capture(this, 640, 480);
   cam.start();
   }
   */
}

void draw() {
  /*if (cam.available() == true) {
   cam.read();
   }
   img = cam.get();
   */
  image(img, 0, 0);
  thresholdBar1.update();
  thresholdBar2.update();
  thresholdBar3.update();
  thresholdBar4.update();
  thresholdBar5.update();
  thresholdBar6.update();

  background(color(255));
  //image(hue(img), 0, 0);

  /*PImage img1 = range(img0, (int)map(thresholdBar1.getPos(), 0, 1, 0, 255), (int)map(thresholdBar2.getPos(), 0, 1, 0, 255));
   image(img0, 0, 0);
   
   */

 /* PImage img1 = thresholdHSB(img, (int)map(thresholdBar1.getPos(), 0, 1, 0, 255), (int)map(thresholdBar2.getPos(), 0, 1, 0, 255), 
    (int)map(thresholdBar3.getPos(), 0, 1, 0, 255), (int)map(thresholdBar4.getPos(), 0, 1, 0, 255), 
    (int)map(thresholdBar5.getPos(), 0, 1, 0, 255), (int)map(thresholdBar6.getPos(), 0, 1, 0, 255));
*/
  PImage img1 = thresholdHSB(img, 80, 140, 100, 255, 0, 255);
  image(img, 0, 0);

  PImage img2 = blob.findConnectedComponents(img1, true);
  PImage img3 = gaussian_kernel(img2);


  //image(img2, 800, 0);


  //image(img3, 0, 600);

  PImage img4 = threshold_binary(scharr(img3), 230);
  image(img4, 800, 0);

  List<PVector> lines = hough(img4, 4);
  
  stroke(204, 102, 0);

  drawLines(lines);

  for (PVector vector : graph.findBestQuad(lines, width, height, width * height,(int) ((1.0/5) * width * (1.0/5) * height), false)) {
    ellipse(vector.x, vector.y, 6, 6);
  }


  //image(blob.findConnectedComponents(img4,true), 800, 600);

  thresholdBar1.display();
  thresholdBar2.display();

  thresholdBar3.display();
  thresholdBar4.display();
  thresholdBar5.display();
  thresholdBar6.display();
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    if (red(img1.pixels[i]) != red(img2.pixels[i]))
      return false;
  return true;
}

void drawLines (List<PVector> lines) {

  for (int idx = 0; idx < lines.size(); idx++) {
    PVector line=lines.get(idx);
    float r = line.x;
    float phi = line.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = img.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = img.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }
}