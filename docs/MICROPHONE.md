# Microphone capture & pitch detection on Fenix 8

**Status: raw microphone capture IS available** in Connect IQ SDK 9.3.0 via `Toybox.Audio` (API 6.0.3+), on Fenix 8 (43/47/51 mm, Solar, Pro) and other recent devices. (An earlier version of this doc wrongly said it was missing: the module is `Audio`, not `Microphone`.)

## API summary
- `Toybox.Audio.Capture` — permission `AudioInput` (manifest `<iq:uses-permission id="AudioInput"/>`).
  - `Capture.isFormatSupported(format)`, `Capture.initializeAudioCapture(callbacks, settings)`, `Capture.start()/stop()`.
  - Callbacks: `onData(ByteArray)`, `onError(error)`, `onComplete()`.
  - Formats: LPCM (16-bit samples) or Opus; 8 / 11.025 / 12 / 16 / 22.05 / 24 / 32 / 44.1 kHz; mono/stereo; WAV or OGG container.
  - `:windowSize` in bytes, `:windowFilledBehavior` (`WINDOW_FILLED_CONTINUE` for streaming), optional `FILTER_NREC` noise reduction (ignored by the simulator).
  - Foreground only; not available to watch faces, data fields or widgets (this is a watch-app, so fine).
- `Toybox.Audio.Output` — permission `AudioOutput`; `play()` accepts bundled resources, `DynamicAudioSourceBuilder` (runtime-generated WAV) or streaming sources.

## What the app does
- `MicSource` (`source/PitchSource.mc`): 8 kHz mono LPCM, 1024-sample windows (2048 bytes), RMS noise gate, then YIN (`source/YinDetector.mc`).
- YIN is restricted to a lag band around the selected string (0.75x to 1.5x of the target frequency), uses a sample stride and integer maths to stay within the watchdog limit. Parabolic interpolation refines the lag.
- Verified headless in the simulator (`source/Tests.mc`): synthetic sines from 31 Hz (B0) to 659 Hz detected within ~1.5 % with no watchdog errors. **Not yet verified with a real microphone** — the WAV header handling (44-byte skip if `RIFF` present) and noise threshold (`MIN_RMS`) may need tuning on a watch.
- Reference tone (`source/ToneGenerator.mc`): synthesizes a 2 s sine WAV and plays it via `Output`. **Off by default**: in SDK 9.3.0 the simulator process crashes on `Output.play` with this source (generation and `complete()` work). Enable via menu "Ref. tone (START)" to test on a real watch.
- `Attention.playTone` is not suitable: it is meant for beeps (2.5–10 kHz examples), not 80–660 Hz.

## Next steps / risks
- Test on real hardware: latency, noise rejection, harmonics (octave errors on low strings), battery drain from continuous capture.
- Tune `threshold` (0.15), `MIN_RMS`, window size; consider smoothing (median of last 3 readings).
- Investigate the simulator `Output.play` crash (try other formats/rates, resource audio, streaming source) and report to Garmin if it is a simulator bug.
