class Cylinder {
  float cylinderBaseSize, cylinderHeight;
  int cylinderResolution;
  PShape openCylinder = new PShape();
  PShape cover = new PShape();
  PShape mushroom;
  PImage texture;
  float rotateX, rotateY, rotateZ, angle;
  float[] x, y;

  Cylinder(float baseSize, float cylinderHeight, boolean withStroke) {
    cylinderBaseSize = baseSize;
    this.cylinderHeight = cylinderHeight;
    cylinderResolution = 40;
    rotateX = 0; 
    rotateY = 0; 
    rotateZ = 0;

    x = new float[cylinderResolution + 1];
    y = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    if (withStroke) {
      openCylinder.stroke(0);
    } else {
      openCylinder.noStroke();
    }
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    openCylinder.endShape();

    cover = createShape();
    cover.beginShape(TRIANGLE_FAN);
    cover.vertex(0, 0, 0);
    for (int i = 0; i < x.length; i++) {
      cover.vertex(x[i], y[i], 0);
    }
    cover.endShape();
  }

  void draw (float x, float y, float z) {
    pushMatrix();
    translate(x, y, z);
    rotateX(rotateX);
    rotateY(rotateY);
    rotateZ(rotateZ);
    shape(openCylinder);
    shape(cover);
    translate(0, 0, cylinderHeight);
    shape(cover);
    popMatrix();
  }

  void rotate(float rotateX, float rotateY, float rotateZ) {
    this.rotateX = rotateX;
    this.rotateY = rotateY;
    this.rotateZ = rotateZ;
  }
}