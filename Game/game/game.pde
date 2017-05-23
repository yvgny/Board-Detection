import java.util.Collections;
import java.math.BigDecimal;

float ry;
float rx;
float speed = 1;
float SCROLLBAR_WIDTH;
float SCROLLBAR_HEIGHT = 20;
float SCORE_BOARD_RECT_WIDTH = 5;
float SCORE_BOARD_RECT_HEIGHT = 10;
int WINDOW_HEIGHT = 1000;
int WINDOW_WIDTH = 1000;
int BOX_HEIGHT = 15;
int BOX_LENGTH = 400;
int BOX_WIDTH = BOX_LENGTH;
int BALL_SIZE = 12;
int CYLINDER_BASESIZE = 25;
int CYLINDER_HEIGHT = 50;
int SCORE_BAR_HEIGHT =  (int) (WINDOW_HEIGHT / 5.0);
int SCORE_BAR_BORDER = 16;
boolean SHIFTpressed = false;
Ball ball = new Ball(BALL_SIZE, 0, -BOX_HEIGHT/2, 0, BOX_LENGTH / 2, BOX_WIDTH / 2);
ArrayList<PVector> cylinders = new ArrayList();
ArrayList<Float> score;
Cylinder cylinder;
PGraphics bar_background;
PGraphics bar_topView;
PGraphics bar_scoreBoard;
PGraphics bar_scoreChart;
float currentTime;
float bufferScore;
float SCORE_UPDATE_PERIOD = 1000;
HScrollbar scrollbar;
PShape snowman;


void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT, P3D);
}

void setup() {
  currentTime = millis();
  ry = 0;
  rx = 0;
  bar_background = createGraphics(width, SCORE_BAR_HEIGHT, P2D);
  bar_topView = createGraphics(SCORE_BAR_HEIGHT - SCORE_BAR_BORDER, SCORE_BAR_HEIGHT - SCORE_BAR_BORDER, P2D);
  bar_scoreBoard = createGraphics((int)(SCORE_BAR_HEIGHT * 4.0 / 5.0 - SCORE_BAR_BORDER), SCORE_BAR_HEIGHT - SCORE_BAR_BORDER, P2D);
  SCROLLBAR_WIDTH = width - bar_topView.width - bar_scoreBoard.width - 2 * SCORE_BAR_BORDER;
  bar_scoreChart = createGraphics((int)SCROLLBAR_WIDTH, SCORE_BAR_HEIGHT - SCORE_BAR_BORDER - (int)SCROLLBAR_HEIGHT, P2D);
  scrollbar = new HScrollbar(
    3.0 / 2.0 * SCORE_BAR_BORDER + bar_topView.width + bar_scoreBoard.width, 
    height - SCORE_BAR_HEIGHT + SCORE_BAR_BORDER + bar_scoreChart.height, 
    SCROLLBAR_WIDTH, 
    SCORE_BAR_HEIGHT - bar_scoreChart.height - SCORE_BAR_BORDER * 3.0 / 2.0);
  score = new ArrayList();
  score.add(0.0);
  bufferScore = 0;
  snowman = loadShape("snowman.obj");
  snowman.scale(1.7);
  noStroke();
}

