import java.util.List;

import processing.core.PVector;
import org.opencv.core.Mat;
import org.opencv.core.CvType; 
import org.opencv.core.Core;

class TwoDThreeD {

  // default focal length, well suited for most webcams
  float f = 700;

  // intrisic camera matrix
  float [][] K = {{f, 0, 0}, 
    {0, f, 0}, 
    {0, 0, 1}};
  float [][] invK;
  PVector invK_r1, invK_r2, invK_r3;
  Mat opencv_A, w, u, vt;
  double [][] V;

  // Real physical coordinates of the Lego board in mm
  //float boardSize = 380.f; // large Duplo board
  // float boardSize = 255.f; // smaller Lego board

  // the 3D coordinates of the physical board corners, clockwise
  float [][] physicalCorners = {
    {-128, 128, 0, 1}, 
    {128, 128, 0, 1}, 
    {128, -128, 0, 1}, 
    {-128, -128, 0, 1}
  };

  //Filtering variables: low-pass filter based on arFilterTrans from ARToolKit v5 */
  float[] q;
  float sampleRate;
  float cutOffFreq;
  float alpha;


  public TwoDThreeD(int width, int height, int sampleRate) {

    // set the offset to the center of the webcam image
    K[0][2] = 0.5f * width;
    K[1][2] = 0.5f * height;
    //compute inverse of K
    Mat opencv_K= new Mat(3, 3, CvType.CV_32F);
    opencv_K.put(0, 0, K[0][0]);
    opencv_K.put(0, 1, K[0][1]);
    opencv_K.put(0, 2, K[0][2]);
    opencv_K.put(1, 0, K[1][0]);
    opencv_K.put(1, 1, K[1][1]);
    opencv_K.put(1, 2, K[1][2]);
    opencv_K.put(2, 0, K[2][0]);
    opencv_K.put(2, 1, K[2][1]);
    opencv_K.put(2, 2, K[2][2]);
    Mat opencv_invK=opencv_K.inv();

    invK = new float[][]{
      { (float)opencv_invK.get(0, 0)[0], (float)opencv_invK.get(0, 1)[0], (float)opencv_invK.get(0, 2)[0] }, 
      { (float)opencv_invK.get(1, 0)[0], (float)opencv_invK.get(1, 1)[0], (float)opencv_invK.get(1, 2)[0] }, 
      { (float)opencv_invK.get(2, 0)[0], (float)opencv_invK.get(2, 1)[0], (float)opencv_invK.get(2, 2)[0] }};
    invK_r1=new PVector(invK[0][0], invK[0][1], invK[0][2]);
    invK_r2=new PVector(invK[1][0], invK[1][1], invK[1][2]);
    invK_r3=new PVector(invK[2][0], invK[2][1], invK[2][2]);

    opencv_A=new Mat(12, 9, CvType.CV_32F);
    w=new Mat();
    u=new Mat();
    vt=new Mat();
    V= new double[9][9];

    q=new float[4];
    q[3]=1;

    this.sampleRate=sampleRate;
    if (sampleRate>0) {
      cutOffFreq=sampleRate/2;
      alpha= (1/sampleRate)/(1/sampleRate + 1/cutOffFreq);
    }
  }

  PVector get3DRotations(List<PVector> points2D) {

    // 1- Solve the extrinsic matrix from the projected 2D points
    double[][] E = solveExtrinsicMatrix(points2D);


    // 2 - Re-build a proper 3x3 rotation matrix from the camera's 
    //     extrinsic matrix E
    PVector firstColumn=new PVector((float)E[0][0], (float)E[1][0], (float)E[2][0]);
    PVector secondColumn=new PVector((float)E[0][1], (float)E[1][1], (float)E[2][1]);
    firstColumn.normalize();
    secondColumn.normalize();
    PVector thirdColumn=firstColumn.cross(secondColumn);
    float [][] rotationMatrix={{firstColumn.x, secondColumn.x, thirdColumn.x}, 
      {firstColumn.y, secondColumn.y, thirdColumn.y}, 
      {firstColumn.z, secondColumn.z, thirdColumn.z}};

    if (sampleRate>0)
      filter(rotationMatrix, false);

    // 3 - Computes and returns Euler angles (rx, ry, rz) from this matrix
    return rotationFromMatrix(rotationMatrix);
  }


