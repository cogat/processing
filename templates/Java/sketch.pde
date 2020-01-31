import java.lang.Math;
import processing.svg.*;

ControlSurface controls;

int testvar = 100;

void setup() {
  controls = new ControlSurface(0, 1);
  listener = new SketchListener(this);
  controls.add_knob_listener(listener);
  controls.add_button_listener(listener);

  size(800, 800, FX2D);
  surface.setResizable(true);
  frameRate(60);

  // blendMode(MULTIPLY);
}

void draw() {
  int w_2 = width/2;
  int h_2 = height/2;

  background(22);
  ellipse(w_2, h_2, w_2 + testvar, h_2 + testvar);

}
