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