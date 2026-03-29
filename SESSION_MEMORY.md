# TONESCOPE — Session Memory

## Project Overview
Professional music tuner webapp mockup — single-file HTML app at `index.html` (~95KB, ~1853 lines).

## What Was Built
A phone-dimension webapp with **4 main sections** + bottom management bar:

### 1. Spectrum (Hz line graph) — 20% height
- Smooth quadratic bezier line graph of frequency data up to 5kHz
- Gradient fill underneath, glowing stroke, trail/decay effect
- **X-axis labels**: 0, 1k, 2k, 3k, 4k, 5k with tick marks
- 14px bottom strip reserved for labels
- **"● LIVE" badge** (top-right) when mic is active source
- **Background color changes** between live mode (darker) and sample mode (lighter `rgba(28,32,55)`)
- 6px top padding to avoid phone frame clipping

### 2. Tuner (arc meter) — 32.5% height
- **~153° arc** (`arcSpan = Math.PI * 0.85`) with ±50 cents range
- Color zones: green (±5¢ with glow), amber (±20¢), red (±50¢)
- 10px thick arc with base track, rounded caps
- Smooth needle with configurable inertia (`S.tunerLerp`, default 0.08)
- **50% needle root masked** with background circle + 10px extra — labels drawn inside mask
- **Note name, Hz (15px), and cents (14px)** drawn high inside the mask area
- Tick marks every 5¢, labels at ±25/±50/0
- Hz labels on outer arc for current note
- **dB indicator** — vertical bar at top-right corner, RMS-based, gradient green→amber→red, 10px labels
- Padding: 28px sides, 18px top, 30px bottom
- Background darkens in live mode (`rgba(4,5,12)`)
- **Tappable** to toggle live/sample mode (with spectrum canvas)
- **Reference pitch control** `[− A440 +]` — centered at bottom, adjustable A392–A494 Hz, hold to repeat
- **Pitch player** `[♭ 🔈 C4 ♯]` — next to A440 control, plays sine tone at selected note through analyser so tuner follows it; semitone up/down buttons; tap to play/stop
- **Sensitivity setting** — Low/Medium/High in settings, controls lerp (0.04–0.18), confidence threshold (0.75–0.88), RMS minimum (0.005–0.015)

### 3. Metronome — 22% height
- **Beat triangles** (pointing right →) at top, tappable to start/stop
- **BPM horizontal scroll wheel** with ± and tempo jump buttons: `[‹][-][--BPM--][+][›]`
  - Max-width 220px, drag to adjust 20–300 BPM
  - **‹ / ›** jump to prev/next tempo marking (Grave→Largo→...→Prestissimo)
  - **Tempo marking label** below dial shows closest marking name (e.g. "Allegro")
  - **Tap tempo** — tap anywhere on BPM track, averages last 8 taps, 2s timeout
  - Green flash on each tap, "TAP TEMPO" hint below
  - BPM label overlaps scroll track with fade background
  - +/- buttons: hold to repeat at 120ms interval
- **Time signature combo dial** — top-right corner, single vertical scroll picker
  - 12 presets: 2/2, 2/4, 3/4, 4/4, 5/4, 3/8, 6/8, 7/8, 9/8, 12/8, 5/8, 6/4
  - 36×48px track, 16px items, prev/next visible
  - Changes beats and denominator together, restarts metronome if playing
- **Beat pattern button** — bottom-right, tap to cycle:
  - Standard (`♩ ♩ ♩ ♩`): accent beat 1, normal others
  - Swing (`♩‿♪ ♩‿♪`): triplet feel, ghost note at 2/3 of each beat
  - March (`𝅘𝅥𝅯 ♩ 𝅘𝅥𝅯 ♩`): accent on beats 1 and midpoint
- **Bar counter** — bottom-left, increments each completed measure, with ↺ reset button
- Web Audio API lookahead scheduler for sample-accurate timing
- Click sounds: accent 1200Hz/0.35vol, normal 880Hz/0.18vol, ghost 660Hz/0.10vol, swing 660Hz/0.12vol

### 4. Waveform + Recording — flex:1, min 100px
- **iOS Voice Memo style** scrubbing: center indicator fixed (1px thin), waveform slides on drag
- Peaks at 100/sec density, 2.5px per peak
- **X-axis time labels** — auto-scaling intervals (0.5s–60s), tick marks + `m:ss` labels
- During recording: waveform grows from left
- After recording: center-indicator mode with played/upcoming color distinction
- Record / Stop / Play buttons (3 buttons)
- Center indicator stops above time label area

### 5. Recording Manager Bar (bottom, 38px tall)
- Full-width bar: `[⚙ | ← Rec 1 → | +]`
- **Gear button** (left, 40px) — opens settings panel
- **Recording dial wheel** (center) — swipe left/right to switch recordings
  - Centered to app width using `getBoundingClientRect()` offset calculation
  - Active item bright, adjacent at 55%, others at 35%, edge fades
  - Items are 100px wide, positioned absolutely within bar
