import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TunerModel {
    var preset as Number = 0;
    var noteIndex as Number = 0;
    var a4 as Float = 440.0;
    var demo as Boolean = true;
    var source as PitchSource = new DemoSource();

    function strings() as Array<Number> { return Instruments.notes(preset); }
    function targetMidi() as Number { return strings()[noteIndex]; }
    function targetFreq() as Float { return PitchMath.midiToFreq(targetMidi(), a4); }

    function setPreset(p as Number) as Void {
        preset = p;
        noteIndex = 0;
    }

    function setDemo(on as Boolean) as Void {
        demo = on;
        source = on ? new DemoSource() : new MicSource();
    }

    function step(delta as Number) as Void {
        var n = strings().size();
        noteIndex = (noteIndex + delta + n) % n;
    }
}

class TunerApp extends Application.AppBase {
    var model as TunerModel = new TunerModel();

    function initialize() { AppBase.initialize(); }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new TunerView(model), new TunerDelegate(model)];
    }
}

function getApp() as TunerApp {
    return Application.getApp() as TunerApp;
}
