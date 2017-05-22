import java.util.ArrayList; //<>//
import java.util.List;
import java.util.TreeSet;
import java.util.Collections;

class BlobDetection {
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
    PImage output = createImage(input.width, img.height, ALPHA);
    output.loadPixels();
    // First pass: label the pixels and store labels’ equivalences
    int [] labels = new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
    int currentLabel=1;
    int foundLabel = currentLabel;
    TreeSet<Integer> neighbours = new TreeSet<Integer>();

    for (int y = 0; y < input.height; y++) {
      for (int x = 0; x < input.width; x++) {
        if (input.pixels[x + y * input.width] == color(255)) {
          for (int l = max(0, y - 1); l <= y; l++) {

            for (int c = max(0, x - 1); c <= min(input.width - 1, x + 1); c++) {
              int neighbourLabel = labels[c + l * input.width];

              if (neighbourLabel != 0) {
                neighbours.add(neighbourLabel);
              }
              if (neighbourLabel > 0 && neighbourLabel < foundLabel) {
                foundLabel = neighbourLabel;
              }
            }
          }
          for (int lab : neighbours) {
            for (int lab2 : neighbours) {
              labelsEquivalences.get(lab - 1).addAll(labelsEquivalences.get(lab2 - 1));
            }
          }
          if (foundLabel == currentLabel) {
            labels[x + y *input.width] = currentLabel++;
            labelsEquivalences.add(new TreeSet(Collections.singletonList(foundLabel)));
          } else {
            labels[x + y *input.width] = foundLabel;
          }
          foundLabel = currentLabel;
          neighbours = new TreeSet<Integer>();
        }
      }
    }

    //Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    int[] blobSize = new int[labelsEquivalences.size()];
    for (int index = 0; index < input.height * input.width; index++) {
      if(labels[index] != 0) {
        int i = labelsEquivalences.get(labels[index] - 1).first();
        blobSize[i - 1]++;
        labels[index] = i;
      }
    }
    // Finally,
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
    if (onlyBiggest) {
      int max = 0;
      int index = 0;
      for (int i = 0 ; i < blobSize.length ; i++) {
        index = blobSize[i] > max ? i : index; 
        max = blobSize[i] > max ? blobSize[i] : max;
      }
      color randomColor = color(255);
      for (int pixel = 0; pixel < input.height * input.width; pixel++) {
        output.pixels[pixel] = labels[pixel] == index + 1 ? randomColor : color(0);
      }
    } else {
      color[] colors = new color[labelsEquivalences.size()];
      for (int i = 0; i < colors.length; i++) colors[i] = color(random(Byte.MAX_VALUE), random(Byte.MAX_VALUE), random(Byte.MAX_VALUE));
      for (int index = 0; index < input.height * input.width; index++) {
        output.pixels[index] = labels[index] != 0 ? colors[labels[index] - 1] : color(0);
      }
    }
    output.updatePixels();

    return output;
  }
}