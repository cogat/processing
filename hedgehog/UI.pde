public class SketchListener implements KnobListener, ButtonListener {
  PApplet applet;

  SketchListener(PApplet applet) {
    this.applet = applet;
  }

  void on_knob_change(int channel, int delta) {
     int d_2 = delta * delta * (int) Math.signum(delta);
    switch (channel) {
      case 0:
        flow_cell_size += delta;
        break;
      //row 1
      case 1:
        vertical_shift += delta;
        break;
      case 2:
        vertical_partitions += delta;
        break;
      case 3:
        noise_size += d_2 / 1000;
        break;
      case 4:
        hair_length += delta / 10.0;
        break;
      case 5:
        break;
      case 6:
        break;
      case 7:
        break;
      case 8:
        break;
      //row 2
      case 9:
        horizontal_shift += delta;
        break;
      case 10:
        horizontal_partitions += delta;
        break;
      case 11:
        noise_radius += delta * 0.001;
        break;
      case 12:
        margin += delta;
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
    redraw();
  }

  boolean on_button_change(int button, boolean value) {
    // buttons latch by default
    // if 'value' is true, return false to turn the button off (momentary)
    // if 'value' is false, return true to turn the button on (reverse momentary)
    switch(button) {
      // row 1
      case 0:
        switch (shape) {
          case "circle":
            shape = "square";
            break;
          case "square":
            shape = "heart";
            break;
          case "heart":
            shape = "circle";
            break;
        };
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
        save_settings("data/" + applet.getClass().getName() + "-" + date_string() + ".json");
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
    redraw();
    return false;
  }

  void save_settings(String filename) {
    JSONObject json = new JSONObject();

    json.setString("shape", shape);
    json.setInt("flow_cell_size", flow_cell_size);
    json.setInt("vertical_shift", vertical_shift);
    json.setInt("horizontal_shift", horizontal_shift);
    json.setInt("vertical_partitions", vertical_partitions);
    json.setInt("horizontal_partitions", horizontal_partitions);
    json.setFloat("noise_size", noise_size);
    json.setFloat("noise_radius", noise_radius);
    json.setFloat("hair_length", hair_length);
    json.setInt("margin", margin);
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

      shape = json.getString("shape");
      flow_cell_size = json.getInt("flow_cell_size");
      vertical_shift = json.getInt("vertical_shift");
      horizontal_shift = json.getInt("horizontal_shift");
      vertical_partitions = json.getInt("vertical_partitions");
      horizontal_partitions = json.getInt("horizontal_partitions");
      noise_size = json.getFloat("noise_size");
      noise_radius = json.getFloat("noise_radius");
      hair_length = json.getFloat("hair_length");
      margin = json.getInt("margin");
      redraw();
    }
  }

}

SketchListener listener;
