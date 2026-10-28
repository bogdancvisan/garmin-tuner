# garmin-tuner

Instrument tuner (guitar & more) for Garmin **Fenix 8**, built with Connect IQ (Monkey C).

> **Status:** v0.2. Live mic pitch detection (`Toybox.Audio.Capture` + YIN) are implemented. Compiles for all four targets and is tested in the simulator with synthetic signals, but **not yet tested on a real watch** (see [docs/MICROPHONE.md](docs/MICROPHONE.md)). Launcher icon is a placeholder.

## Features
- Presets: Guitar standard, Drop D, DADGAD, Open G, Bass 4/5, Ukulele, Violin, Viola, Cello, Mandolin, Banjo
- String/note selector, target frequency (A4 = 440 Hz), cents needle (green within ±5 ct)
- Live mic tuning (YIN): the detected note is always shown with a smoothed needle; strings are detected automatically; the screen is kept lit while tuning
- Menu: pick an instrument (guitar, bass, ukulele, violin, viola, cello, mandolin, banjo) or Chromatic (shows any note); UP/DOWN switch between that instrument's tunings (guitar: standard, drop D, DADGAD, open G/D, half/full step down). Vibration fires only when a string of the chosen tuning is in tune (not in Chromatic).

Controls: START/tap or long-press UP = instrument menu - UP/DOWN = previous/next tuning - BACK = exit.

## Target devices
`fenix847mm`, `fenix8solar47mm`, `fenix8solar51mm`, `fenix8pro47mm` (in `manifest.xml`). **Verify** IDs in the SDK Manager's device list / `<SDK>/Devices/` and adjust.

## Setup
1. Install **JDK 17+**.
2. Install the **Connect IQ SDK Manager** from <https://developer.garmin.com/connect-iq/sdk/>, sign in, download the latest SDK and the Fenix 8 device files.
3. Install **VS Code** + the **Monkey C** extension; run `Monkey C: Verify Installation`, then `Monkey C: Set Current SDK` if prompted.
4. Generate a developer key: `Monkey C: Generate a Developer Key` (keep it safe and **never commit it**; `.gitignore` excludes `developer_key*`/`*.der`).
5. Run in the simulator: F5 (choose `fenix847mm`), or `Monkey C: Run Without Debugging`.
   If you see `Unable to load private key: undefined`, the key isn't set: run `Monkey C: Select Developer Key` or set `"monkeyC.developerKeyPath"` in VS Code user settings.
6. Sideload: build a `.prg` and copy it to `GARMIN/APPS` on the watch over USB.

## Build from the command line / CI
```
# Linux/macOS
CIQ_SDK_HOME=~/connectiq-sdk DEVELOPER_KEY=~/developer_key.der ./scripts/build.sh fenix8solar51mm
# Windows
$env:CIQ_SDK_HOME="C:\sdk"; $env:DEVELOPER_KEY="C:\key\developer_key.der"; .\scripts\build.ps1 fenix847mm
```
Output: `bin/GarminTuner-<device>.prg`. `.github/workflows/build.yml` is a template that needs a pre-populated SDK archive URL and a key secret.

## Run on a real watch (sideload)
No developer mode is needed on the watch.
1. Build for your model: `.\scripts\build.ps1 fenix847mm` (or `fenix8solar47mm`, `fenix8solar51mm`, `fenix8pro47mm`) -> `bin\GarminTuner-<device>.prg`.
2. Connect the watch by USB and copy the `.prg` to `GARMIN\Apps\`, then eject and unplug.
3. Open the app from the watch's Apps list. Accept the microphone permission if prompted.
4. If it crashes, read `GARMIN\Apps\LOGS\CIQ_LOG.YML` on the watch. Close Garmin Express if the watch doesn't mount.

### Troubleshooting a "blocked" app
- **Microphone permission:** the app declares `AudioInput`. On the watch, check Settings > Apps (or the app's entry) > Permissions and allow the microphone. In the Garmin Connect / Connect IQ phone app, check the app's permissions too, and allow microphone access for Garmin Connect in the phone's OS settings.
- **Sideloaded apps and the phone app:** syncing with Connect IQ can show sideloaded apps as unknown; do not uninstall them from the phone app. If it disappears after a sync, copy the `.prg` again.
- **Wrong build:** the `.prg` must match the exact model (47 mm vs 51 mm vs Pro).
- **Collect evidence:** the on-screen status line ("Mic error", "Format unsupported", "No audio API") and `CIQ_LOG.YML` identify the cause.

## Layout
`manifest.xml`, `monkey.jungle`, `resources/` (strings, drawables), `source/` (`TunerApp`, `TunerView`, `TunerDelegate`, `Instruments`, `PitchMath`, `PitchSource`, `YinDetector`), `scripts/`, `docs/`.

## Microphone summary
SDK 9.3.0 provides `Toybox.Audio.Capture` (permission `AudioInput`, API 6.0.3+, supported on Fenix 8). The app captures 8 kHz LPCM and runs YIN. Details: [docs/MICROPHONE.md](docs/MICROPHONE.md).

## Roadmap
- [x] v0.1 Scaffold, UI, presets
- [x] v0.2 Live mic detection (YIN), simulator-tested with synthetic signals
- [ ] v0.3 Real-watch testing/tuning (noise, octave errors, latency, battery); real icon
- [ ] v0.4 A4 calibration, custom tunings, persisted settings, haptic/color in-tune feedback, chromatic mode
- [ ] v1.0 Connect IQ Store release

