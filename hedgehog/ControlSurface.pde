import themidibus.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.lang.reflect.*;


public interface KnobListener {
  void on_knob_change(int knob, int delta);
}

public interface ButtonListener {
  boolean on_button_change(int button, boolean state);
}

public class ControlSurface {
  MidiBus midibus;

  ArrayList<KnobListener> knob_listeners = new ArrayList<KnobListener>();
  ArrayList<ButtonListener> button_listeners = new ArrayList<ButtonListener>();


  ControlSurface(int in_device, int out_device) {
    //MidiBus.list();
    midibus = new MidiBus(this, in_device, out_device);
    for (int i=0; i<16; i++) {
       midibus.sendNoteOff(0, i, 0);
    }
  }

  public void add_knob_listener(KnobListener obj) {
    knob_listeners.add(obj);
  }

  public void add_button_listener(ButtonListener obj) {
     button_listeners.add(obj);
  }

  public void noteOn(Note note) {
    Iterator it = button_listeners.iterator();
    while (it.hasNext()) {
      ButtonListener bl = (ButtonListener) it.next();
      if (!bl.on_button_change(note.pitch() + 1, true)) {
          midibus.sendNoteOff(0, note.pitch(), 0);
      };
    }
  }

  public void noteOff(Note note) {
    Iterator it = button_listeners.iterator();
    while (it.hasNext()) {
      ButtonListener bl = (ButtonListener) it.next();
      if (bl.on_button_change(note.pitch() + 1, false)) {
          midibus.sendNoteOn(0, note.pitch(), 0);
      };
    }
  }

  public void controllerChange(ControlChange change) {
    Iterator it = knob_listeners.iterator();
    while (it.hasNext()) {
      KnobListener kl = (KnobListener) it.next();
      kl.on_knob_change(change.number(), change.value() - 64);
    }
  }
}

class Knob implements KnobListener {
  // A knob that controls a numerical value.
  int knob_number;
  String name;
  Object obj;
  Class cls;
  Field f;
  float factor = 1.0;
  
  Knob(int channel, Object obj, String name) {
    this.knob_number = channel;
    this.obj = obj;
    this.name = name;
    //derivatives
    this.cls = obj.getClass();
    try {
      this.f = cls.getDeclaredField(name);
    } catch (NoSuchFieldException e) {
      println(cls);
      println(e.toString());
    }
    controls.add_knob_listener(this);
  }

  Knob(int channel, Object obj, String name, float factor) {
    this(channel, obj, name);
    this.factor = factor;
  }

  String get_name() {
    return name;
  }

  Object get_value() {
    try {
      return f.get(obj);
    } catch (IllegalAccessException e) {
      println(e.toString());
    }
    return null;
  }

  void set_value(Object v) {
    try {
      f.set(obj, v);
    } catch (IllegalAccessException e) {
      println(e.toString());
    }
  }
  
  void on_knob_change(int channel, int delta) {
    if (channel==this.knob_number) {
      Object v = get_value();
      println(v.getClass().getName());
      if (v instanceof java.lang.Integer) {
        set_value((int) v + (int) (delta * factor));
      } else if (v instanceof java.lang.Float) {
        set_value((float) v + delta * factor);        
      }
      
      println(get_help());
      redraw();
    }
  }

  String get_help() {
    return this.knob_number + ": " + get_name() + "\n" + get_value();
  }
}

class Knob2 extends Knob {
  Knob2(int channel, Object obj, String name) {
    super(channel, obj, name);
  }
  
  Knob2(int channel, Object obj, String name, float factor) {
    super(channel, obj, name, factor);
  }

  void on_knob_change(int channel, int delta) {
    super.on_knob_change(channel, delta);
  }
}

class Button implements ButtonListener {
  // A button that calls a function when pressed.
  int button_number;
  String name;
  Object obj;
  Class cls;
  Method m;
  float factor = 1.0;
  
  Button(int button_number, Object obj, String name) {
    this.button_number = button_number;
    this.obj = obj;
    this.name = name;
    //derivatives
    this.cls = obj.getClass();
    try {
      Class[] args = { boolean.class }; 
      this.m = cls.getDeclaredMethod(name, args);
    } catch (NoSuchMethodException e) {
      println(cls);
      println(e.toString());
    }
    controls.add_button_listener(this);
  }

  String get_name() {
    return name;
  }

  boolean on_button_change(int button_number, boolean value) {
    boolean v = value;
    if (button_number==this.button_number) {
      try {
        v = (boolean) m.invoke(obj, value);
        println(get_help());
        redraw();
      } catch (Exception e) {
         println(e.toString());
      }
    }
    return v;
  }

  String get_help() {
    return this.button_number + ": " + get_name();
  }
}
