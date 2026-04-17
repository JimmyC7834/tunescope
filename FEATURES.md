# ToneScope — Feature Backlog

Suggested features identified during store submission review. Grouped by section.

---

## Tuner

| Feature | Description | Priority |
|---|---|---|
| **Custom tuning presets** | Save and switch between alternate tunings (EADGBE, Drop D, DADGAD, open G, etc.) from the tuner config panel | High |
| **Capo / transpose offset** | User taps capo fret number; tuner adjusts displayed note so a guitarist can tune without removing the capo | High |
| **Response Speed control** | Expose the internal `tunerLerp` value as a slider in the tuner config panel (currently only Low/Med/High sensitivity steps exist) | Medium |
| **Strobe tuner mode** | Classic rotating disc visualization; preferred by brass, wind, and orchestral players for very fine-grained tuning | Medium |
| **Chord detection** | Identify common chords from simultaneous harmonics in the spectrum (e.g. detect a major triad from three peaks) | Low |

---

## Metronome

| Feature | Description | Priority |
|---|---|---|
| **Tempo trainer** | Automatically increase BPM by a set amount every N bars — essential for practicing difficult passages up to speed | High |
| **Haptic feedback** | Vibrate on beat 1 (or all beats) via `navigator.vibrate()` — hugely useful for drummers and in loud environments | High |
| **Setlist / sequence mode** | Chain multiple BPM + time signature steps with automatic transitions; useful for songs with tempo changes | Medium |
| **Subdivision markers** | Show 8th / 16th note grid lines on the beat triangle display | Medium |
| **Practice session timer** | Auto-stop metronome after a set duration (e.g. 5 min practice blocks) | Low |

---

## Recording / Waveform

| Feature | Description | Priority |
|---|---|---|
| **Trim handles** | Drag in/out point markers on the waveform before sharing — avoids exporting silence at the start/end | High |
| **Loop playback** | Toggle to loop between trim markers; useful for repeating a recorded passage while practicing along | High |
| **Recording tags / labels** | Attach instrument type or key signature metadata to a recording slot (stored alongside the name) | Medium |
| **Export format options** | MP3 export alongside WAV via a WebAssembly encoder (e.g. lamejs) — smaller file size for sharing | Low |

---

## General / UX

| Feature | Description | Priority |
|---|---|---|
| **System theme follow** | Auto switch light/dark based on `prefers-color-scheme` media query; override still available in Settings | High |
| **Onboarding paywall** | Show the Pro upgrade modal after the tutorial on first launch — significantly improves conversion vs. Settings-only placement | High |
| **Session / tuning history** | Scrollable log of detected notes + timestamps from the current session; cleared on new session | Medium |
| **Multiple instrument profiles** | Save different A4 reference pitches and sensitivity settings under named profiles (e.g. "Guitar", "Violin") | Medium |
| **Offline-resilient IAP cache** | Extend the `localStorage` tier cache TTL with a timestamp; only re-verify against RevenueCat if >24 h have elapsed, to handle offline use gracefully | Medium |
