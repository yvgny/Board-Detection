int MAXIMA_RADIUS = 10;

List<PVector> hough(PImage edgeImg, int nLines) {
  ArrayList<Integer> bestCandidates = new ArrayList<Integer> ();
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  int minVotes=20;

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
  int element;
  for (int phi = 0; phi < phiDim; phi++) {
    for (int r = 0; r < rDim; r++) {
      element = accumulator[phi * rDim + r];
      if (element > minVotes) {
        boolean best = true;
        for (int x = max(0, phi - MAXIMA_RADIUS); x < min(phi + MAXIMA_RADIUS, phiDim) && best; x++) {
          for (int y = max(0, r - MAXIMA_RADIUS); y < min(r + MAXIMA_RADIUS, rDim) && best; y++) {
            if (accumulator[x * rDim + y] > element) {
              best = false;
            }
          }
        }
        if (best) {
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