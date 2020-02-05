PFont pFont;

void init_ui() {
  pFont = createFont("Monaco", 9, false);
  controls = new ControlSurface(0, 1);
  
  knobs[0] = new Knob(0, this, "flow_cell_size");
  knobs[1] = new Knob(1, this, "vertical_partitions");
  knobs[2] = new Knob(2, this, "vertical_shift");
  knobs[3] = new Knob2(3, this, "noise_size", 0.001);
  knobs[4] = new Knob(4, this, "noise_lod");
  knobs[5] = new Knob(5, this, "hair_length", 0.1);
  //row 2
  knobs[9] = new Knob(9, this, "horizontal_partitions");
  knobs[10] = new Knob(10, this, "horizontal_shift");
  knobs[11] = new Knob(11, this, "noise_radius", 0.001);
  knobs[12] = new Knob2(12, this, "noise_falloff", 0.01);
  knobs[13] = new Knob2(13, this, "size");
  
  buttons[1] = new Button(1, this, "cycle_shape");
  buttons[7] = new Button(7, this, "save");
  //row 2
  buttons[9] = new Button(9, this, "new_seed");
  buttons[15] = new Button(15, this, "load");
  buttons[16] = new Button(16, this, "help");
}

boolean cycle_shape(boolean value) {
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
  return value;
}

boolean save(boolean value) {
  String name = "data/" + applet.getClass().getName() + "-" + date_string();
  save_settings(name + ".json");
  save_svg(name + ".svg");
  return false;
}

boolean load(boolean value) {
  selectInput("Select a settings file to load:", "_apply_settings", null, this);
  return false;
}

boolean new_seed(boolean value) {
  seed = (int) new Date().getTime();
  return false;
}

boolean help(boolean value) {
  show_help = value;
  return value;
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
  json.setInt("size", size);
  json.setInt("noise_lod", noise_lod);
  json.setFloat("noise_falloff", noise_falloff);
  json.setInt("seed", seed);
  // json.setJSONArray("pendula", pcontroller.to_json());

  saveJSONObject(json, filename);
  println("Saved "+filename);
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
    size = json.getInt("size");
    noise_lod = json.getInt("noise_lod");
    noise_falloff = json.getFloat("noise_falloff");
    seed = json.getInt("seed");
    redraw();
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

String app_help() {
  return "lines: " + line_count; 
}
