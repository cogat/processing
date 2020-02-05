import java.lang.Math;
import processing.svg.*;

int size = 720;
String shape = "circle";

int flow_cell_size = 8;
float hair_length = 2.0;

int vertical_partitions = 2;
int horizontal_partitions = 1;

int vertical_shift = 400;
int horizontal_shift = 200;

float noise_size = 0.0008;
float noise_radius = 0.01;

int flow_dim;

int seed = (int) new Date().getTime();
int noise_lod = 8;
float noise_falloff = 0.5;

boolean show_help = false;

PVector[][] flow_grid;

ControlSurface controls;

PGraphics default_graphics;
PGraphics svg_graphics;

PApplet applet;

int line_count;

void setup() {
  applet = this;
  init_ui();
  default_graphics = g;
  size(800, 800);
  surface.setLocation(0,0);
  surface.setResizable(true);
  noLoop();
}

void draw() {
  background(34, 34, 34); // don't draw this on the svg
  stroke(255, 40);
  draw_frame(default_graphics);
  if (show_help) draw_help(default_graphics);
}

void draw_frame(PGraphics g) {
  randomSeed(seed);
  noiseSeed(seed);
  noiseDetail(noise_lod, noise_falloff);
  g.strokeWeight(1);

  g.translate((width - size) / 2, (height - size) / 2);
  init_flow();
  display_flow(g);
  g.translate(-(width - size) / 2, -(height - size) / 2);
}

void init_flow() {
  flow_dim = size / flow_cell_size;

  flow_grid = new PVector[flow_dim][flow_dim];
  for (int i = 0; i < flow_dim; i++) {
    for (int j = 0; j < flow_dim; j++) {
      flow_grid[i][j] = calculate_flow(
        (j + vertical_shift * floor((vertical_partitions * j) / flow_dim)) * noise_size,
        (i + horizontal_shift * floor((horizontal_partitions * i) / flow_dim)) * noise_size,
        noise_radius
      );
    }
  }
}

PVector calculate_flow(float x, float y, float r) {
  PVector mean_arrow = new PVector();
  int radial_samples = 3;
  for (int i = 0; i < radial_samples; i++) {
    float angle = random(PI);
    PVector pos1 = new PVector(x + cos(angle) * r, y + sin(angle) * r);
    PVector pos2 = new PVector(x + cos(angle + PI) * r, y + sin(angle + PI) * r);

    float val1 = noise(pos1.x, pos1.y);
    float val2 = noise(pos2.x, pos2.y);

    PVector hilo = PVector.sub(pos1, pos2)
      .normalize()
      .mult(val1 - val2);

    mean_arrow.add(hilo);
  }
  mean_arrow.div(radial_samples);
  mean_arrow.rotate(PI / 2);
  return mean_arrow;
}

boolean inside_radius(float x, float y, float r) {
  return sqrt(x * x + y * y) < r;
}

boolean inside_heart(float x, float y) {
  y = -y + 0.2; // invert and vertical shift
  float result = pow(x * x + y * y - 1, 3) - x * x * y * y * y;
  return result <= 0;
}

boolean in_mask(int x, int y) {
  int f_2 = flow_dim / 2;
  switch (shape) {
    case "circle":
      return inside_radius(
        x - f_2,
        y - f_2,
        flow_dim / 2
      );
    case "heart":
      // map 0..flow_dim to -2..2
      float scale = 1.3;
      return inside_heart(
        2 * scale * x / flow_dim - scale,
        2 * scale * y / flow_dim - scale
      );
    default:
      return true;
  }
}

void display_flow(PGraphics g) {
  line_count = 0;
  for (int y = 0; y < flow_dim; y++) {
    for (int x = 0; x < flow_dim; x++) {
      if (
        in_mask(x, y)
      ) {
        g.line(
          x * flow_cell_size,
          y * flow_cell_size,
          x * flow_cell_size + flow_grid[y][x].x * hair_length * 2500,
          y * flow_cell_size + flow_grid[y][x].y * hair_length * 2500
        );
        line_count++;
      }
    }
  }
}
