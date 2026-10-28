import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class TunerModel {
    const TICK_MS = 100;

    var preset as Number = 0;
    var noteIndex as Number = 0;
    var a4 as Float = 440.0;
    var demo as Boolean = false;
    var haptic as Boolean = true;
    var chromatic as Boolean = false;
    var autoString as Boolean = true;
    var source as PitchSource = new MicSource();

    // Smoothed result for the view; shownCents is null when there is no signal.
    var shownMidi as Number = 40;
    var shownCents as Float or Null = null;

    private var _timer as Timer.Timer = new Timer.Timer();
    private var _m as Float or Null = null;
    private var _cand as Float or Null = null;
    private var _miss as Number = 0;
    private var _switch as Number = 0;
    private var _hits as Number = 0;
    private var _lastBuzz as Number = -10000;

    function begin() as Void {
        source.start();
        _timer.start(method(:tick), TICK_MS, true);
    }

    function finish() as Void {
        _timer.stop();
        source.stop();
    }

    function strings() as Array<Number> { return Instruments.notes(preset); }
    function targetMidi() as Number { return strings()[noteIndex]; }
    function targetFreq() as Float { return PitchMath.midiToFreq(targetMidi(), a4); }

    function setPreset(p as Number) as Void {
        preset = p;
        chromatic = false;
        noteIndex = 0;
        resetTracking();
    }

    function setChromatic() as Void {
        chromatic = true;
        resetTracking();
    }

    function setAutoString(on as Boolean) as Void {
        autoString = on;
        resetTracking();
    }

    function setDemo(on as Boolean) as Void {
        source.stop();
        demo = on;
        source = on ? new DemoSource() : new MicSource();
        source.start();
        resetTracking();
    }

    function step(delta as Number) as Void {
        var n = strings().size();
        noteIndex = (noteIndex + delta + n) % n;
        chromatic = false;
        resetTracking();
    }

    private function resetTracking() as Void {
        _m = null;
        _cand = null;
        _miss = 0;
        _switch = 0;
        _hits = 0;
        shownCents = null;
        shownMidi = targetMidi();
    }

    private function updateRange() as Void {
        if (chromatic) {
            source.setRange(30.0, 1000.0);
        } else if (autoString) {
            var s = strings();
            var lo = s[0];
            var hi = s[0];
            for (var i = 1; i < s.size(); i++) {
                if (s[i] < lo) { lo = s[i]; }
                if (s[i] > hi) { hi = s[i]; }
            }
            source.setRange(PitchMath.midiToFreq(lo, a4) * 0.85, PitchMath.midiToFreq(hi, a4) * 1.2);
        } else {
            var t = targetFreq();
            source.setRange(t * 0.75, t * 1.5);
        }
    }

    // Runs independently of the view so haptic feedback works with the screen off.
    function tick() as Void {
        source.hint = targetFreq();
        updateRange();

        var f = source.getFrequency();
        if (f == null) {
            _miss++;
            if (_miss >= 4) {
                _m = null;
                _cand = null;
            }
        } else {
            _miss = 0;
            fold(69.0 + 12.0 * Math.ln(f / a4) / 0.6931472);
        }
        derive();

        var c = shownCents;
        if (c != null && c.abs() < 6.0) { _hits++; } else { _hits = 0; }
        var now = System.getTimer();
        if (haptic && _hits >= 4 && now - _lastBuzz > 1500) {
            _lastBuzz = now;
            if (Toybox has :Attention && Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(100, 400)]);
            }
        }
    }

    // Exponential smoothing in fractional MIDI units; a jump needs two agreeing readings.
    private function fold(m as Float) as Void {
        var cur = _m;
        if (cur == null) {
            _m = m;
        } else if ((m - cur).abs() > 0.6) {
            var cand = _cand;
            if (cand != null && (m - cand).abs() < 0.3) {
                _m = m;
                _cand = null;
            } else {
                _cand = m;
            }
        } else {
            _cand = null;
            _m = cur + 0.3 * (m - cur);
        }
    }

    private function derive() as Void {
        var m = _m;
        if (m == null) {
            shownCents = null;
            return;
        }
        var mid;
        if (chromatic) {
            mid = (m + 0.5).toNumber();
        } else if (autoString) {
            var s = strings();
            var best = 0;
            var bestD = 1000.0;
            for (var i = 0; i < s.size(); i++) {
                var d = (m - s[i]).abs();
                if (d < bestD) { bestD = d; best = i; }
            }
            if (best != noteIndex) {
                _switch++;
                if (_switch >= 3) {
                    noteIndex = best;
                    _switch = 0;
                }
            } else {
                _switch = 0;
            }
            mid = targetMidi();
        } else {
            mid = targetMidi();
        }
        shownMidi = mid;
        var c = (m - mid) * 100.0;
        shownCents = c > 50.0 ? 50.0 : (c < -50.0 ? -50.0 : c);
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
