class Ball {
  PVector location, velocity, gravity, friction;
  float gravityConstant, normalForce, mu, frictionMagnitude, size;
  float maxX, minX, maxZ, minZ;

  Ball(float size, float initialPosX, float initialPosY, float initialPosZ, float xBoundary, float zBoundary) {
    this.size = size;
    location = new PVector(initialPosX, initialPosY - size, initialPosZ);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, 0, 0);
    friction = new PVector(0, 0, 0);
    gravityConstant = 0.12;
    normalForce = 1;  
    mu = 0.03;
    maxX = xBoundary;
    minX = -maxX;
    maxZ = zBoundary;
    minZ = -maxZ;
  }

  void update (float rotX, float rotZ) {
    frictionMagnitude = normalForce * mu;
    friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    gravity.x = sin(rotZ) * gravityConstant;
    gravity.z = sin(rotX) * gravityConstant;
    velocity.add(gravity);
    velocity.add(friction);
    location.add(velocity);
  }

  void display() {
    my_game.translate(location.x, location.y, location.z);
    my_game.sphere(size);
  }

  void checkEdges() {
    boolean hit = false;
    if (location.x + size > maxX) {
      hit = true;
      velocity.set(-velocity.x, velocity.y, velocity.z);
      location.x = maxX - size;
    } else if (location.x - size < minX) {
      hit = true;
      velocity.set(-velocity.x, velocity.y, velocity.z);
      location.x = minX + size;
    }

    if (location.z + size > maxZ) {
      hit = true;
      velocity.set(velocity.x, velocity.y, -velocity.z);
      location.z = maxZ - size;
    } else if (location.z - size < minZ) {
      hit = true;
      velocity.set(velocity.x, velocity.y, -velocity.z);
      location.z = minZ + size;
    }

    if (hit) {
      addScore(-getVelocity());
    }
  }

  void checkCylinderCollisions() {
    for (PVector cylPos : cylinders) {
      PVector adjustedCylPos = new PVector(cylPos.x, location.y, cylPos.y);
      float distance = location.dist(adjustedCylPos);
      if (distance <= CYLINDER_BASESIZE + BALL_SIZE) {
        addScore(getVelocity());
        PVector normal = location.copy().sub(adjustedCylPos).normalize();
        velocity.sub(normal.copy().mult(2 * velocity.dot(normal)));
        location = adjustedCylPos.copy().add(normal.copy().mult(CYLINDER_BASESIZE + BALL_SIZE));
      }
    }
  }

  void render(float rotX, float rotZ) {
    my_game.pushMatrix();
    update(rotX, rotZ);
    checkEdges();
    checkCylinderCollisions();
    display();
    my_game.popMatrix();
  }

  float getVelocity() {
    return round (velocity.mag(), 3);
  }

  float round(float d, int decimalPlace) {
    BigDecimal bd = new BigDecimal(Float.toString(d));
    bd = bd.setScale(decimalPlace, BigDecimal.ROUND_DOWN);
    return bd.floatValue();
  }
}