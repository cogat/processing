class SketchListener implements KnobListener, ButtonListener {
  void on_knob_change(int channel, int delta) {
    // int d_2 = delta * delta * (int) Math.signum(delta);
    switch (channel) {
      case 0:
        testvar += delta;
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

  void on_button_change(int button, boolean value) {
    switch(button) {
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
        break;
      case 7:
        break;
      default:
        println("unmapped button " + button + ": " + value);
        break;
    }
  }
}

SketchListener listener;