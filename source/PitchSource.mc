import Toybox.Audio;
import Toybox.Audio.Capture;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

// A source of detected frequency. Returns null when there is no signal.
class PitchSource {
    var status as String = "";
    var hint as Float = 440.0;
    protected var _loHz as Float = 50.0;
    protected var _hiHz as Float = 1000.0;

    function initialize() {}
    function start() as Void {}
    function stop() as Void {}

    // Frequency band that pitch detection should search.
    function setRange(loHz as Float, hiHz as Float) as Void {
        _loHz = loHz;
        _hiHz = hiHz;
    }

    function getFrequency() as Float or Null { return null; }
}

// Wobbles around the hint so the needle UI can be exercised without a mic.
class DemoSource extends PitchSource {
    function initialize() { PitchSource.initialize(); status = "Demo"; }

    function getFrequency() as Float or Null {
        var ms = System.getTimer() % 8000;
        var cents = 40.0 * Math.sin(ms / 8000.0 * 2.0 * Math.PI);
        return hint * Math.pow(2.0, cents / 1200.0);
    }
}

// Live pitch from the microphone: 8 kHz mono LPCM, 1024-sample windows, YIN.
class MicSource extends PitchSource {
    const RATE = 8000;
    const WINDOW_SAMPLES = 1024;
    const MIN_RMS = 120;
    const STALE_MS = 700;

    private var _yin as YinDetector = new YinDetector(RATE);
    private var _freq as Float or Null = null;
    private var _stamp as Number = 0;
    private var _ready as Boolean = false;

    function initialize() {
        PitchSource.initialize();
        status = "Mic idle";
    }

    function start() as Void {
        if (!(Toybox has :Audio)) {
            status = "No audio API";
            return;
        }
        var format = {
            :containerFormat => Audio.CONTAINER_WAV,
            :codec => Audio.CODEC_LPCM,
            :frequency => Audio.FREQ_8_KHZ,
            :channels => Audio.CHANNEL_MONO
        };
        if (!Capture.isFormatSupported(format)) {
            status = "Format unsupported";
            return;
        }
        try {
            Capture.initializeAudioCapture(self, {
                :format => format,
                :windowSize => WINDOW_SAMPLES * 2,
                :windowFilledBehavior => Capture.WINDOW_FILLED_CONTINUE,
                :filters => []
            });
            Capture.start();
            _ready = true;
            status = "Listening...";
        } catch (e) {
            status = "Mic error";
            System.println("Capture init failed: " + e.getErrorMessage());
        }
    }

    function stop() as Void {
        if (_ready && Capture.getState() == Capture.CAPTURE_CAPTURING) {
            Capture.stop();
        }
        _ready = false;
    }

    function getFrequency() as Float or Null {
        if (_freq != null && System.getTimer() - _stamp > STALE_MS) { _freq = null; }
        return _freq;
    }

    function onData(audioData as ByteArray) as Void {
        try {
            process(audioData);
        } catch (e) {
            status = "Err " + e.getErrorMessage();
        }
    }

    private function process(audioData as ByteArray) as Void {
        var offset = 0;
        // Skip a WAV header if the container adds one.
        if (audioData.size() > 44 && audioData[0] == 0x52 && audioData[1] == 0x49) { offset = 44; }
        var count = (audioData.size() - offset) / 2;

        var tauMax = (RATE / _loHz).toNumber();
        var tauMin = (RATE / _hiHz).toNumber();
        var need = (tauMax > 256 ? tauMax : 256) + tauMax + 4;
        if (count < need) { return; }
        count = need;

        var samples = new [count] as Array<Number>;
        var energy = 0;
        for (var i = 0; i < count; i++) {
            var v = audioData[offset + 2 * i] | (audioData[offset + 2 * i + 1] << 8);
            if (v > 32767) { v -= 65536; }
            samples[i] = v;
            energy += (v * v) / 256;
        }
        var rms = Math.sqrt(energy.toFloat() / count * 256.0);
        if (rms < MIN_RMS) {
            status = "Too quiet";
            return;
        }

        var f = _yin.detect(samples, tauMin, tauMax);
        if (f == null) {
            status = "No pitch";
            return;
        }
        _freq = f;
        _stamp = System.getTimer();
        status = "Listening...";
    }

    function onError(error as Capture.Error) as Void {
        status = "Mic error " + error;
        System.println("Capture error: " + error);
    }

    function onComplete() as Void {}
}
