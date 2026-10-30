import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class TunerModel {
    const TICK_MS = 100;
    const HOLD_TICKS = 8;
    const BACKLIGHT_MS = 2500;
    const TARGET_WINDOW = 1.5;

    var group as Number = 0;
    var tuning as Number = 0;
    var a4 as Float = 440.0;
    var haptic as Boolean = true;
    var noteIndex as Number = 0;
    var source as PitchSource = new MicSource();

    // Smoothed result for the view. shownCents is null when nothing is heard.
    // shownMatched is true when shownMidi is a string of the chosen tuning.
    var shownMidi as Number = 69;
    var shownCents as Float or Null = null;
    var shownMatched as Boolean = false;

    private var _timer as Timer.Timer = new Timer.Timer();
    private var _m as Float or Null = null;
    private var _cand as Float or Null = null;
    private var _miss as Number = 0;
    private var _hits as Number = 0;
    private var _lastBuzz as Number = -10000;
    private var _lastLight as Number = -10000;

    function begin() as Void {
        source.start();
        _timer.start(method(:tick), TICK_MS, true);
    }

    function finish() as Void {
        _timer.stop();
        source.stop();
    }

    // The menu pauses everything so the UI stays responsive.
    function pause() as Void {
        _timer.stop();
        source.pause();
    }

    function resume() as Void {
        resetTracking();
        source.resume();
        _timer.stop();
        _timer.start(method(:tick), TICK_MS, true);
    }

    function isChromatic() as Boolean { return group == Instruments.CHROMATIC; }
    function strings() as Array<Number> { return Instruments.notes(group, tuning); }
    function tuningCount() as Number { return Instruments.tuningNames(group).size(); }

    function title() as String {
        var g = Instruments.groupNames()[group];
        if (isChromatic() || tuningCount() < 2) { return g; }
        return Instruments.tuningNames(group)[tuning];
    }

    function setGroup(g as Number) as Void {
        group = g;
        tuning = 0;
        noteIndex = 0;
        resetTracking();
    }

    function stepTuning(delta as Number) as Void {
        var n = tuningCount();
        if (n < 2) { return; }
        tuning = (tuning + delta + n) % n;
        noteIndex = 0;
        resetTracking();
    }

    private function resetTracking() as Void {
        _m = null;
        _cand = null;
        _miss = 0;
        _hits = 0;
        shownCents = null;
        shownMatched = false;
    }

    private function updateRange() as Void {
        if (isChromatic()) {
            source.setRange(30.0, 1000.0);
            return;
        }
        var s = strings();
        var lo = s[0];
        var hi = s[0];
        for (var i = 1; i < s.size(); i++) {
            if (s[i] < lo) { lo = s[i]; }
            if (s[i] > hi) { hi = s[i]; }
        }
        source.setRange(PitchMath.midiToFreq(lo, a4) * 0.85, PitchMath.midiToFreq(hi, a4) * 1.2);
    }

    // Runs independently of the view so haptics and backlight work with the screen dim.
    function tick() as Void {
        try {
            step();
        } catch (e) {
            source.status = "Err " + e.getErrorMessage();
            resetTracking();
        }
    }

    private function step() as Void {
        var now = System.getTimer();
        updateRange();

        if (now - _lastLight > BACKLIGHT_MS) {
            _lastLight = now;
            if (Toybox has :Attention && Attention has :backlight) { Attention.backlight(true); }
        }

        var f = source.getFrequency();
        if (f == null) {
            _miss++;
            if (_miss >= HOLD_TICKS) {
                _m = null;
                _cand = null;
            }
        } else {
            _miss = 0;
            fold(69.0 + 12.0 * Math.ln(f / a4) / 0.6931472);
        }
        derive();

        var c = shownCents;
        if (shownMatched && c != null && c.abs() < 6.0) { _hits++; } else { _hits = 0; }
        if (haptic && _hits >= 4 && now - _lastBuzz > 1500) {
            _lastBuzz = now;
            if (Toybox has :Attention && Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(100, 400)]);
            }
        }
    }

    // Exponential smoothing in fractional MIDI units. A new pitch, or a jump, needs two agreeing readings.
    private function fold(m as Float) as Void {
        var cur = _m;
        if (cur != null && (m - cur).abs() <= 0.6) {
            _cand = null;
            _m = cur + 0.3 * (m - cur);
            return;
        }
        var cand = _cand;
        if (cand != null && (m - cand).abs() < 0.4) {
            _m = m;
            _cand = null;
        } else {
            _cand = m;
        }
    }

    // Round to a note, keeping the previous one until the pitch is clearly closer to another.
    private function holdNote(m as Float) as Number {
        if (shownCents != null && (m - shownMidi).abs() <= 0.65) { return shownMidi; }
        return (m + 0.5).toNumber();
    }

    private function derive() as Void {
        var m = _m;
        if (m == null) {
            shownCents = null;
            shownMatched = false;
            return;
        }
        var mid = 0;
        var matched = false;
        if (!isChromatic()) {
            var s = strings();
            var best = noteIndex;
            var bestD = (m - s[noteIndex]).abs();
            for (var i = 0; i < s.size(); i++) {
                var d = (m - s[i]).abs();
                if (d < bestD - 0.3) { bestD = d; best = i; }
            }
            noteIndex = best;
            if (bestD <= TARGET_WINDOW) {
                mid = s[best];
                matched = true;
            }
        }
        if (!matched) { mid = holdNote(m); }
        shownMidi = mid;
        shownMatched = matched;
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
