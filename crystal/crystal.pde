/*
TODO:

- address grid issue that allows diagonal lines to pass each other
- svg, control surface, yada yada
*/

import java.lang.Math;
import processing.svg.*;

ControlSurface controls;
PGraphics default_graphics;
PGraphics svg_graphics;

int cell_size = 5;
int num_lines_start = 500;

int x_dim;
int y_dim;

PVector[][] field;
ArrayList<IntLine> lines = new ArrayList<IntLine>();

boolean[][] line_passes;
boolean[][] line_terminates;


class LineComplete extends Exception {
  LineComplete(String str) {
    super(str);
  }
};

class IntLine {
  int x1;
  int y1;
  int x2;
  int y2;
  int xdiff;
  int ydiff;
  boolean e1_intersects;
  boolean e2_intersects;
  
  IntLine(int x1, int y1) {
    this.x1 = x1;
    this.y1 = y1;
    // set a random direction for this line
    while (xdiff == 0 && ydiff == 0) {
      xdiff = (int) random(-2, 2);
      ydiff = (int) random(-2, 2);
    }
    this.x2 = x1;
    this.y2 = y1;
    line_passes[this.x1][this.y1] = true;
  }
  
  IntLine(int x1, int y1, int xdiff, int ydiff) {
    this.x1 = x1;
    this.y1 = y1;
    this.xdiff = xdiff;
    this.ydiff = ydiff;
    this.x2 = x1;
    this.y2 = y1;
    line_passes[this.x1][this.y1] = true;
  }
  
  String toString() {
    return "["+this.x1+","+this.y1+" => "+this.x2+","+this.y2+"]";
  }
  
  float length() {
    int a = x2-x1;
    int b = y2-y1;
    return sqrt(a * a + b * b); 
  }

  void extend2_if_poss() throws LineComplete {
    try {
      if (line_passes[x2 + xdiff][y2 + ydiff]) {
        x2 += xdiff;
        y2 += ydiff;
        e2_intersects = true;
        throw new LineComplete("end 2 intersects");
      } else {
        x2 += xdiff;
        y2 += ydiff;
        line_passes[x2][y2] = true;
      }
    } catch (ArrayIndexOutOfBoundsException e) {
      e2_intersects = true;
      throw new LineComplete("end 2 is at edge");
    }
  }

  void extend1_if_poss() throws LineComplete {
    try {
      if (line_passes[x1 - xdiff][y1 - ydiff]) {
        x1 -= xdiff;
        y1 -= ydiff;
        e1_intersects = true;
        throw new LineComplete("end 1 intersects");
      } else {
        x1 -= xdiff;
        y1 -= ydiff;
        line_passes[x1][y1] = true;
      }
    } catch (ArrayIndexOutOfBoundsException e) {
      e1_intersects = true;
      throw new LineComplete("end 1 is at edge");
    }
  }

  void draw(PGraphics g) {
    PVector p1 = field[x1][y1];
    PVector p2 = field[x2][y2];  
    g.line(p1.x, p1.y, p2.x, p2.y);
  }
  
  int[] midpoint() {
    int[] result = new int[2];
    result[0] = (x1 + x2) / 2;
    result[1] = (y1 + y2) / 2;
    //println(x1, x2, result[0]);
    //println(y1, y2, result[0]);
    return result;
  }
  
  int[] spinoff_diffs() {
    switch (xdiff) {
      case -1:
        switch (ydiff) {
          case -1:
            return new int[] {-1, 0, 0, -1};
          case 0:
            return new int[] {-1, 1, -1, -1};          
          case 1:
            return new int[] {0, 1, -1, 0};                    
        }
      case 0:
        switch (ydiff) {
          case -1:
            return new int[] {-1, -1, 1, -1};
          case 1:
            return new int[] {1, 1, -1, 1};                    
        }      
      case 1:
        switch (ydiff) {
          case -1:
            return new int[] {0, -1, 1, 0};
          case 0:
            return new int[] {1, -1, 1, 1};          
          case 1:
            return new int[] {1, 0, 0, 1};                    
        }
    }
    // default just to make the compiler happy
    return new int[] {0,0,0,0};
  }
}

void setup() {
  controls = new ControlSurface(0, 1);
  listener = new SketchListener(this);
  controls.add_knob_listener(listener);
  controls.add_button_listener(listener);

  default_graphics = g;

  size(800, 800, FX2D);
  surface.setResizable(true);
  frameRate(60);
  //noLoop();
  
  x_dim = 1 + (width / cell_size);
  y_dim = 1 + (height / cell_size);
  
  field = new PVector[x_dim][y_dim];
  line_passes = new boolean[x_dim][y_dim];
  for (int x=0; x<x_dim; x++) {
    for (int y=0; y<y_dim; y++) {
      field[x][y] = new PVector(x * cell_size, y * cell_size);
    }
  }
  
  // set up some initial lines
  for (int p=0; p<num_lines_start; p++) {
    lines.add(new IntLine((int)random(x_dim), (int)random(y_dim)));
  }
}

void draw() {
  draw_frame(default_graphics);
}

void draw_grid(PGraphics g) {
  stroke(128);
  for (int x=0; x<x_dim; x++) {
    for (int y=0; y<y_dim; y++) {
      g.point(x * cell_size, y * cell_size);
    }
  }
  stroke(0);
}

boolean done;

void draw_frame(PGraphics g) {
  if (done) return;
  g.background(200);
  
  //draw_grid(g);
  
  boolean all_lines_complete = true;
  
  for (int i=0; i<lines.size(); i++) {
    IntLine l = lines.get(i);
    
    if (l.e1_intersects && l.e2_intersects) {
      // the line is complete; nothing to do except draw.
      l.draw(g);
      continue;
    }
    
    all_lines_complete = false;
    
    if (!l.e1_intersects) {
      try {
       l.extend1_if_poss();
      } catch (LineComplete e) {}
    }
    if (!l.e2_intersects) {
      try {
       l.extend2_if_poss();
      } catch (LineComplete e) {}
    }
    
    if (l.e1_intersects && l.e2_intersects && l.length() >= 2) {
      // the line was just completed; start 2 new lines at the midpoint
      // pi/4 from the line
      int[] midpoint = l.midpoint();
      int[] newdiffs = l.spinoff_diffs();
      
      IntLine l1 = new IntLine(
        midpoint[0], midpoint[1],
        newdiffs[0], newdiffs[1]
      );
      l1.e1_intersects = true;
      IntLine l2 = new IntLine(
        midpoint[0], midpoint[1],
        newdiffs[2], newdiffs[3]
      );
      l2.e1_intersects = true;

      lines.add(l1);
      lines.add(l2);
    }

    l.draw(g);
  }
  
  if (all_lines_complete) {
    println("Done.");
    done = true;
  }
}
