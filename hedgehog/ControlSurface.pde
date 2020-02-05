import themidibus.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.lang.reflect.*;

Knob[] knobs = new Knob[17];
Button[] buttons = new Button[17];


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
      if (v instanceof java.lang.Integer) {
        set_value((int) v + (int) (delta * factor));
      } else if (v instanceof java.lang.Float) {
        set_value((float) v + delta * factor);        
      }      
      redraw();
    }
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
        redraw();
      } catch (Exception e) {
         println(e.toString());
      }
    }
    return v;
  }
}

void draw_help(PGraphics g) {
  g.fill(255);
  g.textFont(pFont, 9);
  g.textLeading(9);
  g.textAlign(RIGHT, BOTTOM);
  String app_help = app_help();
  if (app_help.length() > 0) {
    app_help += "\n";
  }
  
  String s = app_help + knobs_help() + "\n" + buttons_help();
  g.text(s, 10, 10, g.width - 20, g.height - 20);
}

String knobs_help() {
  int num_columns = 9, num_rows = 2;
  int[][] numbers = new int[num_columns][num_rows];
  String[][] names = new String[num_columns][num_rows];
  String[][] values = new String[num_columns][num_rows];
  int[][] lengths = new int[num_columns][num_rows];
  
  // populate array of strings to show
  int knob_number = -1;
  for (int row=0; row < num_rows; row ++) {
    for (int col=0; col < num_columns; col++) {
      if (col == 0 && row > 0) { // only the first row gets an extra knob 0
        numbers[col][row] = -1;
        names[col][row] = "";
        values[col][row] = "";
        lengths[col][row] = 0;
        continue;
      }
      
      knob_number ++;
      numbers[col][row] = knob_number;
      try {
        Knob k = knobs[knob_number];
        names[col][row] = k.get_name();
        values[col][row] = "" + k.get_value();
      } catch (Exception e) {
        names[col][row] = "";
        values[col][row] = "";
      }
      lengths[col][row] = max(names[col][row].length(), values[col][row].length());
    }
  }
  // align the lengths of each column in the 2 rows
  for (int row=0; row < num_rows; row ++) {
    for (int col=0; col < num_columns; col++) {
      lengths[col][row] = max(lengths[col][0], lengths[col][1], 2);
    }
  }

  String s = "";
  
  for (int row=0; row < num_rows; row++) {
    
    // draw top line
    for (int col=0; col < num_columns; col++) {
      if (numbers[col][row] == -1) continue;
      if (col==0) {
        s += "┌";
      } else {
        s += "┬";
        
      }
      String padding_string = "%-"+lengths[col][row]+"s";
      s += String.format(padding_string, numbers[col][row]).replace(' ', '─');
    }
    s += "┐\n";
    
    //draw name
    for (int col=0; col < num_columns; col++) {
      if (numbers[col][row] == -1) continue;
      String padding_string = "%-"+lengths[col][row]+"s";
      s += "│" + String.format(padding_string, names[col][row]);
    }
    s += "│\n";

    //draw value
    for (int col=0; col < num_columns; col++) {
      if (numbers[col][row] == -1) continue;
      String padding_string = "%-"+lengths[col][row]+"s";
      s += "│" + String.format(padding_string, values[col][row]);
    }
    s += "│\n";

    // draw bottom line
    for (int col=0; col < num_columns; col++) {
      if (numbers[col][row] == -1) continue;
      if (col==0) {
        s += "└";
      } else {
        s += "┴";
        
      }
      String padding_string = "%-"+lengths[col][row]+"s";
      s += String.format(padding_string, "").replace(' ', '─');
    }
    s += "┘\n";
  }
  
  return s;
}

String buttons_help() {
  int num_columns = 8, num_rows = 2;
  int[][] numbers = new int[num_columns][num_rows];
  String[][] names = new String[num_columns][num_rows];
  int[][] lengths = new int[num_columns][num_rows];
  
  // populate array of strings to show
  int button_number = 0;
  for (int row=0; row < num_rows; row ++) {
    for (int col=0; col < num_columns; col++) {
      button_number ++;
      numbers[col][row] = button_number;
      Button b = buttons[button_number];
      if (b != null) {
        names[col][row] = b.get_name();
      } else {
        names[col][row] = "";
      }
      lengths[col][row] = names[col][row].length();
    }
  }
  // align the lengths of each column in the 2 rows
  for (int row=0; row < num_rows; row ++) {
    for (int col=0; col < num_columns; col++) {
      lengths[col][row] = max(lengths[col][0], lengths[col][1], 2);
    }
  }

  String s = "";
  
  for (int row=0; row < num_rows; row++) {
    // draw top line
    for (int col=0; col < num_columns; col++) {
      if (col==0) {
        s += "┌";
      } else {
        s += "┬";
        
      }
      String padding_string = "%-"+lengths[col][row]+"s";
      s += String.format(padding_string, numbers[col][row]).replace(' ', '─');
    }
    s += "┐\n";
    
    //draw name
    for (int col=0; col < num_columns; col++) {
      String padding_string = "%-"+lengths[col][row]+"s";
      s += "│" + String.format(padding_string, names[col][row]);
    }
    s += "│\n";

    // draw bottom line
    for (int col=0; col < num_columns; col++) {
      if (col==0) {
        s += "└";
      } else {
        s += "┴";
        
      }
      String padding_string = "%-"+lengths[col][row]+"s";
      s += String.format(padding_string, "").replace(' ', '─');
    }
    s += "┘\n";
  }
  
  return s;
}
