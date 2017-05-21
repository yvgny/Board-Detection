import processing.video.*; //<>// //<>// //<>// //<>//
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
int neighbours_radius = 5;
int counter = 0;

void settings(){
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

  PImage img1 = thresholdHSB(img, (int)map(thresholdBar1.getPos(), 0, 1, 0, 255), (int)map(thresholdBar2.getPos(), 0, 1, 0, 255), 
    (int)map(thresholdBar3.getPos(), 0, 1, 0, 255), (int)map(thresholdBar4.getPos(), 0, 1, 0, 255), 
    (int)map(thresholdBar5.getPos(), 0, 1, 0, 255), (int)map(thresholdBar6.getPos(), 0, 1, 0, 255));

  // PImage img1 = thresholdHSB(img, 80, 160, 140, 255, 0, 130);
  image(img, 0, 0);

  PImage img2 = blob.findConnectedComponents(img1, true);

  PImage img3 = gaussian_kernel(img2);
  //image(img2, 800, 0);


  //image(img3, 0, 600);

  PImage img4 = threshold_binary(scharr(img3), 230);
  image(img2, 800, 0);

  List<PVector> lines = hough(img4, 20);
  stroke(204, 102, 0);
  /*
  for (PVector vector : graph.findBestQuad(lines, width, height, width * height, 0, false)) {
    ellipse(vector.x, vector.y, 3, 3);
  }
  */
  drawLines(lines);

  //image(blob.findConnectedComponents(img4,true), 800, 600);

  thresholdBar1.display();
  thresholdBar2.display();

  thresholdBar3.display();
  thresholdBar4.display();
  thresholdBar5.display();
  thresholdBar6.display();
}

/*
void draw() {
 image(hough_test, 0, 0);
 drawLines(hough(hough_test));
 }
 */
PImage scharr(PImage img) {
  float[][] vKernel = {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 } };
  float[][] hKernel = {
    { 3, 10, 3 }, 
    { 0, 0, 0 }, 
    { -3, -10, -3 } };
  int imgWidth = img.width;
  int imgHeight = img.height;
  PImage result = createImage(imgWidth, imgHeight, ALPHA);
  result.loadPixels();
  for (int i = 0; i < imgWidth * imgHeight; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[imgWidth * imgHeight];
  for (int y = 1; y < imgHeight - 1; y++) {
    for (int x = 1; x < imgWidth - 1; x++) {
      float sum_v = 0;
      float sum_h = 0;
      for (int l = -1; l <= 1; l++) {
        for (int c = -1; c <= 1; c++) {
          sum_v += vKernel[l + 1][c + 1] * brightness(img.pixels[(y + c)*imgWidth + (x + l)]);
          sum_h += hKernel[l + 1][c + 1] * brightness(img.pixels[(y + c)*imgWidth + (x + l)]);
        }
      }
      buffer[y * imgWidth + x] = sqrt(sum_h * sum_h + sum_v * sum_v);
      max = max(max, buffer[y * imgWidth + x]);
    }
  }
  for (int y = 2; y < imgHeight - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < imgWidth - 2; x++) { // Skip left and right
      int val=(int) ((buffer[y * imgWidth + x] / max)*255);
      result.pixels[y * imgWidth + x]=color(val);
    }
  }

  result.updatePixels();
  return result;
}

PImage gaussian_kernel(PImage img) {
  float[][] kernel = {
    { 9, 12, 9 }, 
    { 12, 15, 12 }, 
    { 9, 12, 9 }};
  float normFactor = 99.f;
  return convolute(img, kernel, normFactor);
}

PImage kernel1(PImage img) {
  float[][] kernel = {
    { 0, 0, 0 }, 
    { 0, 2, 0 }, 
    { 0, 0, 0 }};
  float normFactor = 1.f;
  return convolute(img, kernel, normFactor);
}

PImage kernel2(PImage img) {
  float[][] kernel = {
    { 0, 1, 0 }, 
    { 1, 0, 1 }, 
    { 0, 1, 0 }};
  float normFactor = 1.f;
  return convolute(img, kernel, normFactor);
}

PImage convolute(PImage img, float[][] kernel, float normFactor) {
  int imgWidth = img.width;
  int imgHeight = img.height;
  PImage result = createImage(imgWidth, imgHeight, ALPHA);
  for (int x = 1; x < imgWidth - 1; x++) {
    for (int y = 1; y < imgHeight - 1; y++) {
      int totalColor = 0;
      for (int l = -1; l <= 1; l++) {
        for (int c = -1; c <= 1; c++) {
          totalColor += (int)kernel[l + 1][c + 1] * brightness(img.pixels[(y + c)*imgWidth + (x + l)]);
        }
      }
      result.pixels[y * imgWidth + x] = color(totalColor / normFactor);
    }
  }
  result.updatePixels();
  return result;
}