void draw() {
  background(255);

  if (SHIFTpressed) {
    cylinder = new Cylinder(CYLINDER_BASESIZE, CYLINDER_HEIGHT, true);
    stroke(230);
    pushMatrix();
    centerAxis();
    fill(102);
    box(BOX_LENGTH, BOX_WIDTH, BOX_HEIGHT);
    popMatrix();
    cylinder.rotate(0, 0, 0);
    stroke(255);

    //Ball
    pushMatrix();
    centerAxis();
    translate(ball.location.x, ball.location.z, -ball.location.y); 
    stroke(0);
    sphere(ball.size);
    popMatrix();


    //Cylinders
    if (!hasCorrectPosition(mouseX - width/2, mouseY - width /2)) {
      cylinder.openCylinder.setStroke(color(100, 40, 40));
      cylinder.cover.setStroke(color(100, 40, 40));
    }

    cylinder.draw(mouseX, mouseY, BOX_HEIGHT / 2);
    cylinder.openCylinder.setStroke(color(0));
    cylinder.cover.setStroke(color(0));

    for (PVector position : cylinders) {
      cylinder.draw(position.x + width/2, position.y + width/2, BOX_HEIGHT / 2);
    }
  } else {
    clearScoreBuffer();
    cylinder = new Cylinder(CYLINDER_BASESIZE, CYLINDER_HEIGHT, false);
    drawScore();
    image(bar_background, 0, height - SCORE_BAR_HEIGHT);
    image(bar_topView, SCORE_BAR_BORDER / 2, height - SCORE_BAR_HEIGHT + SCORE_BAR_BORDER / 2);
    image(bar_scoreBoard, SCORE_BAR_BORDER + bar_topView.width, height - SCORE_BAR_HEIGHT + SCORE_BAR_BORDER / 2);
    image(bar_scoreChart, 3.0 / 2.0 * SCORE_BAR_BORDER + bar_topView.width + bar_scoreBoard.width, height - SCORE_BAR_HEIGHT + SCORE_BAR_BORDER / 2);
    scrollbar.update();
    scrollbar.display();

    fill(255);
    noStroke();
    directionalLight(50, 100, 125, -1, 1, -1);
    ambientLight(102, 102, 102);

    centerAxis();
    rotateZ(rx);
    rotateX(ry);


    box(BOX_LENGTH, BOX_HEIGHT, BOX_WIDTH);

    cylinder.rotate(PI/2, 0, 0);
    for (PVector position : cylinders) {
      cylinder.draw(position.x, -BOX_HEIGHT / 2, position.y);
    }


    ball.render(-ry, rx);
  }
}

void drawScore() {
  bar_background.beginDraw();
  bar_background.background(230, 226, 175);
  bar_background.endDraw();

  bar_topView.beginDraw();
  bar_topView.background(6, 101, 130);
  bar_topView.fill(230, 226, 175);
  bar_topView.translate(bar_topView.width / 2, bar_topView.height / 2);
  bar_topView.noStroke();
  for (PVector cylinder : cylinders) {
    float posX = map(cylinder.x, -BOX_LENGTH / 2, BOX_LENGTH / 2, - bar_topView.width / 2, bar_topView.width/2);
    float posY = map(cylinder.y, -BOX_WIDTH / 2, BOX_WIDTH / 2, - bar_topView.height / 2, bar_topView.height/2);
    float radius = 23;
    bar_topView.ellipse(posX, posY, radius, radius);
  }
  float ballX = map(ball.location.x, -BOX_LENGTH / 2, BOX_LENGTH / 2, - bar_topView.width / 2, bar_topView.width/2);
  float ballY = map(ball.location.z, -BOX_WIDTH / 2, BOX_WIDTH / 2, - bar_topView.height / 2, bar_topView.height/2);
  bar_topView.fill(220, 0, 0);
  bar_topView.ellipse(ballX, ballY, 9, 9);
  bar_topView.endDraw();

  bar_scoreBoard.beginDraw();
  // Add border
  bar_scoreBoard.fill(230, 226, 175);
  bar_scoreBoard.stroke(250);
  bar_scoreBoard.strokeWeight(5);
  bar_scoreBoard.rect(0, 0, bar_scoreBoard.width, bar_scoreBoard.height);

  // Add texts
  int indexLastScore = score.size() < 2 ? 0 : score.size() - 2;
  bar_scoreBoard.fill(90, 90, 90);
  bar_scoreBoard.text("Total Score :\n" + score.get(score.size() - 1) + "\n\nVelocity :\n" + ball.getVelocity() + "\n\nLast Score :\n" + score.get(indexLastScore), SCORE_BAR_BORDER, SCORE_BAR_BORDER * 2);
  bar_scoreBoard.endDraw();

  bar_scoreChart.beginDraw();
  bar_scoreChart.background(239, 236, 202);
  float adjustedRectWidth = scrollbar.getPosMapped(1, 3) * SCORE_BOARD_RECT_WIDTH;
  int numberOfRect = (int)Math.ceil(bar_scoreChart.width / adjustedRectWidth);
  numberOfRect = numberOfRect > score.size() ? score.size() : numberOfRect;
  float x = bar_scoreChart.width;
  float rectHeight;
  for (int i = score.size() - 1; i >= score.size() - numberOfRect; i--) {
    bar_scoreChart.rectMode(CORNERS);
    rectHeight = score.get(i) == 0.0 ? 1 : map(score.get(i), 0, maxScoreFrom(score.size() - numberOfRect), 0, bar_scoreChart.height);
    bar_scoreChart.noStroke();
    for (int y = bar_scoreChart.height; y > bar_scoreChart.height - rectHeight + SCORE_BOARD_RECT_HEIGHT; y -= SCORE_BOARD_RECT_HEIGHT) {
      float adjustColor = map(y, 0, bar_scoreChart.height, 0, 70);
      bar_scoreChart.fill(6 + adjustColor, 101 + adjustColor, 130 + adjustColor);
      bar_scoreChart.rect(x, y, (x - adjustedRectWidth + 2), y - SCORE_BOARD_RECT_HEIGHT + 2);
    }
    x -= adjustedRectWidth;
  }
  bar_scoreChart.endDraw();
}

