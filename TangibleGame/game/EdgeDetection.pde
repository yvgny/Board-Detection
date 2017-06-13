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
      result.pixels[y * imgWidth + x]=color(166, val,71);
    }
  }

  result.updatePixels();
  return result;
}