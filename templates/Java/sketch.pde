import java.lang.Math;
import processing.svg.*;

ControlSurface controls;
PGraphics default_graphics;
PGraphics svg_graphics;

int testvar = 100;

void setup() {
  controls = new ControlSurface(0, 1);
  listener = new SketchListener(this);
  controls.add_knob_listener(listener);
  controls.add_button_listener(listener);

  default_graphics = g;

  size(800, 800, FX2D);
  surface.setResizable(true);
  frameRate(60);
}

void draw() {
  draw_frame(default_graphics);
}

void draw_frame(PGraphics g) {
  int w_2 = width/2;
  int h_2 = height/2;

  g.background(22);
  g.ellipse(w_2, h_2, w_2 + testvar, h_2 + testvar);
}
