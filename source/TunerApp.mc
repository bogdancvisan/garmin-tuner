import Toybox.Application;
import Toybox.Attention;
import Toybox.System;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.System;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.WatchUi;

class TunerModel {
    var preset as Number = 0;
    var noteIndex as Number = 0;
    var a4 as Float = 440.0;
    var demo as Boolean = false;
    var tone as Boolean = false;
    var haptic as Boolean = true;
    var source as PitchSource = new MicSource();
    private var _timer as Timer.Timer = new Timer.Timer();
    private var _hits as Number = 0;
    private var _lastBuzz as Number = -10000;

    function begin() as Void {
        source.start();
        _timer.start(method(:tick), 150, true);
    }

    function finish() as Void {
        _timer.stop();
        source.stop();
    }

    // Runs independently of the view so haptic feedback works with the screen off.
    function tick() as Void {
        var target = targetFreq();
        var f = source.getFrequency(target);
        if (f != null && PitchMath.cents(f, target).abs() < 5.0) { _hits++; } else { _hits = 0; }
        var now = System.getTimer();
        if (haptic && _hits >= 3 && now - _lastBuzz > 1500) {
            _lastBuzz = now;
            if (Toybox has :Attention && Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(100, 400)]);
            }
        }
    }

    function strings() as Array<Number> { return Instruments.notes(preset); }
    function targetMidi() as Number { return strings()[noteIndex]; }
    function targetFreq() as Float { return PitchMath.midiToFreq(targetMidi(), a4); }

    function setPreset(p as Number) as Void {
        preset = p;
        noteIndex = 0;
    }

    function setDemo(on as Boolean) as Void {
        source.stop();
        demo = on;
        source = on ? new DemoSource() : new MicSource();
        source.start();
        _hits = 0;
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
        model.begin();
        return [new TunerView(model), new TunerDelegate(model)];
    }

    function onStop(state as Dictionary?) as Void {
        model.finish();
    }
}

function getApp() as TunerApp {
    return Application.getApp() as TunerApp;
}
