import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

class TunerView extends WatchUi.View {
    private var _model as TunerModel;
    private var _timer as Timer.Timer = new Timer.Timer();

    function initialize(model as TunerModel) {
        View.initialize();
        _model = model;
    }

    function onShow() as Void {
        _timer.start(method(:refresh), 100, true);
    }

    function onHide() as Void {
        _timer.stop();
    }

    function refresh() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var target = _model.targetFreq();
        var freq = _model.source.getFrequency(target);
        var midi = _model.targetMidi();

        // Instrument and string selector
        dc.drawText(cx, h * 0.08, Graphics.FONT_XTINY, Instruments.names()[_model.preset], Graphics.TEXT_JUSTIFY_CENTER);
        var strs = _model.strings();
        for (var i = 0; i < strs.size(); i++) {
            var x = cx + (i - (strs.size() - 1) / 2.0) * (w * 0.13);
            dc.setColor(i == _model.noteIndex ? Graphics.COLOR_YELLOW : Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(x, h * 0.2, Graphics.FONT_XTINY, PitchMath.NAMES[strs[i] % 12], Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Target note
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(cx, h * 0.36, Graphics.FONT_NUMBER_MEDIUM, PitchMath.noteName(midi), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Gauge: -50..+50 cents mapped to +-60 degrees around a pivot below the note
        var px = cx;
        var py = cy + h * 0.32;
        var r = w * 0.38;
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        for (var c = -50; c <= 50; c += 10) {
            var a = Math.toRadians(-90 + c * 1.2);
            var inner = (c == 0) ? r - w * 0.08 : r - w * 0.04;
            dc.drawLine(px + r * Math.cos(a), py + r * Math.sin(a), px + inner * Math.cos(a), py + inner * Math.sin(a));
        }

        if (freq == null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(cx, h * 0.68, Graphics.FONT_XTINY, WatchUi.loadResource(Rez.Strings.NoSignal), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(cx, h * 0.8, Graphics.FONT_XTINY, target.format("%.1f") + " Hz", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var cents = PitchMath.cents(freq, target);
        var inTune = cents.abs() < 5.0;
        dc.setColor(inTune ? Graphics.COLOR_GREEN : (cents.abs() < 20.0 ? Graphics.COLOR_YELLOW : Graphics.COLOR_RED), Graphics.COLOR_BLACK);
        dc.setPenWidth(5);
        var na = Math.toRadians(-90 + cents * 1.2);
        dc.drawLine(px, py, px + (r - w * 0.02) * Math.cos(na), py + (r - w * 0.02) * Math.sin(na));
        dc.fillCircle(px, py, 6);
        dc.drawText(cx, h * 0.68, Graphics.FONT_SMALL, (cents >= 0 ? "+" : "") + cents.format("%.0f") + " ct", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(cx, h * 0.8, Graphics.FONT_XTINY, target.format("%.1f") + " Hz", Graphics.TEXT_JUSTIFY_CENTER);
    }
}

