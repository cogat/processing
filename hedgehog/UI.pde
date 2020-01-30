class SketchListener implements KnobListener, ButtonListener {
  void on_knob_change(int channel, int delta) {
     int d_2 = delta * delta * (int) Math.signum(delta);
    switch (channel) {
      case 0:
        flow_cell_size += delta;
        break;
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

  void on_button_change(int button, boolean value) {
    switch(button) {
      case 0:
        circular_shape = value;
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
        break;
      case 7:
        break;
      default:
        println("unmapped button " + button + ": " + value);
        break;
    }
    redraw();
  }
}

SketchListener listener;
