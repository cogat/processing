int SCREEN_WIDTH = 640;
int SCREEN_HEIGHT = 1000;

float speed = - SCREEN_WIDTH / 64;

int skyr = 99;
int skyg = 179;
int skyb = 255;

Section sectionA;
Section sectionB;

class Cable {
  float x1, y1, x2, y2, droop, colour, line_width;
  float cp_x_ratio = 0.25;

  Cable(x1, x2, variance, line_width) {
    this.x1 = x1;
    this.x2 = x2;
    this.line_width = line_width;

    // find points of disappearing at or above the screen
    y1 = -line_width - random(0, variance);
    y2 = -line_width - random(0, variance);

    droop = random(0, SCREEN_HEIGHT * 1.1);
    colour = random(0.0, 0.24); //0.14
    opacity = random(185, 255);
    // colour = 0;
  }

  void draw(x_offset) {
    float cp_x_diff = (x2 - x1) * cp_x_ratio;
    float cp_y = max(y1, y2) + droop;

    stroke(colour * skyr, colour * skyg, colour * skyb, opacity);
    strokeWeight(line_width);

    bezier(
      x1 + x_offset, y1,
      x1 + x_offset + cp_x_diff, cp_y,
      x2 + x_offset - cp_x_diff, cp_y,
      x2 + x_offset, y2
    );

  }
}

class Section {
  int num_cables;
  float variance;
  Cable[] cables;
  float length;
  float left = 0.6;

  Section(length) {
    this.length = length;
    num_cables = int(abs(gRand(10,14)));
    println(num_cables);

    variance = random(0, SCREEN_HEIGHT / 3);

    cables = new Cable[num_cables];
    for (int i = 0; i < cables.length; i++) {
      float line_width = abs(gRandSkew(200.0/num_cables, 300.0/num_cables, 800.0/num_cables));
      cables[i] = new Cable(0, length, variance, line_width);
    }
  }

  float gRand(low, high) {
    // return a gaussian random with a mean halfway between low and high, and with low and high being 
    // 1 SD away from mean.
    float mean = (high + low)/2.0;
    float sd = high - mean;
    return mean + sd * randomGaussian();
  }

  float gRandSkew(low, mean, high) {
    // return a skewed gaussian, by specifying mean and SD in each direction of the mean
    float g = randomGaussian();
    float sd;
    if (g >= 0) {
      sd = high - mean;
    } else {
      sd = mean - low;
    }
    return mean + sd * g;

  }

  float right() {
    return this.length + this.left;
  }

  void draw() {
    for (int i = 0; i < cables.length; i++) {
      cables[i].draw(this.left);
    }
  }
}

float random_length() {
  // return 640 * 20;
  // return 640 * 75;
  return random(640 * 20, 640 * 75);
}

void setup() 
{
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
  frameRate(60);
  noFill();
  
  // start some sections at the right edge of the screen
  sectionA = new Section(random_length());
  sectionA.left = SCREEN_WIDTH;
  sectionB = new Section(random_length());
  sectionB.left = sectionA.left + sectionA.length;
}

void draw() 
{
  background(skyr, skyg, skyb);

  sectionA.left += speed;
  sectionB.left += speed;

  sectionA.draw();
  sectionB.draw();

  // if a section has moved entirely off the screen, delete it and create a new one
  if (sectionA.right() < 0) {
    sectionA = sectionB;
    sectionB = new Section(random_length());
    sectionB.left = sectionA.left + sectionA.length;
  }
}