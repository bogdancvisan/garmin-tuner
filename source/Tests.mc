import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;
import Toybox.WatchUi;

(:test)
function testButtons(logger as Logger) as Boolean {
    var m = new TunerModel();
    var d = new TunerDelegate(m);
    d.onSelect();
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
function testMenu(logger as Logger) as Boolean {
    var m = new TunerModel();
    var d = new TunerDelegate(m);
    d.onMenu();
    return true;
}
