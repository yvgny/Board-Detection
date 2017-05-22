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