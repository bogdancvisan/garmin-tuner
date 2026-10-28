# Microphone capture & pitch detection on Fenix 8

**Status: UNVERIFIED — must be confirmed against the installed SDK.** No Connect IQ SDK was available when this was scaffolded, and web lookups of the API docs failed.

## What is known / believed
- Connect IQ apps have historically had **no raw microphone (PCM) access**. `Toybox.Media` covers audio *playback* and sync of media content; `Toybox.Attention` plays tones/vibration. Voice features (dictation, assistants) are handled by the OS, not exposed as samples.
- Newer SDKs may add microphone-related APIs; check before assuming either way.

## Phase 0 spike (do this first)
1. In the SDK: search `<SDK>/bin/api.mir` and docs (`doc/`) for `Microphone`, `AudioRecorder`, `Recording`.
2. Add `using Toybox.Microphone;` to a scratch file and compile for `fenix847mm`; also `Toybox.Application has` / `Toybox has :Microphone` at runtime in the simulator.
3. Check the Connect IQ release notes and the Garmin developer forum for the API level that introduced it, and whether it needs a manifest permission.
4. Record the outcome here, and if available set `minApiLevel` and add the permission in `manifest.xml`.

## If raw PCM IS available
- Sample at 8 kHz (decimate if the source is faster); window 1024–2048 samples (lowest bass E1 ≈ 41 Hz needs ≥ 2 periods ≈ 390 samples at 8 kHz; use 1024 for stability).
- **YIN** (cumulative mean normalized difference, threshold ≈ 0.1–0.15, parabolic interpolation) is the best accuracy/cost tradeoff; FFT-based methods are heavier in Monkey C (no SIMD, interpreted). `source/YinDetector.mc` has a skeleton.
- Budget: naive YIN is O(N·τmax). Restrict τ to a band around the selected string (±1 semitone … a fifth), keep arrays preallocated, use integers where possible, process one frame per ~100–200 ms. Watch-app memory is limited (~100s of KB heap on Fenix 8 — check `System.getSystemStats().freeMemory`); a 1024-sample `Array<Number>` costs ~4–8 KB.
- Add a noise gate (RMS threshold) and median-filter successive readings.

## If NOT available — alternatives
1. **Reference-tone mode (implemented):** START plays the target note via `Attention.ToneProfile`; tune by ear. Limits: the watch speaker is tiny and tone frequency/waveform support varies, so treat it as a rough aid.
2. **Manual/demo mode (implemented):** UI works without input (demo needle) for development.
3. **Phone companion:** a phone app does the DSP and sends the detected frequency/cents to the watch via `Toybox.Communications` (phone messages/BLE). Added latency, requires the phone nearby.
4. **External sensor/clip-on tuner** over BLE/ANT+ (long shot).
5. Ask Garmin to expose mic access (developer forum / feature request).
