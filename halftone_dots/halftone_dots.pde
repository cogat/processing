float circle_spacing_h = 145;
float circle_spacing_v = circle_spacing_h * cos(PI/6);
float circle_size = 148;
float offset_speed = 0.50;

float num_rows, num_cols;

void setup() {
  size(1000, 400);
  blendMode(ADD);
  colorMode(RGB, 1.0);
  noStroke();
  frameRate(60);
  
  num_cols = 1 + width / circle_spacing_h;
  num_rows = 1 + height / circle_spacing_v;
}


void drawGrid(PVector offset) {
  int x0 = -ceil(offset.x / circle_spacing_h);
  int y0 = -ceil(offset.y / circle_spacing_v);
  
  for (int xi = x0; xi <= num_cols + x0 + 1; xi++) {
    for (int yi = y0; yi <= num_rows + y0 + 1; yi++) {
      
      float x = xi;
      if (yi % 2 != 0) x+= 0.5;
      
      ellipse(
        (x * circle_spacing_h + offset.x), 
        (yi * circle_spacing_v + offset.y),
        circle_size, circle_size
      );
    }
  }
}

PVector polar2vec(float r, float theta) {
  return new PVector(
    r * cos(theta),
    r * -sin(theta)
  );
}



float offset = 0;
void draw() {
  
  offset += offset_speed;
  
  background(0,0,0.6);
  
  fill(0.8, 0, 0);
  drawGrid(polar2vec(offset, 0));
  
  fill(0.0, 0.6, 0.2);
  drawGrid(polar2vec(offset, 2.0 * PI / 3.0));
  
  fill(0, 0.2, 1.0);
  drawGrid(polar2vec(offset, 4.0 * PI / 3.0));
}
