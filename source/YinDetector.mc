import Toybox.Lang;

// Pure-integer-friendly YIN pitch detector skeleton, kept for when raw PCM is available.
// Input: signed 16-bit samples decimated to ~8 kHz, window of 1024 (>= 2 periods of lowest string).
class YinDetector {
    private var _rate as Number;
    private var _threshold as Float;

    function initialize(sampleRate as Number) {
        _rate = sampleRate;
        _threshold = 0.15;
    }

    // Returns frequency in Hz or null if no confident pitch. tauMin/tauMax restrict the
    // search to the selected string (saves CPU and avoids octave errors).
    function detect(samples as Array<Number>, tauMin as Number, tauMax as Number) as Float or Null {
        var n = samples.size() / 2;
        if (tauMax >= n) { tauMax = n - 1; }
        var diff = new [tauMax + 1] as Array<Float>;
        var running = 0.0;
        diff[0] = 1.0;
        var bestTau = -1;
        for (var tau = 1; tau <= tauMax; tau++) {
            var sum = 0.0;
            for (var i = 0; i < n; i++) {
                var d = samples[i] - samples[i + tau];
                sum += d * d;
            }
            running += sum;
            diff[tau] = running > 0.0 ? sum * tau / running : 1.0;
            if (tau >= tauMin && diff[tau] < _threshold) {
                bestTau = tau;
                break;
            }
        }
        if (bestTau < 0) { return null; }
        return _rate.toFloat() / bestTau;
    }
}
