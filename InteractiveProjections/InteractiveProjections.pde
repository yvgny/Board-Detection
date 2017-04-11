float rotateX = 0;
float rotateY = 0;
float scale = 1;

void settings() {
  size(1000, 1000, P2D);
}
void setup () {

}

void draw() {
  background(255, 255, 255);
  
  My3DPoint eye = new My3DPoint(-width/2, -height/2, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);

  
  
  //rotated around x
  float[][] transform1 = rotateXMatrix(rotateX);
  input3DBox = transformBox(input3DBox, transform1);
  
  float[][] transform2 = rotateYMatrix(rotateY);
  input3DBox = transformBox(input3DBox, transform2);
  
  float[][] transform3 = scaleMatrix(scale, scale, scale);
  input3DBox = transformBox(input3DBox, transform3);
  
  projectBox(eye, input3DBox).render();
}

void keyPressed() {
  switch (keyCode) {
    case UP: 
      rotateX -= PI/12; 
      break;
    case DOWN:
      rotateX += PI/12;
      break;
    case LEFT:
      rotateY += PI/12;
      break;
    case RIGHT:
      rotateY -= PI/12;
      break;
    default:
      break;
  }
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  return new My2DPoint((- eye.z * (p.x - eye.x)) / (p.z -eye.z), (- eye.z * (p.y - eye.y)) / (p.z -eye.z));
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }

  void render() {
    for (int i = 0; i < 4; i++) {
      line(s[i].x, s[i].y, s[(i + 1) % 4].x, s[(i + 1) % 4].y);
      line(s[i + 4].x, s[i + 4].y, s[((i + 1) % 4) + 4].x, s[((i + 1) % 4) + 4].y);
      line(s[i].x, s[i].y, s[i + 4].x, s[i + 4].y);
    }
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x, y+dimY, z+dimZ), 
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

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] points = new My2DPoint[box.p.length];

  for (int i = 0; i < points.length; i++) {
    points[i] = projectPoint(eye, box.p[i]);
  }

  return new My2DBox(points);
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}


float[][]  rotateXMatrix(float angle) {
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
    {cos(angle), sin(angle), 0, 0}, 
    {-sin(angle), cos(angle), 0, 0}, 
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

float[] matrixProduct(float[][] a, float[] b) { //Complete the code!
  int temp = 0;
  float[] product = new float[b.length];
  for (int y = 0; y < a.length; y++) {
    for (int x = 0; x < a[y].length; x++) {
      temp += a[y][x] * b[x];
    }
    product[y] = temp;
    temp = 0;
  }

  return product;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] points = new My3DPoint[box.p.length];

  for (int i = 0; i < box.p.length; i++) {
    points[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }

  return new My3DBox(points);
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}