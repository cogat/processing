// TODO:
// randomize button
// ADSR controls?
// button to highlight start and end dots + amp/angle vectors
// animate phase/rotation
// dynamic system for revving up knobs
// use the LINES setting

import java.lang.Math;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import processing.svg.*;


String[] help_lines;
String help = "";

boolean show_help = false;
boolean show_text = false;
boolean use_lines = false;

int num_dots = 10000;
float track_length = 1000.0;
int x_offset, y_offset;

PendulaController pcontroller;
ControlSurface midi_interface;


class MainListener implements KnobListener, ButtonListener {
  void on_knob_change(int channel, int delta) {
    int d_2 = delta * delta * (int) Math.signum(delta);
    switch (channel) {
      case 0: // num dots
        num_dots += d_2;
        break;
      case 7:
        x_offset += delta;
        break;
      case 8:
        track_length += d_2;
        break;
      case 15:
        y_offset -= delta;
        break;
    }
  } 
  
  void on_button_change(int button, boolean value) {
    switch(button) {
      case 6:
        selectInput("Select a file to load:", "fileSelected");
        break;      
      case 7:
        show_help = value;
        break;      
      case 12:
        println("Highlight start/end");
        break;
      case 13:
        use_lines = value;
        break;      
      case 14:
        String file_root = date_filename();
        save_json(file_root + ".json");
        save_svg(file_root + ".svg");
        break;
      case 15:
        show_text = value;
        break;
    }
  }     
}

MainListener main_listener;
PFont pFont;
PFont pFont_mono;

JSONObject json;

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    json = loadJSONObject(selection.getAbsolutePath());
    num_dots = json.getInt("num_dots");
    track_length = json.getFloat("track_length");
    x_offset = json.getInt("x_offset");
    y_offset = json.getInt("y_offset");
    use_lines = json.getBoolean("use_lines");

    pcontroller.from_json(json.getJSONArray("pendula"));
  }
}

String date_filename() {
  DateFormat df = new SimpleDateFormat("yyyyMMdd-HHmmss");
  String nowAsISO = df.format(new Date());
  return "data/harmonograph-" + nowAsISO;
}

void save_json(String filename) {
  json = new JSONObject();

  json.setInt("num_dots", num_dots);
  json.setFloat("track_length", track_length);
  json.setInt("x_offset", x_offset);
  json.setInt("y_offset", y_offset);
  json.setBoolean("use_lines", use_lines);
  
  json.setJSONArray("pendula", pcontroller.to_json());
    
  saveJSONObject(json, filename);
  println("Saved "+filename);
}

void save_svg(String filename) {
  PGraphics svg = createGraphics(width, height, SVG, filename);
  svg.beginDraw();

  float w_2 = width/2;
  float h_2 = height/2;
  float timedelta = track_length / num_dots;
    
  if (use_lines) {
    svg.beginShape();
    //beginShape(LINES); // this is quite interesting
  } else {
    svg.beginShape(POINTS);
  }
  
  float t = 0;
  for (int i=0; i < num_dots; i++) {
    float x = w_2;
    float y = h_2;
    t += timedelta;
    for (int p=0; p<pcontroller.pendula.length; p++) {
      Pendulum pd = pcontroller.pendula[p];
      if (pd.is_active) {
        pd.compute(t);
        x += pd.x;
        y += pd.y;
      }
    }
    svg.vertex(x + x_offset, y + y_offset);
  }
  
  svg.endShape();

  svg.dispose();
  svg.endDraw();
  println("Saved "+filename);
}

void setup() 
{
  help_lines = loadStrings("help.txt");
  for (int i=0; i < help_lines.length; i++) {
    help += help_lines[i] + "\n";
  };

  midi_interface = new ControlSurface(0, 1);
  pcontroller = new PendulaController();
  pcontroller.pendula[0].enable();
  pcontroller.pendula[4].enable();  
  main_listener = new MainListener();
  
  size(800, 800);
  surface.setResizable(true);
  frameRate(50);
  pFont = createFont("04b03", 8, false);
  pFont_mono = createFont("Monospaced", 10, true);

  midi_interface.add_knob_listener(pcontroller);
  midi_interface.add_knob_listener(main_listener);

  midi_interface.add_button_listener(pcontroller);
  midi_interface.add_button_listener(main_listener);
  blendMode(MULTIPLY);
}

void draw() {
  float w_2 = width/2;
  float h_2 = height/2;
  float timedelta = track_length / num_dots;
  background(250, 244, 237);
  noFill();

  if (use_lines) {
    stroke(94, 87, 81, 85);
    beginShape();
    //beginShape(LINES); // this is quite interesting
  } else {
    stroke(94, 87, 81, 85);
    beginShape(POINTS);
  }
  
  float t = 0;
  for (int i=0; i < num_dots; i++) {
    float x = w_2;
    float y = h_2;
    t += timedelta;
    for (int p=0; p<pcontroller.pendula.length; p++) {
      Pendulum pd = pcontroller.pendula[p];
      if (pd.is_active) {
        pd.compute(t);
        x += pd.x;
        y += pd.y;
      }
    }
    vertex(x + x_offset, y + y_offset);
  }
  
  endShape();

  
  // render text
  fill(50);
  if (show_text) {
    textFont(pFont, 8);
    textAlign(RIGHT, BOTTOM);
    String s = "";
    s += 
      "n: " + num_dots + 
      " length: " + track_length + 
      " fps: " + int(frameRate) + 
      " +[" + x_offset + ", " + y_offset + "]" +
      "\n";
    for (int p=0; p<pcontroller.pendula.length; p++) {
      if (pcontroller.pendula[p].is_active) {
        s += p+": ";
        s += pcontroller.pendula[p].toString() + "\n";
      }
    }
    text(s, 10, 0, width - 20, height);
  }
  
  if (show_help) {
      textFont(pFont_mono, 10);
      textLeading(12.5);
      textAlign(TOP, LEFT);
      text(help, 10, 0, width - 20, height);
  }
  
}
