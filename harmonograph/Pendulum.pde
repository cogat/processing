class Pendulum {
  boolean is_active;
  PVector amplitude;
  float frequency, phase, decay;
  float velocity_x, velocity_y;
  float x, y;

  Pendulum () {
    amplitude = new PVector(random(150.0), 0);
    amplitude.rotate(random(2*PI));
    frequency = random(10.0);
    phase = 0;
    decay = 0;
    is_active = false;
  }
  
  void randomise() {
    amplitude = new PVector(random(150.0), 0);
    amplitude.rotate(random(2*PI));
    frequency = random(1.0);
    phase = 0;
    decay = random(0.005);
  }
  
  void enable() {
    is_active = true;
  }
  
  void disable() {
    is_active = false;
  }

  void compute(float t) {
    if (!is_active) return;
    float s = sin(t * frequency + phase) * exp(-decay * t);
    x = t * velocity_x + amplitude.x * s;
    y = t * velocity_y + amplitude.y * s;
  }

  String toString() {
    return 
      "[" + String.format("%.2f", amplitude.mag()) + "∠"+ String.format("%.2f", amplitude.heading()/PI) +"π]" + 
      " F: " + String.format("%.4f", frequency) + 
      " P: " + String.format("%.2f", phase/PI) + "π" +
      " D: " + String.format("%.6f", decay) + 
      " +[" + String.format("%.2f", velocity_x) + ", " + String.format("%.2f", velocity_y) + "]";
  }
  
  JSONObject to_json() {
    JSONObject j = new JSONObject();
    j.setBoolean("is_active", is_active);
    j.setFloat("amplitude_x", amplitude.x);
    j.setFloat("amplitude_y", amplitude.y);
    j.setFloat("frequency", frequency);
    j.setFloat("phase", phase);
    j.setFloat("decay", decay);
    j.setFloat("velocity_x", velocity_x);
    j.setFloat("velocity_y", velocity_y);
    return j;
  }

  void from_json(JSONObject j) {
    is_active = j.getBoolean("is_active");
    amplitude.x = j.getFloat("amplitude_x");
    amplitude.y = j.getFloat("amplitude_y");
    frequency = j.getFloat("frequency");
    phase = j.getFloat("phase");
    decay = j.getFloat("decay");
    velocity_x = j.getFloat("velocity_x");
    velocity_y = j.getFloat("velocity_y");
  }
}