PImage swaggish(PImage img) {
  float[][] kernel = {
    { 9, 12, 9 }, 
    { 12, 15, 12 }, 
    { 9, 12, 9 }};
  float normFactor = 1.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      float totalColor = 0;
      for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
          if (isValid(i + x, j + y, img.width, img.height)) {
            totalColor += kernel[x+1][y+1] * img.pixels[(j + y)*img.width + i + x];
          }
        }
      }
      result.pixels[j*img.width + i] = (int)totalColor / 9;
    }
  }
  println("out");
  return result;
}

boolean isValid(int x, int y, int imgWidth, int imgHeight) {
  return x >= 0 && x < imgWidth && y >= 0 && y < imgHeight;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    if (red(img1.pixels[i]) != red(img2.pixels[i]))
      return false;
  return true;
}

PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    int pixel = img.pixels[i];
    result.pixels[i] =
      hue(pixel) >= minH && hue(pixel) <= maxH &&
      saturation(pixel) >= minS && saturation(pixel) <= maxS &&
      brightness(pixel) >= minB && brightness(pixel) <= maxB ? color(255) : color(0);
  }
  result.updatePixels();
  return result;
}

PImage range(PImage img, int thresholdMin, int thresholdMax) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = hue(img.pixels[i]) >= Math.min(thresholdMin, thresholdMax) && hue(img.pixels[i]) <= Math.max(thresholdMin, thresholdMax) ? img.pixels[i] : color(0);
  }
  img.updatePixels();
  return result;
}

PImage hue(PImage img) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(hue(img.pixels[i]));
  }
  img.updatePixels();
  return result;
}

PImage threshold_binary(PImage img, int threshold) {
  return threshold(img, threshold, color(0), color(255));
}

PImage threshold_binary_inverted(PImage img, int threshold) {
  return threshold(img, threshold, color(255), color(0));
}

PImage threshold(PImage img, int threshold, color under, color above) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = brightness(img.pixels[i]) <= threshold ? under : above;
  }
  img.updatePixels();
  return result;
}

List<PVector> hough(PImage edgeImg, int nLines) {
  ArrayList<Integer> bestCandidates = new ArrayList<Integer> ();
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 0.3f;
  int minVotes=15;

  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi +1);

  //The max radius is the image diagonal, but it can be also negative 
  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width + edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1); 

  // our accumulator
  int[] accumulator = new int[phiDim * rDim];

  // Fill the accumulator: on edge points (ie, white pixels of the edge 
  // image), store all possible (r, phi) pairs describing lines going 
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        float r;
        for (int phi = 0; phi < phiDim; phi++) {
          r = x * cos(phi * discretizationStepsPhi) + y * sin(phi * discretizationStepsPhi);
          r = (r / discretizationStepsR);
          r += rDim / 2;
          accumulator[(int)(phi * rDim + r)] += 1;
        }
      }
    }
  }

  ArrayList<PVector> lines=new ArrayList<PVector>();
  /*
  for (int bc = 0; bc < accumulator.length; bc++) {
    if (accumulator[bc] > minVotes) {
      boolean best = true;
      for (int x = -neighbours_radius; x <= neighbours_radius; x++) {
        for (int y = -neighbours_radius; y <= neighbours_radius; y++) {
          int x_clamped = max(0, min(rDim, (bc % rDim) + x));
          int y_clamped = max(0, min(phiDim, (bc / rDim) + x));
          if (y_clamped * rDim + x_clamped != bc && accumulator[y_clamped * rDim + x_clamped] >= accumulator[bc]) {
            best = false;
          }
        }
      }
      if (best) {
        bestCandidates.add(bc);
      }
    }
  }
  */
  int element;
  for (int phi = 0; phi < phiDim; phi++) {
    for (int r = 0; r < rDim; r++) {
      element = accumulator[phi * rDim + r];
      if (element > minVotes) {
        boolean best = true;
        for (int x = max(0, phi - 5); x < min(phi + 5, phiDim); x++) {
          for (int y = max(0, r - 5); y < min(r + 5, rDim); y++) {
            if (accumulator[x * rDim + y] > element) {
                best = false;
            }
          }
        }
        if (best){
          bestCandidates.add(phi * rDim + r);
        }
      }
    }
  }

  compare = new HoughComparator(accumulator);
  bestCandidates.sort(compare);
  for (int i = 0; i < min(nLines, bestCandidates.size()); i++) {
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (bestCandidates.get(i) / (rDim)); 
    int accR = bestCandidates.get(i) - (accPhi) * (rDim); 
    float r = (accR - (rDim) * 0.5f) * discretizationStepsR; 
    float phi = accPhi * discretizationStepsPhi;
    lines.add(new PVector(r, phi));
  }
  houghImg = createImage(rDim, phiDim, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(400, 400);
  houghImg.updatePixels();
  return lines;
}

double getPhi (int x, int y) {
  return 2 * Math.atan((double) y / (x + getR(x, y))) + PI;
}

double getR (int x, int y) {
  return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
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