  double[][] solveExtrinsicMatrix(List<PVector> points2D) {

    // p ~= K · [R|t] · P
    // with P the (3D) corners of the physical board, p the (2D) 
    // projected points onto the webcam image, K the intrinsic 
    // matrix and R and t the rotation and translation we want to 
    // compute.
    //
    // => We want to solve: (K^(-1) · p) X ([R|t] · P) = 0

    float[][] projectedCorners = new float[4][3];

    for (int i=0; i<4; i++) {
      // TODO:
      // store in projectedCorners the result of (K^(-1) · p), for each 
      // corner p found in the webcam image.
      // You can use PVector dot function for computing dot product between K^(-1) lines and p.
      //Do not forget to normalize the result
      PVector point =points2D.get(i);
      projectedCorners[i][0]=point.dot(invK_r1)/point.dot(invK_r3);
      projectedCorners[i][1]=point.dot(invK_r2)/point.dot(invK_r3);
      projectedCorners[i][2]=1;
    }

    // 'A' contains the cross-product (K^(-1) · p) X P
    float[][] A= new float[12][9];

    for (int i=0; i<4; i++) {
      A[i*3][0]=0;
      A[i*3][1]=0;
      A[i*3][2]=0;

      // note that we take physicalCorners[0,1,*3*]: we drop the Z
      // coordinate and use the 2D homogenous coordinates of the physical
      // corners
      A[i*3][3]=-projectedCorners[i][2] * physicalCorners[i][0];
      A[i*3][4]=-projectedCorners[i][2] * physicalCorners[i][1];
      A[i*3][5]=-projectedCorners[i][2] * physicalCorners[i][3];

      A[i*3][6]= projectedCorners[i][1] * physicalCorners[i][0];
      A[i*3][7]= projectedCorners[i][1] * physicalCorners[i][1];
      A[i*3][8]= projectedCorners[i][1] * physicalCorners[i][3];

      A[i*3+1][0]= projectedCorners[i][2] * physicalCorners[i][0];
      A[i*3+1][1]= projectedCorners[i][2] * physicalCorners[i][1];
      A[i*3+1][2]= projectedCorners[i][2] * physicalCorners[i][3];

      A[i*3+1][3]=0;
      A[i*3+1][4]=0;
      A[i*3+1][5]=0;

      A[i*3+1][6]=-projectedCorners[i][0] * physicalCorners[i][0];
      A[i*3+1][7]=-projectedCorners[i][0] * physicalCorners[i][1];
      A[i*3+1][8]=-projectedCorners[i][0] * physicalCorners[i][3];

      A[i*3+2][0]=-projectedCorners[i][1] * physicalCorners[i][0];
      A[i*3+2][1]=-projectedCorners[i][1] * physicalCorners[i][1];
      A[i*3+2][2]=-projectedCorners[i][1] * physicalCorners[i][3];

      A[i*3+2][3]= projectedCorners[i][0] * physicalCorners[i][0];
      A[i*3+2][4]= projectedCorners[i][0] * physicalCorners[i][1];
      A[i*3+2][5]= projectedCorners[i][0] * physicalCorners[i][3];

      A[i*3+2][6]=0;
      A[i*3+2][7]=0;
      A[i*3+2][8]=0;
    }

    for (int i=0; i<12; i++)
      for (int j=0; j<9; j++)
        opencv_A.put(i, j, A[i][j]);

    Core.SVDecomp(opencv_A, w, u, vt);

    for (int i=0; i<9; i++)
      for (int j=0; j<9; j++)
        V[j][i]=vt.get(i, j)[0];

    double[][] E = new double[3][3];

    //E is the last column of V
    for (int i=0; i<9; i++) {
      E[i/3][i%3] = V[i][V.length-1] / V[8][V.length-1];
    }

    return E;
  }

  PVector rotationFromMatrix(float[][]  mat) {

    // Assuming rotation order is around x,y,z
    PVector rot = new PVector();

    if (mat[1][0] > 0.998) { // singularity at north pole
      rot.z = 0;
      float delta = (float) Math.atan2(mat[0][1], mat[0][2]);
      rot.y = -(float) Math.PI/2;
      rot.x = -rot.z + delta;
      return rot;
    }

    if (mat[1][0] < -0.998) { // singularity at south pole
      rot.z = 0;
      float delta = (float) Math.atan2(mat[0][1], mat[0][2]);
      rot.y = (float) Math.PI/2;
      rot.x = rot.z + delta;
      return rot;
    }

    rot.y =-(float)Math.asin(mat[2][0]);
    rot.x = (float)Math.atan2(mat[2][1]/Math.cos(rot.y), mat[2][2]/Math.cos(rot.y));
    rot.z = (float)Math.atan2(mat[1][0]/Math.cos(rot.y), mat[0][0]/Math.cos(rot.y));

    return rot;
  }