- **+ button** (right, 40px) — adds new empty recording slot
- **Swipe up** on bar → reveals **action bar**: `[ Share | Rename | Delete ]`
  - 34px thin bar, animates height 0→34px
  - Share exports as WAV, Rename prompts, Delete removes slot
- 6px bottom margin to avoid phone frame clipping

### 6. Settings Panel (push-up design)
- Gear icon toggles settings — **entire app content pushes upward** by ~70%
- `.app-inner` wraps both `.app-content` and `.settings-panel`
- Smooth cubic-bezier transition on transform
- **Sections**:
  - Appearance: Light/Dark mode toggle
  - Language: English, 繁體中文, 日本語, Español (dropdown)
  - Tuner: Reference Pitch (A=440 Hz), **Sensitivity** (Low/Medium/High dropdown)
  - Audio: Metronome Volume
  - About: TONESCOPE v1.0

## Key Behaviors
- **Tap startup overlay** → initializes AudioContext + mic
- **Live mode**: spectrum + tuner update from mic via AnalyserNode (darker backgrounds, LIVE badge)
- **Recording mode**: all components update from live mic; MediaRecorder captures audio
- **Playback mode**: audio routed through AnalyserNode → all components update from playback
- **Paused mode**: offline analysis at scrub position using custom JS FFT + autocorrelation
- **Live override**: tap spectrum/tuner while paused → switches to live mic (tap again or scrub to go back)
- **Recording management**: multiple recording slots, swipe dial to switch, + to add, swipe up for actions
- **Pitch player**: sine oscillator routed through analyser + output gain, tuner tracks the played note

## Technical Architecture

### Audio Graph
```
Live/Recording:  Mic → AnalyserNode → GainNode(0) → Destination  (silent)
Playback:        BufferSource → AnalyserNode → GainNode(1) → Destination  (audible)
Metronome:       Oscillator → MetronomeGain → Destination  (separate path)
Pitch Player:    Oscillator → GainNode(0.15) → AnalyserNode + OutputGain → Destination
```

### Pitch Detection
- NSDF-style normalized autocorrelation with parabolic interpolation
- Lag range: sampleRate/4200 to sampleRate/45 (~45–4200 Hz)
- Configurable via sensitivity: confidence threshold (`S.tunerConfidence`), RMS minimum (`S.tunerRmsMin`)
- `let A4 = 440` — mutable reference pitch, adjustable 392–494 Hz

### Offline Analysis (paused/scrubbing)
- `simpleFFT()`: Radix-2 Cooley-Tukey FFT with Hanning window
- `analyzeAtPosition(posSec)`: 2048-sample window, runs FFT + autocorrelation

### State Machine
`idle → live → recording → paused → playback → paused`
- `liveOverride` flag for mic detection while paused with recording

### Metronome Patterns
- `standard`: accent on beat 0, normal on all others
- `swing`: normal beat + ghost note at 2/3 beat interval (triplet feel)
- `march`: accent on beats 0 and midpoint, normal on others

### Tempo Markings
Grave(35) → Largo(50) → Larghetto(63) → Adagio(72) → Andante(84) → Moderato(104) → Allegretto(116) → Allegro(132) → Vivace(166) → Presto(192) → Prestissimo(240)

### HTML Structure
```
.app (overflow:hidden, viewport size)
  .app-inner (170% tall, slides up for settings)
    .app-content (100dvh — all sections)
      .startup (overlay)
      .sec-spectrum (canvas, 20%, 6px top padding)
      .sec-tuner (canvas, 32.5%, ref-pitch-ctrl + pitch-player-ctrl)
      .sec-metro (metronome controls, 22%)
      .sec-wave (waveform + controls, flex:1 min 100px)
      .rec-actions (share/rename/delete bar, height-animated)
      .rec-bar (gear | dial wheel | +, 38px, 6px bottom margin)
    .settings-panel (70% — settings body)
```

### i18n System
- `I18N` object with `en`, `zh`, `ja`, `es` keys
- `t(key)` function for lookups
- `applyLang()` updates all DOM text + canvas labels + sensitivity dropdown
- `curLang` tracks current language
- Keys include: sensitivity, sensLow, sensMed, sensHigh (and all originals)

## Design System
- **Fonts**: Chakra Petch (display/UI), Share Tech Mono (numbers/readings)
- **Colors**: `--accent: #00e89a`, `--warning: #ffb020`, `--danger: #ff3d5a`
- **Dark bg**: `#060810` with radial gradient, panels at `#0c0e18`
- **Light theme**: CSS custom properties override via `.app.light` class
- **Effects**: Noise texture overlay (SVG turbulence, 25% opacity)
- **Layout**: max-width 430px, 98vh/1100px tall, phone-frame border-radius on desktop

## File Structure
```
demo/
  index.html          — Complete single-file app (~95KB, ~1853 lines)
  SESSION_MEMORY.md   — This file
```
