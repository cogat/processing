int margin;
boolean circular_shape = true;

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
  listener = new SketchListener();
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

void display_flow() {
  for (int i = 0; i < flow_dim; i++) {
    for (int j = 0; j < flow_dim; j++) {
      if (
        !circular_shape ||
        inside_radius(
          i - flow_dim / 2,
          j - flow_dim / 2,
          flow_dim / 2
        )
      ) {
        line(
          j * flow_cell_size,
          i * flow_cell_size,
          j * flow_cell_size + flow_grid[i][j].x * hair_length * 2500,
          i * flow_cell_size + flow_grid[i][j].y * hair_length * 2500
        );
      }
    }
  }
}

boolean inside_radius(float x, float y, float r) {
  return sqrt(x * x + y * y) < r;
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
