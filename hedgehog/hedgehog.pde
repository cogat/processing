int width = 1000;
int height = 1000;
int offset = -100;
boolean b = true;
boolean circular_shape = true;

int flow_cell_size = 5;
int hair_length = 3;
int number_of_layers = 1;

int vertical_partitions = 2;
int horizontal_partitions = 1;

int vertical_shift = 400;
int horizontal_shift = 200;

float noise_size = 0.0008;
float noise_radius = 0.01;

float flow_width = (width + offset * 2.0) / flow_cell_size;
float flow_height = (height + offset * 2.0) / flow_cell_size;

PVector[][] flow_grid;

float noise_offset_x, noise_offset_y;

void setup() {
  size(1000, 300);
  surface.setResizable(true);
  smooth();
  stroke(255, 40);
  strokeWeight(1);
}

void draw() {
  background(34, 34, 34);
  translate(-offset, -offset);

  for (int i = 0; i < number_of_layers; i++) {
    noise_offset_x = random(10);
    noise_offset_y = random(10);
    init_flow();
    display_flow(i);
  }

  noLoop();

}

void init_flow() {
  flow_grid = new PVector[(int)flow_height][];
  for (int i = 0; i < flow_height; i++) {
    PVector[] row = new PVector[(int)flow_width];
    for (int j = 0; j < flow_width; j++) {
      row[j] = calculate_flow(
        (j + vertical_shift * floor((vertical_partitions * j) / flow_height)) * noise_size,
        (i + horizontal_shift * floor((horizontal_partitions * i) / flow_width)) * noise_size,
        noise_radius
      );
  }
    flow_grid[i] = row;
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

void display_flow(int col) {
  for (int i = 0; i < flow_grid.length; i++) {
    for (int j = 0; j < flow_grid[i].length; j++) {
      if (
        !circular_shape ||
        inside_radius(
          i - flow_grid.length / 2,
          j - flow_grid[i].length / 2,
          400.0 / flow_cell_size
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
    save("mySVG.svg");
    // saveCanvas('noise_grid', 'jpeg');
  }
};
