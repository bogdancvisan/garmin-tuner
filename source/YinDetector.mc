import Toybox.Lang;

// YIN pitch detector over signed 16-bit samples.
// CPU is bounded by the tau range (set per target string) and a sample stride.
class YinDetector {
    private var _rate as Number;
    private var _threshold as Float = 0.15;

    function initialize(sampleRate as Number) {
        _rate = sampleRate;
    }

    // Returns frequency in Hz, or null when there is no confident pitch.
    function detect(samples as Array<Number>, tauMin as Number, tauMax as Number) as Float or Null {
        if (tauMax >= samples.size() / 2) { tauMax = samples.size() / 2 - 1; }
        if (tauMin < 2) { tauMin = 2; }
        if (tauMax <= tauMin + 2) { return null; }

        // Keep the per-call work small: real watches enforce a watchdog the simulator does not.
        var n = samples.size() - tauMax - 2;
        var want = tauMax > 256 ? tauMax : 256;
        if (n > want) { n = want; }
        var stride = n / 40;
        if (stride < 2) { stride = 2; }
        var d = new [tauMax + 2] as Array<Float>;
        var running = 0.0;
        d[0] = 1.0;
        for (var tau = 1; tau <= tauMax + 1; tau++) {
            var sum = 0;
            for (var i = 0; i < n; i += stride) {
                var diff = samples[i] - samples[i + tau];
                sum += diff * diff / 16;
            }
            running += sum;
            d[tau] = running > 0 ? sum.toFloat() * tau / running : 1.0;
        }

        // First dip below threshold at/after tauMin, then walk down to its local minimum.
        var best = -1;
        for (var tau = tauMin; tau <= tauMax; tau++) {
            if (d[tau] < _threshold) {
                while (tau + 1 <= tauMax && d[tau + 1] < d[tau]) { tau++; }
                best = tau;
                break;
            }
        }
        if (best < 0) { return null; }

        // Parabolic interpolation around the minimum.
        var a = d[best - 1];
        var b = d[best];
        var c = d[best + 1];
        var denom = a - 2.0 * b + c;
        var tauF = best.toFloat();
        if (denom.abs() > 0.000001) { tauF += (a - c) / (2.0 * denom); }
        return _rate.toFloat() / tauF;
    }
}
