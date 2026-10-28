import Toybox.Lang;
import Toybox.Math;

module PitchMath {
    const NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

    function midiToFreq(midi as Number, a4 as Float) as Float {
        return a4 * Math.pow(2.0, (midi - 69) / 12.0);
    }

    function noteName(midi as Number) as String {
        return NAMES[midi % 12] + (midi / 12 - 1).format("%d");
    }

    // Signed cents of freq relative to target, clamped to +-50 for display.
    function cents(freq as Float, target as Float) as Float {
        var c = 1200.0 * Math.ln(freq / target) / Math.ln(2.0);
        return c > 50.0 ? 50.0 : (c < -50.0 ? -50.0 : c);
    }
}
