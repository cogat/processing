int margin;
String shape = "heart";

int flow_cell_size = 4;
float hair_length = 2.0;

int vertical_partitions = 2;
int horizontal_partitions = 1;

int vertical_shift = 400;
int horizontal_shift = 200;

float noise_size = 0.0008;
float noise_radius = 0.01;

int flow_dim;

PVector[][] flow_grid;

ControlSurface controls;

float noise_offset_x, noise_offset_y;

void setup() {
  controls = new ControlSurface(0, 1);
  listener = new SketchListener(this);
  controls.add_knob_listener(listener);
  controls.add_button_listener(listener);

  size(800, 800);
  margin = (int)(width * 0.05);

  surface.setLocation(0,0);
  surface.setResizable(true);
  smooth();
  stroke(255, 40);
  strokeWeight(1);

  noise_offset_x = random(10);
  noise_offset_y = random(10);

  noLoop();
}

void draw() {
  background(34, 34, 34);
  translate(margin, margin);
  init_flow();
  display_flow();
}

void init_flow() {
  flow_dim = (height - margin * 2) / flow_cell_size;

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

    float val1 = noise(noise_offset_x + pos1.x, noise_offset_y + pos1.y);
    float val2 = noise(noise_offset_x + pos2.x, noise_offset_y + pos2.y);

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

void display_flow() {
  for (int y = 0; y < flow_dim; y++) {
    for (int x = 0; x < flow_dim; x++) {
      if (
        in_mask(x, y)
      ) {
        line(
          x * flow_cell_size,
          y * flow_cell_size,
          x * flow_cell_size + flow_grid[y][x].x * hair_length * 2500,
          y * flow_cell_size + flow_grid[y][x].y * hair_length * 2500
        );
      }
    }
  }
}

void keyPressed() {
  if (keyCode == 32) {
    vertical_partitions ++;
    flow_cell_size++;
    redraw();
    //save("mySVG.svg");
    // saveCanvas('noise_grid', 'jpeg');
  }
};
