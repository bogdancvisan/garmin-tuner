import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

// A source of detected frequency. Returns null when there is no signal.
class PitchSource {
    function initialize() {}
    function getFrequency(target as Float) as Float or Null { return null; }
}

// Placeholder for live detection. Raw mic PCM is not known to be available
// to Connect IQ apps (see docs/MICROPHONE.md); wire a YIN detector here if it is.
class MicSource extends PitchSource {
    function initialize() { PitchSource.initialize(); }
}

// Wobbles around the target so the needle UI can be exercised in the simulator/on device.
class DemoSource extends PitchSource {
    function initialize() { PitchSource.initialize(); }

    function getFrequency(target as Float) as Float or Null {
        var ms = System.getTimer() % 8000;
        var cents = 40.0 * Math.sin(ms / 8000.0 * 2.0 * Math.PI);
        return target * Math.pow(2.0, cents / 1200.0);
    }
}
