int SCREEN_WIDTH = 640;
int SCREEN_HEIGHT = 640;

color mask = color(0, 0, 0);
color bg = color(99, 179, 255);

float diameter = min(SCREEN_WIDTH, SCREEN_HEIGHT) - 40;
float angle = 0;

Coaster coasterA, coasterB;

class Coaster {
  float diameter;
  float angle;
  float stroke_weight = 10;

  Coaster(float d) {
    this.diameter = d;
  }

  void draw_lines() {};

  void draw(float angle) {
    color(mask);
    strokeWeight(stroke_weight);
    rotate(angle);
    draw_lines();
    rotate(-angle);
  }
}

class LineCoaster extends Coaster {
  LineCoaster(float d) { super(d); }

  void draw_lines() {
    for (int x=-diameter/2; x <= diameter/2; x += stroke_weight * 2) {
      line(x, -diameter/2, x, diameter/2);
    }
  }
}

class HalvedCoaster extends Coaster {
  HalvedCoaster(float d) { super(d); }

  void draw_lines() {
    for (int x=-diameter/2; x <= diameter/2; x += stroke_weight * 2) {
      line(x, -diameter/2, x, x);
      line(x, x, -diameter/2, x);
    }
    
  }
}

class QuarteredCoaster extends Coaster {
  QuarteredCoaster(float d) { super(d); }

  void draw_lines() {
    float r = diameter / 2;
    for (int n=-r; n <= 0; n += stroke_weight * 2) {
      line(n, -r, n, n);
      line(n, n, -r, n);

      line(-n, -r, -n, n);
      line(-n, n, r, n);

      line(-r, -n, n, -n);
      line(n, -n, n, r);

      line(-n, r, -n, -n);
      line(-n, -n, r, -n);
    }
    
  }
}

class ZigZagCoaster extends Coaster {
  ZigZagCoaster(float d) { super(d); }

  void draw_lines() {
    int d = diameter / (2 * sqrt(2));
    float r = diameter / 2;

    for (int x=-r; x <= r; x += stroke_weight * 2) {
        //down from O
        line(x, -x, x, -x + d);
        // right from down
        line(x, -x + d, x + d, -x + d);
        // left from O
        line(x-d, -x, x, -x);
        // up from left
        line(x-d, -x-d, x-d, -x);
    }    
  }
}

class HoopyCoaster extends Coaster {
  HoopyCoaster(float d) { super(d); }

  void draw_lines() {
    noFill();
    for (int x=-diameter/2; x <= 0; x += stroke_weight * 2) {
      line(x, 0, x, diameter/2);
      line(-x, 0, -x, diameter/2);

      arc(0, 0, abs(x*2), abs(x*2), PI, TWO_PI);

    }
  }
}


void setup()
{
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
  frameRate(60);
  coasterA = new HoopyCoaster(diameter);
  coasterB = new ZigZagCoaster(diameter);
}

void draw()
{
  angle += 0.005 / TWO_PI;
  background(mask);
  fill(bg);
  // translate origin to the middle of the screen
  translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
  //draw the background
  ellipse(0, 0, diameter, diameter);
  //draw the coasters
  coasterA.draw(angle);
  coasterB.draw(-angle*exp(1)/2.0);
}
