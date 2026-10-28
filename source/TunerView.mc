import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

class TunerView extends WatchUi.View {
    private var _model as TunerModel;
    private var _timer as Timer.Timer = new Timer.Timer();
    private var _needle as Float or Null = null;

    function initialize(model as TunerModel) {
        View.initialize();
        _model = model;
    }

    function onShow() as Void {
        _timer.start(method(:refresh), 66, true);
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
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var cents = _model.shownCents;
        var midi = _model.shownMidi;

        // Detected note, always shown while a pitch is heard
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        var noteText = cents == null ? "--" : PitchMath.noteName(midi);
        dc.drawText(cx, h * 0.27, Graphics.FONT_NUMBER_MEDIUM, noteText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Gauge: -50..+50 cents mapped to +-60 degrees around a pivot below the note
        var px = cx;
        var py = h * 0.8;
        var r = w * 0.35;
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        for (var c = -50; c <= 50; c += 10) {
            var a = Math.toRadians(-90 + c * 1.2);
            var inner = (c == 0) ? r - w * 0.08 : r - w * 0.04;
            dc.drawLine(px + r * Math.cos(a), py + r * Math.sin(a), px + inner * Math.cos(a), py + inner * Math.sin(a));
        }

        if (cents == null) {
            _needle = null;
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(cx, h * 0.6, Graphics.FONT_XTINY, _model.source.status, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(cx, h * 0.88, Graphics.FONT_XTINY, _model.title(), Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        // Ease the drawn needle toward the smoothed reading
        var shown = _needle;
        if (shown == null) { shown = cents; } else { shown = shown + 0.2 * (cents - shown); }
        _needle = shown;

        var inTune = _model.shownMatched && cents.abs() < 5.0;
        dc.setColor(inTune ? Graphics.COLOR_GREEN : (cents.abs() < 20.0 ? Graphics.COLOR_YELLOW : Graphics.COLOR_RED), Graphics.COLOR_BLACK);
        var na = Math.toRadians(-90 + shown * 1.2);
        var ca = Math.cos(na);
        var sa = Math.sin(na);
        var len = r - w * 0.02;
        var bw = w * 0.015;
        dc.fillPolygon([
            [px + len * ca, py + len * sa],
            [px - bw * sa, py + bw * ca],
            [px + bw * sa, py - bw * ca]
        ]);
        dc.fillCircle(px, py, w * 0.02);
        dc.drawText(cx, h * 0.6, Graphics.FONT_SMALL, (cents >= 0 ? "+" : "") + cents.format("%.0f") + " ct", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(cx, h * 0.88, Graphics.FONT_XTINY, _model.title(), Graphics.TEXT_JUSTIFY_CENTER);
    }
}
