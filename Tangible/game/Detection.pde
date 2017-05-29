import processing.video.*; //<>// //<>// //<>//
import java.util.function.*;
import gab.opencv.*;

float discretizationStepsPhi = 0.06f;
float discretizationStepsR = 2.5f;



// dimensions of the accumulator
int phiDim = (int) (Math.PI / discretizationStepsPhi +1);

// pre-compute the sin and cos values
float[] tabSin = new float[phiDim];
float[] tabCos = new float[phiDim];

HoughComparator compare;


class ImageProcessing extends PApplet {
  OpenCV opencv;
  PImage img;
  HScrollbar bar1 = new HScrollbar(0, 0, 640, 20);
  HScrollbar bar2 = new HScrollbar(0, 20, 640, 20);
  HScrollbar bar3 = new HScrollbar(0, 40, 640, 20);
  HScrollbar bar4 = new HScrollbar(0, 60, 640, 20);
  HScrollbar bar5 = new HScrollbar(0, 80, 640, 20);
  HScrollbar bar6 = new HScrollbar(0, 100, 640, 20);
  BlobDetection blob;
  QuadGraph graph;
  TwoDThreeD rotations;

  Capture cam;


  /*private static final int hMin = 80;
   private static final int hMax = 135;
   private static final int sMin = 100;
   private static final int sMax = 255;
   private static final int bMin = 0;
   private static final int bMax = 170;*/

  /*private static final int hMin = 100;
   private static final int hMax = 180;
   private static final int sMin = 50;
   private static final int sMax = 255;
   private static final int bMin = 0;
   private static final int bMax = 255;*/


  private static final int QUAD_BORDERS_NBR = 4;

  private static final double IMAGE_RESIZING_RATIO = 2.0/3;

  private static final int tbValue = 230;

  private static final String BOARD_TO_LOAD = "/Users/sachakozma/Documents/Dropbox/Documents/Ecole/EPFL/Semestre IV/Prog visuelle/visual/Tangible/game/data/board4.jpg";

  public float xRotation;
  public float yRotation;


  void settings() {
    size(640, 480);
    //img = loadImage(BOARD_TO_LOAD);
    //img.resize(640,480);
  }

  void setup() {
    String[] cameras = Capture.list();

    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, 640, 480);
    cam.start();

    rotations = new TwoDThreeD(width, height, 0);

    /*img.resize((int)(IMAGE_RESIZING_RATIO *img.width), (int)(IMAGE_RESIZING_RATIO *img.height));
     size(3 *img.width, img.height);*/

    opencv = new OpenCV(this, 100, 100);
    blob = new BlobDetection();
    graph = new QuadGraph();
    float inverseR = 1.f / discretizationStepsR;
    float ang = 0;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
  }

  void draw() {
    cam.read();
    img = cam.get();
    img.loadPixels();

    bar1.update(imgProcessing);
    bar2.update(imgProcessing);
    bar3.update(imgProcessing);
    bar4.update(imgProcessing);
    bar5.update(imgProcessing);
    bar6.update(imgProcessing);

    int hMin = (int)map(bar1.getPos(), 0, 1, 0, 255);
    int hMax = (int)map(bar2.getPos(), 0, 1, 0, 255);
    int sMin = (int)map(bar3.getPos(), 0, 1, 0, 255);
    int sMax = (int)map(bar4.getPos(), 0, 1, 0, 255);
    int bMin = (int)map(bar5.getPos(), 0, 1, 0, 255);
    int bMax = (int)map(bar6.getPos(), 0, 1, 0, 255);

    background(color(255));

    PImage img1 = thresholdHSB(img, hMin, hMax, sMin, sMax, bMin, bMax);
    img1.loadPixels();

    PImage img2 = blob.findConnectedComponents(img1, true);
    img2.loadPixels();

    PImage img3 = gaussian_kernel(img2);
    img3.loadPixels();

    PImage img4 = scharr(img3);
    img4.loadPixels();


    List<PVector> lines = hough(threshold_binary(img4, tbValue), QUAD_BORDERS_NBR);

    image(img4, 0, 0);
    //image(img2, img.width, 0);
    //image(img4, 2.0 *img.width, 0);

    drawLines(lines);

    stroke(244, 249, 102);
    fill(192, 9, 161);

    List<PVector> bestQuads = graph.findBestQuad(lines, img.width, img.height, img.width * img.height, (int)((1.0/5 * 1.0/4) * img.height * img.height), false);


    for (PVector vector : bestQuads) {
      vector.z = 1;
    }
    if (!bestQuads.isEmpty()) {
      PVector rotation = rotations.get3DRotations(bestQuads);
      println(rotation);
      float degree_rotation = (float)Math.toDegrees(rotation.x);
      if (degree_rotation > 300) {
       xRotation = rotation.x - 2*PI;
       } else if (degree_rotation < -300) {
       xRotation = rotation.x + 2*PI;
       } else {
       xRotation = rotation.x - PI;
       }
      //xRotation = my_game.clamp(rotation.x, -PI/3.0, PI/3.0);
      yRotation = my_game.clamp(rotation.y, -PI/3.0, PI/3.0);


      for (PVector vector : bestQuads) {
        ellipse(vector.x, vector.y, 10, 10);
      }
    }

    bar1.display(imgProcessing);
    bar2.display(imgProcessing);
    bar3.display(imgProcessing);
    bar4.display(imgProcessing);
    bar5.display(imgProcessing);
    bar6.display(imgProcessing);
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
}