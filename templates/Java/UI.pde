

public class SketchListener implements KnobListener, ButtonListener {
  PApplet applet;

  SketchListener(PApplet applet) {
    this.applet = applet;
  }

  void on_knob_change(int channel, int delta) {
    // int d_2 = delta * delta * (int) Math.signum(delta);
    switch (channel) {
      case 0:
        testvar += delta;
        break;
      // row 1
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
      case 5:
        break;
      case 6:
        break;
      case 7:
        break;
      case 8:
        break;
      // row 2
      case 9:
        break;
      case 10:
        break;
      case 11:
        break;
      case 12:
        break;
      case 13:
        break;
      case 14:
        break;
      case 15:
        break;
      case 16:
        break;
      default:
        println("unmapped knob " + channel + ": " + delta);
        break;
    }
  }

  boolean on_button_change(int button, boolean value) {
    // buttons latch by default
    // if 'value' is true, return false to turn the button off (momentary)
    // if 'value' is false, return true to turn the button on (reverse momentary)
    switch(button) {
      // row 1
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
      case 5:
        break;
      case 6:
        String name = "data/" + applet.getClass().getName() + "-" + date_string();
        save_settings(name + ".json");
        save_svg(name + ".svg");
        return false;
      case 7:
        break;
      // row 2
      case 8:
        break;
      case 9:
        break;
      case 10:
        break;
      case 11:
        break;
      case 12:
        break;
      case 13:
        break;
      case 14:
        load_settings();
        return false;
      case 15:
        break;
      default:
        println("unmapped button " + button + ": " + value);
        break;
    }
    return value;
  }

  void save_settings(String filename) {
    JSONObject json = new JSONObject();

    json.setInt("testvar", testvar);
    // json.setJSONArray("pendula", pcontroller.to_json());

    saveJSONObject(json, filename);
    println("Saved "+filename);
  }

  void load_settings() {
      selectInput("Select a settings file to load:", "_apply_settings", null, this);
  }

  public void _apply_settings(File selection) {
    if (selection != null) {
      JSONObject json = loadJSONObject(selection.getAbsolutePath());
      testvar = json.getInt("testvar");
      // pcontroller.from_json(json.getJSONArray("pendula"));
    }
  }

  void save_svg(String filename) {
    svg_graphics = createGraphics(width, height, SVG, filename);
    svg_graphics.beginDraw();

    draw_frame(svg_graphics);

    svg_graphics.dispose();
    svg_graphics.endDraw();
    println("Saved "+filename);
    }

}

SketchListener listener;

void keyPressed() { // hack to use keys without midi
  if ('0' <= key && key <= '9') {
    listener.on_button_change(keyCode-48, true);
  }
}