void mouseDragged() {
  if (mouseY > height - SCORE_BAR_HEIGHT || SHIFTpressed) {
    return;
  }

  ry -= (mouseY - pmouseY) / 300.0 * speed;
  ry = clamp(ry, -PI/3, PI/3);

  rx += (mouseX - pmouseX) / 300.0 * speed;
  rx = clamp(rx, -PI/3, PI/3);
}

float clamp(float num, float min, float max) {
  return num <= min ? min : num >= max ? max : num;
}

void mouseWheel(MouseEvent event) {
  if (SHIFTpressed) {
    return;
  }
  speed += event.getCount() * 1.0/700;
  speed = clamp(speed, 0.2, 1.5);
}

void keyPressed() {
  if (keyCode == SHIFT) 
    SHIFTpressed = true;
}

void keyReleased() {
  if (keyCode == SHIFT) 
    SHIFTpressed = false;
}

void mouseClicked() {
  if (SHIFTpressed && hasCorrectPosition(mouseX - width/2, mouseY - height/2)) {
    cylinders.add(new PVector(mouseX - width/2, mouseY - height/2));
  }
}

void centerAxis() {
  translate(width/2, height/2, 0);
}

boolean hasCorrectPosition(int x, int y) {
  if (x - CYLINDER_BASESIZE  < - BOX_WIDTH /2) {
    return false;
  } else if (x + CYLINDER_BASESIZE > BOX_WIDTH /2) {
    return false;
  } else if (y + CYLINDER_BASESIZE > BOX_LENGTH / 2) {
    return false;
  } else if (y - CYLINDER_BASESIZE < - BOX_LENGTH / 2) {
    return false;
  }

  PVector pos = new PVector(x, y);

  for (PVector cylPos : cylinders) {
    if (pos.dist(cylPos) <= CYLINDER_BASESIZE * 2) {
      return false;
    }
  }

  PVector ballPos = new PVector(ball.location.x, ball.location.z);

  if (pos.dist(ballPos) <= BALL_SIZE + CYLINDER_BASESIZE) {
    return false;
  }

  return true;
}

void clampScore() {
  if (score.get(score.size() - 1) < 0) {
    score.set(score.size() - 1, 0.0);
  }
}

float maxScoreFrom(int from) {
  return Collections.max(score.subList(from, score.size()));
}

void addScore(float difference) {
  float newScore = Math.round(bufferScore + difference);
  newScore = newScore < 0 ? 0 : newScore;
  bufferScore = newScore;
}

void clearScoreBuffer() {
  if ((millis() - currentTime) > SCORE_UPDATE_PERIOD) {
    currentTime = millis();
    score.add(bufferScore);
  }
}