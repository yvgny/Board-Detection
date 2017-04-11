void settings() {
  size(1000, 1000, P2D);
}

void setup () {
}

void draw() {
  background(255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}


My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  return new My2DPoint(((p.x - eye.x) * (-eye.z) / (p.z - eye.z)), ((p.y - eye.y) * (-eye.z) / (p.z - eye.z)));
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] points = new My2DPoint[8];
  for (int i = 0; i < points.length; i++) {
    points[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(points);
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] points = new My3DPoint[8];
  for (int i = 0; i < box.p.length; i++) {
    points[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(points);
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] matrix = new float[b.length];
  for (int i = 0; i < a.length; i++) {
    for (int j = 0; j < a[0].length; j++) {
      matrix[i] += a[i][j] * b[j];
    }
  }
  return matrix;
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {
    {1, 0, 0, 0}, 
    {0, cos(angle), sin(angle), 0}, 
    {0, -sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}

float[][] rotateYMatrix(float angle) {
  return(new float[][] {
    {cos(angle), 0, -sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}

float[][] rotateZMatrix(float angle) {
  return(new float[][] {
    {cos(angle), -sin(angle), 0, 0}, 
    {sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}

float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {
    {x, 0, 0, 0}, 
    {0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}

float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {
    {1, 0, 0, x}, 
    {0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }

  void render() {
    //Front face
    drawLine(s[0], s[1]); 
    drawLine(s[1], s[2]); 
    drawLine(s[2], s[3]); 
    drawLine(s[3], s[0]);
    //Connecting the 2 faces
    drawLine(s[0], s[4]); 
    drawLine(s[1], s[5]); 
    drawLine(s[2], s[6]); 
    drawLine(s[3], s[7]);
    //Back face
    drawLine(s[4], s[5]); 
    drawLine(s[5], s[6]); 
    drawLine(s[6], s[7]); 
    drawLine(s[7], s[4]);
  }

  void drawLine(My2DPoint p1, My2DPoint p2) {
    line(p1.x, p1.y, p2.x, p2.y);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{
      new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }

  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

class My2DPoint {
  float x, y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x, y, z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}