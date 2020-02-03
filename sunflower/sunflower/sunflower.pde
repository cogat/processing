int SCREEN_WIDTH = 640;
int SCREEN_HEIGHT = 640;

float radius = (min(SCREEN_HEIGHT, SCREEN_WIDTH) - 10) / 2;

float PHI = (sqrt(5)+1)/2;

color bg = color(0, 0, 0);
color fg = color(99, 179, 255);

float rotate_angle = 0;
int t = 0;

void setup()
{
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
  frameRate(60);
  ellipseMode(CENTER);
}

void draw()
{
  
  t++;
  // rotate_angle -= 0.003;

  int num_seeds = 100 + t;

  float scale = 15;
  

  background(bg);
  fill(fg);
  noStroke();

  translate(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);

  for (int n=0; n < num_seeds; n++) {
    float r = radius - (radius * (n * n) / (num_seeds * num_seeds));
    float theta = PHI * n + rotate_angle;

    // Convert polar to cartesian
    float x = r * cos(theta);
    float y = r * sin(theta);
    ellipse(x, y, 5 + 20 * r/radius, 5 + 20 * r/radius);
  }
  

}
