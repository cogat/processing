class SketchListener implements KnobListener, ButtonListener {
  void on_knob_change(int channel, int delta) {
    // int d_2 = delta * delta * (int) Math.signum(delta);
    switch (channel) {
      case 0:
        testvar += delta;
      default: // num dots
        println("knob " + channel + ": " + delta);
        break;
    }
  }

  void on_button_change(int button, boolean value) {
    switch(button) {
      case 0:
        // ...
      default: // num dots
        println("button " + button + ": " + value);
        break;
    }
  }
}

SketchListener listener;