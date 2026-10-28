import Toybox.Lang;

// YIN pitch detector over signed 16-bit samples.
// CPU is bounded: a coarse pass over every 2nd lag, a sample stride, then exact refinement near the winner.
class YinDetector {
    private var _rate as Number;
    private var _threshold as Float = 0.15;
    private var _samples as Array<Number> = [] as Array<Number>;
    private var _n as Number = 0;
    private var _stride as Number = 2;

    function initialize(sampleRate as Number) {
        _rate = sampleRate;
    }

    private function diff(tau as Number) as Number {
        var sum = 0;
        for (var i = 0; i < _n; i += _stride) {
            var d = _samples[i] - _samples[i + tau];
            sum += d * d / 16;
        }
        return sum;
    }

    // Returns frequency in Hz, or null when there is no confident pitch.
    function detect(samples as Array<Number>, tauMin as Number, tauMax as Number) as Float or Null {
        if (tauMax >= samples.size() / 2) { tauMax = samples.size() / 2 - 1; }
        if (tauMin < 2) { tauMin = 2; }
        if (tauMax <= tauMin + 4) { return null; }

        var want = tauMax > 256 ? tauMax : 256;
        _n = samples.size() - tauMax - 4;
        if (_n > want) { _n = want; }
        _stride = _n / 32;
        if (_stride < 2) { _stride = 2; }
        _samples = samples;

        // Coarse pass over even lags with a running-mean normalisation.
        var running = 0.0;
        var count = 0;
        var best = -1;
        var prev = 1.0;
        for (var tau = 2; tau <= tauMax; tau += 2) {
            var raw = diff(tau);
            running += raw;
            count++;
            var norm = running > 0 ? raw.toFloat() * count / running : 1.0;
            if (tau >= tauMin && norm < _threshold) {
                best = tau;
                prev = norm;
                // Walk down to the local minimum.
                while (best + 2 <= tauMax) {
                    var r2 = diff(best + 2);
                    var n2 = r2.toFloat() * (count + 1) / (running + r2);
                    if (n2 < prev) {
                        best += 2;
                        prev = n2;
                        running += r2;
                        count++;
                    } else { break; }
                }
                break;
            }
        }
        if (best < 0) { return null; }

        // Exact refinement within +-1 lag, then parabolic interpolation.
        var a = diff(best - 1).toFloat();
        var b = diff(best).toFloat();
        var c = diff(best + 1).toFloat();
        var tauF = best.toFloat();
        if (a < b && a <= c) {
            tauF = best - 1.0;
            c = b;
            b = a;
            a = diff(best - 2).toFloat();
        } else if (c < b && c < a) {
            tauF = best + 1.0;
            a = b;
            b = c;
            c = diff(best + 2).toFloat();
        }
        var denom = a - 2.0 * b + c;
        if (denom.abs() > 0.000001) { tauF += (a - c) / (2.0 * denom); }
        if (tauF < 2.0) { return null; }
        return _rate.toFloat() / tauF;
    }
}
