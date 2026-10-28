import Toybox.Graphics;
import Toybox.Audio;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;
import Toybox.WatchUi;

(:test)
function testButtons(logger as Logger) as Boolean {
    var m = new TunerModel();
    var d = new TunerDelegate(m);
    d.onNextPage();
    d.onPreviousPage();
    logger.debug("note index " + m.noteIndex);
    return true;
}

(:test)
function testPresets(logger as Logger) as Boolean {
    var m = new TunerModel();
    for (var i = 0; i < Instruments.names().size(); i++) {
        m.setPreset(i);
        for (var j = 0; j < m.strings().size(); j++) {
            m.step(1);
            logger.debug(PitchMath.noteName(m.targetMidi()) + " " + m.targetFreq().format("%.1f"));
        }
    }
    return true;
}

(:test)
function testRender(logger as Logger) as Boolean {
    var m = new TunerModel();
    var v = new TunerView(m);
    var dc = Graphics.createBufferedBitmap({ :width => 454, :height => 454 }).get().getDc();
    for (var demo = 0; demo < 2; demo++) {
        m.setDemo(demo == 1);
        for (var i = 0; i < Instruments.names().size(); i++) {
            m.setPreset(i);
            for (var j = 0; j < m.strings().size(); j++) {
                m.step(1);
                v.onUpdate(dc);
            }
        }
    }
    return true;
}

(:test)
function testYin(logger as Logger) as Boolean {
    var yin = new YinDetector(8000);
    var targets = [30.9, 41.2, 82.4, 110.0, 196.0, 329.6, 440.0, 659.3];
    var ok = true;
    for (var k = 0; k < targets.size(); k++) {
        var t = targets[k] as Float;
        var s = new [1024] as Array<Number>;
        for (var i = 0; i < 1024; i++) {
            s[i] = (8000.0 * Math.sin(2.0 * Math.PI * t * 1.01 * i / 8000.0)).toNumber();
        }
        var f = yin.detect(s, (8000 / (t * 1.5)).toNumber(), (8000 / (t * 0.75)).toNumber());
        logger.debug("target " + t + " -> " + f);
        if (f == null || (f - t * 1.01).abs() > t * 0.01) { ok = false; }
    }
    return ok;
}

(:test)
function testYinWide(logger as Logger) as Boolean {
    var yin = new YinDetector(8000);
    var targets = [41.2, 82.4, 110.0, 196.0, 329.6, 440.0];
    var ok = true;
    for (var k = 0; k < targets.size(); k++) {
        var t = targets[k] as Float;
        var s = new [1024] as Array<Number>;
        for (var i = 0; i < 1024; i++) {
            s[i] = (8000.0 * Math.sin(2.0 * Math.PI * t * i / 8000.0)).toNumber();
        }
        var f = yin.detect(s, (8000 / 1000.0).toNumber(), (8000 / 30.0).toNumber());
        logger.debug("wide " + t + " -> " + f);
        if (f == null || (f - t).abs() > t * 0.02) { ok = false; }
    }
    return ok;
}

(:test)
function testTone(logger as Logger) as Boolean {
    var w = ToneGenerator.wav(110.0, 2);
    logger.debug("wav bytes " + w.size());
    logger.debug("generated"); return w.size() == 44 + 32000;
}

(:test)
function testMenu(logger as Logger) as Boolean {
    var m = new TunerModel();
    var d = new TunerDelegate(m);
    d.onMenu();
    return true;
}
