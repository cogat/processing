import themidibus.*;
import java.util.ArrayList;
import java.util.Iterator;

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
    MidiBus.list();
    midibus = new MidiBus(this, in_device, out_device);
    for (int i=0; i<127; i++) {
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
    // Receive a noteOn
    //println();
    //println("Note On:");
    //println("--------");
    //println("Channel:"+note.channel());
    //println("Pitch:"+note.pitch());
    //println("Velocity:"+note.velocity());

    Iterator it = button_listeners.iterator();
    while (it.hasNext()) {
      ButtonListener bl = (ButtonListener) it.next();
      if (!bl.on_button_change(note.pitch(), true)) {
          midibus.sendNoteOff(0, note.pitch(), 0);
      };
    }
  }

  public void noteOff(Note note) {
    // Receive a noteOff
    //println();
    //println("Note Off:");
    //println("--------");
    //println("Channel:"+note.channel());
    //println("Pitch:"+note.pitch());
    //println("Velocity:"+note.velocity());

    Iterator it = button_listeners.iterator();
    while (it.hasNext()) {
      ButtonListener bl = (ButtonListener) it.next();
      if (bl.on_button_change(note.pitch(), false)) {
          midibus.sendNoteOn(0, note.pitch(), 0);
      };
    }

    //for (int i=0; i<button_listeners.size(); i++) {
    //   button_listeners.get(i).on_button_change(note.pitch(), false);
    //}

  }

  public void controllerChange(ControlChange change) {
    // Receive a controllerChange
    //println();
    //println("Controller Change:");
    //println("--------");
    //println("Channel:"+change.channel());
    //println("Number:"+change.number());
    //println("Value:"+change.value());

    Iterator it = knob_listeners.iterator();
    while (it.hasNext()) {
      KnobListener kl = (KnobListener) it.next();
      kl.on_knob_change(change.number(), change.value() - 64);
    }
  }
}