  int filter(float m[][], boolean reset) {

    float[] q= new float[4];
    float alpha, oneminusalpha, omega, cosomega, sinomega, s0, s1;

    mat2Quat(m, q);
    if (nomalizeQuaternion(q)<0) return -1;

    if (reset) {  
      this.q[0] = q[0];
      this.q[1] = q[1];
      this.q[2] = q[2];
      this.q[3] = q[3];
    } else {
      alpha = this.alpha;

      oneminusalpha = 1.0 - alpha;

      // SLERP for orientation.
      cosomega = q[0]*this.q[0] + q[1]*this.q[1] + q[2]*this.q[2] + q[3]*this.q[3]; // cos of angle between vectors.
      if (cosomega < 0.0) {
        cosomega = -cosomega;
        q[0] = -q[0];
        q[1] = -q[1];
        q[2] = -q[2];
        q[3] = -q[3];
      } 
      if (cosomega > 0.9995) {
        s0 = oneminusalpha;
        s1 = alpha;
      } else {
        omega = acos(cosomega);
        sinomega = sin(omega);
        s0 = sin(oneminusalpha * omega) / sinomega;
        s1 = sin(alpha * omega) / sinomega;
      }
      this.q[0] = q[0]*s1 + this.q[0]*s0;
      this.q[1] = q[1]*s1 + this.q[1]*s0;
      this.q[2] = q[2]*s1 + this.q[2]*s0;
      this.q[3] = q[3]*s1 + this.q[3]*s0;
      nomalizeQuaternion(this.q);
    }

    if (quat2Mat(this.q, m) < 0) return (-2);

    return (0);
  }


  int nomalizeQuaternion(float[] q) {// Normalise quaternion.
    float mag2 = q[0]*q[0] + q[1]*q[1] + q[2]*q[2] + q[3]*q[3];
    if (mag2==0) return (-1);

    float mag = sqrt(mag2);

    q[0] /= mag;
    q[1] /= mag;
    q[2] /= mag;
    q[3] /= mag;

    return (0);
  }

  int mat2Quat(float m[][], float q[]) {
    float t, s;
    t = m[0][0] + m[1][1] + m[2][2] + 1.0;
    if (t > 0.0001) {
      s = sqrt(t) * 2.0;
      q[0] = (m[1][2] - m[2][1]) / s;
      q[1] = (m[2][0] - m[0][2]) / s;
      q[2] = (m[0][1] - m[1][0]) / s;
      q[3] = 0.25 * s;
    } else {
      if (m[0][0] > m[1][1] && m[0][0] > m[2][2]) {  // Column 0:
        s  = sqrt(1.0 + m[0][0] - m[1][1] - m[2][2]) * 2.0;
        q[0] = 0.25 * s;
        q[1] = (m[0][1] + m[1][0] ) / s;
        q[2] = (m[2][0] + m[0][2] ) / s;
        q[3] = (m[1][2] - m[2][1] ) / s;
      } else if (m[1][1] > m[2][2]) {      // Column 1:
        s  = sqrt(1.0 + m[1][1] - m[0][0] - m[2][2]) * 2.0;
        q[0] = (m[0][1] + m[1][0] ) / s;
        q[1] = 0.25 * s;
        q[2] = (m[1][2] + m[2][1] ) / s;
        q[3] = (m[2][0] - m[0][2] ) / s;
      } else {            // Column 2:
        s  = sqrt(1.0 + m[2][2] - m[0][0] - m[1][1]) * 2.0;
        q[0] = (m[2][0] + m[0][2] ) / s;
        q[1] = (m[1][2] + m[2][1] ) / s;
        q[2] = 0.25 * s;
        q[3] = (m[0][1] - m[1][0] ) / s;
      }
    }
    return 0;
  }

  int quat2Mat( float q[], float m[][] )
  {
    float    x2, y2, z2;
    float    xx, xy, xz;
    float    yy, yz, zz;
    float    wx, wy, wz;

    x2 = q[0] * 2.0;
    y2 = q[1] * 2.0;
    z2 = q[2] * 2.0;

    xx = q[0] * x2;
    xy = q[0] * y2;
    xz = q[0] * z2;
    yy = q[1] * y2;
    yz = q[1] * z2;
    zz = q[2] * z2;
    wx = q[3] * x2;
    wy = q[3] * y2;
    wz = q[3] * z2;

    m[0][0] = 1.0 - (yy + zz);
    m[1][1] = 1.0 - (xx + zz);
    m[2][2] = 1.0 - (xx + yy);

    m[1][0] = xy - wz;
    m[0][1] = xy + wz;
    m[2][0] = xz + wy;
    m[0][2] = xz - wy;
    m[2][1] = yz - wx;
    m[1][2] = yz + wx;

    return 0;
  }
}