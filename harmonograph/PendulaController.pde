import java.util.ArrayList;

static int NUM_PENDULA = 8;

class PendulaController implements KnobListener, ButtonListener {
  Pendulum[] pendula =  new Pendulum[NUM_PENDULA];
  boolean[] selected_pendula = new boolean[NUM_PENDULA];  
  
  PendulaController() {
    for (int i=0; i<NUM_PENDULA; i++) {
      pendula[i] = new Pendulum();
    }    
  }
  
  void on_button_change(int button, boolean value) {
    switch (button) {
      case 0:
      case 1:
      case 2:
      case 3:
        selected_pendula[button] = value;
        break;
      case 4:
        for (int i=0; i<NUM_PENDULA; i++) {
          if (selected_pendula[i]) {
            Pendulum p = pendula[i];
            if (value) {
              p.enable();
            } else {
              p.disable();
            }
          }
        }
        break;
      case 5:
        for (int i=0; i<NUM_PENDULA; i++) {
          if (selected_pendula[i]) {
            Pendulum p = pendula[i];
            p.randomise();
          }
        }
        break;
      case 8:
      case 9:
      case 10:
      case 11:
        selected_pendula[button-4] = value;
        break;
    }
  }
  
  void on_knob_change(int knob, int delta) {
    int d_2 = delta * delta * (int) Math.signum(delta);

    for (int i=0; i<NUM_PENDULA; i++) {
      if (selected_pendula[i]) {
        Pendulum p = pendula[i];
        switch(knob) {
          case 1:
            p.amplitude.setMag(p.amplitude.mag() + d_2);  
            break;
          case 2:
            p.amplitude.rotate(d_2 * 0.01);
            break;
          case 3:
            p.frequency += d_2 * 0.0001;
            break;
          case 4:
            p.phase += d_2 * 0.01;
            break;
          case 5:
            p.velocity_x += d_2 * 0.001;
            break;
          case 10:
            p.decay += d_2 * 0.0001;
            break;
          case 13:
            p.velocity_y -= d_2 * 0.001;
            break;
        }
      }
    }
  }
  
  JSONArray to_json() {
    JSONArray result = new JSONArray();
    for (int i=0; i<NUM_PENDULA; i++) {
       result.setJSONObject(i, pendula[i].to_json());
    }
    return result;
  }
  
  void from_json(JSONArray j) {
    for (int i = 0; i < j.size(); i++) {
      JSONObject p = j.getJSONObject(i);
      pendula[i].from_json(p);
    }
  }
}
