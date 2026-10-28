import Toybox.Audio;
import Toybox.Audio.Output;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

// Synthesizes a sine reference tone and plays it through the watch speaker.
module ToneGenerator {
    const RATE = 8000;

    function wav(freq as Float, seconds as Number) as ByteArray {
        var n = RATE * seconds;
        var data = new [44 + n * 2]b;
        var dataLen = n * 2;
        putStr(data, 0, "RIFF");
        putInt(data, 4, 36 + dataLen, 4);
        putStr(data, 8, "WAVEfmt ");
        putInt(data, 16, 16, 4);
        putInt(data, 20, 1, 2);
        putInt(data, 22, 1, 2);
        putInt(data, 24, RATE, 4);
        putInt(data, 28, RATE * 2, 4);
        putInt(data, 32, 2, 2);
        putInt(data, 34, 16, 2);
        putStr(data, 36, "data");
        putInt(data, 40, dataLen, 4);

        // Sine via recurrence: y[n] = 2cos(w) y[n-1] - y[n-2]
        var w = 2.0 * Math.PI * freq / RATE;
        var k = 2.0 * Math.cos(w);
        var y1 = Math.sin(-w);
        var y2 = Math.sin(-2.0 * w);
        var fade = RATE / 20;
        for (var i = 0; i < n; i++) {
            var y = k * y1 - y2;
            y2 = y1;
            y1 = y;
            var amp = 12000.0;
            if (i < fade) { amp = amp * i / fade; }
            else if (i > n - fade) { amp = amp * (n - i) / fade; }
            var s = (y * amp).toNumber();
            if (s < 0) { s += 65536; }
            data[44 + 2 * i] = s & 0xFF;
            data[45 + 2 * i] = (s >> 8) & 0xFF;
        }
        return data;
    }

    function putStr(b as ByteArray, at as Number, s as String) as Void {
        var chars = s.toUtf8Array();
        for (var i = 0; i < chars.size(); i++) { b[at + i] = chars[i]; }
    }

    function putInt(b as ByteArray, at as Number, v as Number, len as Number) as Void {
        for (var i = 0; i < len; i++) { b[at + i] = (v >> (8 * i)) & 0xFF; }
    }

    function play(freq as Float) as Boolean {
        if (!(Toybox has :Audio)) { return false; }
        try {
            var format = {
                :containerFormat => Audio.CONTAINER_WAV,
                :codec => Audio.CODEC_LPCM,
                :frequency => Audio.FREQ_8_KHZ,
                :channels => Audio.CHANNEL_MONO
            };
            var builder = new Output.DynamicAudioSourceBuilder({ :format => format });
            builder.append(wav(freq, 2));
            Output.play(builder.complete(), 0);
            return true;
        } catch (e) {
            System.println("Tone failed: " + e.getErrorMessage());
            return false;
        }
    }
}
