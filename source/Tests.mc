import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;
import Toybox.WatchUi;

(:test)
function testTunings(logger as Logger) as Boolean {
    var m = new TunerModel();
    var groups = Instruments.groupNames();
    for (var g = 0; g < groups.size(); g++) {
        m.setGroup(g);
        for (var t = 0; t < m.tuningCount(); t++) {
            m.stepTuning(1);
            logger.debug(m.title() + " " + m.strings().size() + " strings");
        }
    }
    return true;
}

(:test)
function testButtons(logger as Logger) as Boolean {
    var m = new TunerModel();
    var d = new TunerDelegate(m);
    d.onNextPage();
    d.onPreviousPage();
    return m.tuning == 0;
}

(:test)
function testRender(logger as Logger) as Boolean {
    var m = new TunerModel();
    var v = new TunerView(m);
    var dc = Graphics.createBufferedBitmap({ :width => 454, :height => 454 }).get().getDc();
    for (var g = 0; g < Instruments.groupNames().size(); g++) {
        m.setGroup(g);
        v.onUpdate(dc);
    }
    return true;
}

(:test)
function testYin(logger as Logger) as Boolean {
    var yin = new YinDetector(8000);
    var targets = [41.2, 82.4, 110.0, 196.0, 329.6, 440.0];
    var ok = true;
    for (var k = 0; k < targets.size(); k++) {
        var t = targets[k] as Float;
        var s = new [1024] as Array<Number>;
        for (var i = 0; i < 1024; i++) {
            s[i] = (8000.0 * Math.sin(2.0 * Math.PI * t * i / 8000.0)).toNumber();
        }
        var f = yin.detect(s, 8, (8000 / 30.0).toNumber());
        logger.debug("target " + t + " -> " + f);
        if (f == null || (f - t).abs() > t * 0.02) { ok = false; }
    }
    return ok;
}
