# garmin-tuner

Instrument tuner (guitar & more) for Garmin **Fenix 8**, built with Connect IQ (Monkey C).

> **Status:** v0.1 scaffold. UI, presets and tuning math are in place; live microphone pitch detection is **blocked on SDK support** (see [docs/MICROPHONE.md](docs/MICROPHONE.md)). The source has not yet been compiled — the first build may need small fixes, and device IDs must be verified.

## Features
- Presets: Guitar standard, Drop D, DADGAD, Open G, Bass 4/5, Ukulele, Violin, Viola, Cello, Mandolin, Banjo
- String/note selector, target frequency (A4 = 440 Hz), cents needle (green within ±5 ct)
- START plays a reference tone; demo needle for UI testing (menu toggle)

Controls: UP/DOWN = previous/next string · START = reference tone · long-press UP (menu) = instrument picker / demo toggle · BACK = exit.

## Target devices
`fenix847mm`, `fenix8solar47mm`, `fenix8solar51mm`, `fenix8pro47mm` (in `manifest.xml`). **Verify** IDs in the SDK Manager's device list / `<SDK>/Devices/` and adjust.

## Setup
1. Install **JDK 17+**.
2. Install the **Connect IQ SDK Manager** from <https://developer.garmin.com/connect-iq/sdk/>, sign in, download the latest SDK and the Fenix 8 device files.
3. Install **VS Code** + the **Monkey C** extension; run `Monkey C: Verify Installation`, then `Monkey C: Set Current SDK` if prompted.
4. Generate a developer key: `Monkey C: Generate a Developer Key` (keep it safe and **never commit it**; `.gitignore` excludes `developer_key*`/`*.der`).
5. Run in the simulator: F5 (choose `fenix847mm`), or `Monkey C: Run Without Debugging`.
6. Sideload: build a `.prg` and copy it to `GARMIN/APPS` on the watch over USB.

## Build from the command line / CI
```
# Linux/macOS
CIQ_SDK_HOME=~/connectiq-sdk DEVELOPER_KEY=~/developer_key.der ./scripts/build.sh fenix8solar51mm
# Windows
$env:CIQ_SDK_HOME="C:\sdk"; $env:DEVELOPER_KEY="C:\key\developer_key.der"; .\scripts\build.ps1 fenix847mm
```
Output: `bin/GarminTuner-<device>.prg`. `.github/workflows/build.yml` is a template that needs a pre-populated SDK archive URL and a key secret.

## Layout
`manifest.xml`, `monkey.jungle`, `resources/` (strings, drawables), `source/` (`TunerApp`, `TunerView`, `TunerDelegate`, `Instruments`, `PitchMath`, `PitchSource`, `YinDetector`), `scripts/`, `docs/`.

## Microphone summary
Connect IQ has historically given apps no raw mic access. Details, the YIN plan and alternatives (reference tone, phone companion) are in [docs/MICROPHONE.md](docs/MICROPHONE.md).

## Roadmap
- [x] v0.1 Scaffold, UI, presets, reference tone
- [ ] v0.2 Compile on all targets; Phase 0 mic spike; real icon; layout check on 47/51 mm
- [ ] v0.3 Live detection (YIN) if mic API exists, otherwise phone-companion DSP
- [ ] v0.4 A4 calibration, custom tunings, persisted settings, haptic/color in-tune feedback, chromatic mode
- [ ] v1.0 Connect IQ Store release
