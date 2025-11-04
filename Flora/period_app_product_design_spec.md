# Project: Flora (working title) — Private Period & Cycle Tracker

> **One‑line**: A 100% on‑device, privacy‑first period & fertility tracker with a modern, minimal, “Apple‑esque” UI — feature‑parity with leading apps like Flo, but entirely free and offline by default.

---

## 1) Vision & Principles
- **Privacy‑by‑default**: All data is **local‑only**. No third‑party SDKs or servers. Network access is not required to use the app.
- **No paywalls**: Every feature is free. No ads. No tracking.
- **Clinical‑ish clarity, not clinical vibes**: Clear language, warm tone, zero fear‑mongering.
- **Useful > busy**: Minimal UI that reveals depth when needed.
- **Accessibility**: First‑class support for Dynamic Type, VoiceOver, high contrast, and motion reduction.

---

## 2) Target Users & Jobs‑To‑Be‑Done
**Primary**: Women tracking cycles for health awareness, symptom management, and predicting period windows.
**Secondary**: Users monitoring fertility windows (trying to conceive or avoid), PCOS/irregular cycles, postpartum, and perimenopause.

**Top jobs**
1. Know when the next period is expected and when to prepare.
2. Log symptoms, moods, and factors that influence comfort & performance.
3. Understand fertile window & ovulation estimates (with confidence ranges).
4. Receive helpful, respectful reminders (period start, meds, supplements, tests).
5. Keep data private, exportable, and portable.

---

## 3) Feature Set (User‑Facing)

### 3.1 Core Tracking
- **Period logging**: Start/stop, flow intensity (light/med/heavy), spotting.
- **Cycle timeline**: Calendar heat‑map, list view, and compact “this week” card.
- **Symptoms** (multi‑select, customizable): cramps, headaches, bloating, breast tenderness, acne, sleep, energy, GI, cravings, libido, mood tags.
- **Body metrics**: weight, basal body temperature (BBT), resting HR, sleep hours/quality.
- **Sexual activity** (optional): protected/unprotected; note partner; notes.
- **Birth control**: type (pill, IUD, ring, shot, implant, patch, plan-b), schedule, adherence reminders.
- **Medications & supplements**: daily/PRN with reminders.
- **Notes & journal**: quick text, voice‑to‑text, tags.

### 3.2 Predictions & Insights (On‑device)
- **Next period prediction** with **confidence bands** based on historical variance.
- **Fertile window & ovulation estimate** (standard calendars + learned luteal length; adjustable rules for irregular cycles).
- **Irregularity awareness**: flags when cycles are notably longer/shorter than personal baseline.
- **Pattern insights**: symptom correlations (e.g., migraines ↑ two days pre‑period), BBT shift alerts.
- **Per‑phase guidance**: short, practical tips for menstruation, follicular, ovulation, luteal phases.

### 3.3 Modes
- **Trying to Conceive (TTC) Mode**: richer fertile window detail, BBT overlay, intercourse logging cadence tips.
- **Pregnancy Mode** (optional, local): week‑by‑week timeline, symptom journal, medication reminders; disables period predictions.
- **Postpartum/Perimenopause Mode**: broader confidence windows, flexible cycle detection thresholds.

### 3.4 Reminders & Notifications
- Smart reminders: period due soon, pad/tampon/cup prep, meds/BC, BBT time, hydration.
- **Quiet hours** & **snooze** controls.
- **Siri Shortcuts / App Intents**: “Log period start”, “Log cramps level 2”, “How many days until my period?”.

### 3.5 Data Ownership
- **Local‑only storage** with encryption at rest.
- **Export**: Encrypted ZIP (JSON + CSV) to Files, AirDrop, or external drive.
- **Import**: Restore from your encrypted archive (device‑local only by default).
- **Apple Health (optional)**: One‑way **user‑controlled** reads/writes for relevant categories (e.g., BBT, menstruation), disabled by default.

### 3.6 Widgets & Surfaces
- **Lock Screen / Home widgets**: days until period, cycle day, discreet “🌙 / ☀️” state indicators.
- **Apple Watch**: quick log (flow/symptom), BBT reminder, glanceable timeline.

---

## 4) Non‑Goals (V1)
- No social feeds, forums, or A/B tested “engagement loops”.
- No cloud services by default. (Future optional iCloud sync can be added with explicit consent, see §11.)
- No external analytics SDKs.

---

## 5) Safety, Scope, & Disclaimers
- Not a contraceptive device; predictions are estimates, not medical advice.
- Prominent **Safety Notice** in onboarding and settings.
- No crisis or diagnostic content; provide a local “Resources” sheet linking to public hotlines (no network request needed, stored locally).

---

## 6) Architecture (iOS)
- **Language/UI**: Swift + SwiftUI (iOS 17+).
- **State**: MVVM or The Composable Architecture (TCA) for testable, predictable flows.
- **Storage**: Core Data (backed by SQLite) + **SQLCipher** for encryption at rest.
- **Crypto**: Secure Enclave‑backed key using Keychain; per‑user data encryption key rotation on first launch.
- **Background**: BackgroundTasks for prediction refresh & reminder scheduling.
- **Notifications**: UNUserNotificationCenter (local only).
- **Health**: HealthKit (optional, explicit permission prompts with granular toggles).
- **Widgets/Watch**: WidgetKit, App Intents, WatchKit / SwiftUI for watchOS companion.

---

## 7) Data Model (Core Entities)
- **UserProfile**: birth year (optional), timezone, units, modes (TTC/pregnancy), privacy flags.
- **Cycle**: id, startDate, endDate (optional until detected), averageFlow, notes.
- **PeriodEvent**: date, flowLevel, spotting, source (manual/auto).
- **SymptomLog**: dateTime, tags [cramps(0–3), mood tags, etc.], intensity(0–3), notes.
- **Vitals**: dateTime, bbt(°C/°F), weight, rhr, sleep.
- **SexActivity** (optional): dateTime, protected(bool), partnerTag, notes.
- **BirthControl**: type, schedule, adherence events.
- **Medication**: name, dosage, schedule, adherence logs.
- **PredictionSnapshot**: computedAt, cycleDay, nextPeriodRange(start..end), fertileRange, ovulationEstimate, confidence(0–1), rationale.
- **Settings**: reminder prefs, theme, passcode/FaceID, analytics=off (hard‑coded).

> All entities persisted in encrypted Core Data store. Export = serialized JSON & CSV inside password‑encrypted ZIP.

---

## 8) Prediction Algorithms (On‑Device)
**Cycle Detection**
- Detect period starts from explicit user logs; infer end when flow-level returns to 0 for N days (configurable, default N=2).

**Next Period Date**
- Maintain rolling stats over last **k** cycles (default k=6, min 3):
  - avgCycle = mean(cycleLength)
  - varCycle = variance(cycleLength)
  - **Confidence band** ±1σ (clamped to [24, 38] day physiological bounds unless user toggles wide mode).
  - Prediction = lastStart + avgCycle; Range = [−σ, +σ] around prediction.

**Luteal Estimation**
- If BBT shifts observed ≥0.2°C sustained 3+ days: ovulation ≈ day before sustained rise; luteal = days from ovulation→next period.
- Otherwise use personal luteal median if known; fallback 14 days.

**Fertile Window**
- OvulationEstimate ±2 days; fertile = ovulation −5 .. ovulation +1.

**Irregularity Flag**
- If current cycle len outside personal IQR by >1.5×IQR or >2σ, mark low confidence and broaden ranges.

**Symptom Correlation (Local)**
- Compute per‑phase symptom frequency and simple Pearson/Spearman with cycle day; surface top 3 correlations with caveats.

---

## 9) Privacy & Security Architecture
- **No network calls** in production build (feature flagged; CI asserts).
- **At‑rest encryption** via SQLCipher; key sealed in Keychain with Secure Enclave.
- **App Lock**: opt‑in FaceID/TouchID/passcode; quick‑hide screen (blur) on app switcher.
- **Granular permissions**: HealthKit off by default; per‑category switches.
- **Exports**: user‑provided password; AES‑GCM encrypted archive.
- **No telemetry**: Only on‑device counters in memory (not persisted) for UX tuning during development builds.
- **Privacy Nutrition Label**: “Data Not Collected”, “Data Not Tracked”.

---

## 10) Information Architecture & Navigation
- **Tab 1 — Today**: cycle day, status chip, quick log (flow/symptoms), next period card, actions (add note, BBT).
- **Tab 2 — Calendar**: month grid with color dots (flow, fertile), long‑press to log; toggle to list timeline.
- **Tab 3 — Insights**: predictions with confidence ranges, patterns (“You often report cramps day −1 to +1”), phase tips.
- **Tab 4 — Reminders**: BC/meds/BBT schedules, quiet hours.
- **Tab 5 — More**: modes, Health access, export/import, appearance, security, help & disclaimers.

---

## 11) Optional iCloud (Future, Explicit Opt‑In)
- **Approach**: NSPersistentCloudKitContainer for private database.
- **Disclosure**: Transparent copy explaining Apple’s role and end‑to‑end protections; default remains **local‑only**.
- **User control**: per‑device sync toggle, local‑only mode preserved.

---

## 12) Design System (Clean • Minimal • Feminine Touch)
**Brand**
- **Name (candidates)**: Flora, Bloom, Ember, Lune, Matra.
- **Tone**: Warm, supportive, never preachy. Microcopy is brief and kind.

**Color**
- Base neutrals: **Porcelain** (#F8F8F8), **Ink** (#0B0B0C), **Mist** (#EDEDEF).
- Accent palette (one primary, subtle gradients allowed):
  - **Rose** (#FF7A8A), **Coral** (#FF8E72), **Lavender** (#A08CFF), **Sage** (#A6C1A8).
- Use color sparingly; rely on whitespace, typographic hierarchy, and subtle elevation.

**Typography**
- SF Pro / SF Rounded for friendly headlines.
- Sizes: Title 1 (28), Title 2 (22), Body (17), Caption (13). Dynamic Type compliance.

**Iconography & Illustrations**
- Thin‑stroke SF Symbols; small line illustrations only in empty states.

**Components**
- **Card** containers (8–12pt radius), soft shadows at large sizes only.
- **Chips** for cycle states (Menstruation, Follicular, Ovulation, Luteal).
- **Segmented controls** for flow & symptom intensities.
- **Stepper** for BBT entry; **Toggle** groups for reminders.

**Motion**
- Gentle 150–200ms transitions; reduce motion obeys OS setting.

**Empty States & Microcopy**
- “No logs yet — your cycle story starts when you’re ready.”

---

## 13) Key Screens (Wireframe Notes)
1. **Onboarding**: 3 cards (privacy pledge → how predictions work → consent choices). Collect: last period start/end (optional), average cycle (optional).
2. **Today**: Status chip (“Cycle Day 12 • Follicular”), prediction pill (“Period in 17–19 days”), quick log row, shortcuts (Add symptom, Add BBT, Add note).
3. **Calendar**: Month view; tap a day → context sheet (Log flow/symptom/sex/meds).
4. **Insights**: Big date range pill with confidence bar; trend chips (Sleep ↓ pre‑period), disclaimers.
5. **Reminders**: Schedules list with toggles; quiet hours time picker.
6. **Security**: Enable FaceID/passcode; change export password hints.
7. **Export/Import**: One‑tap encrypted export; import flow with preview.

---

## 14) Accessibility & Internationalization
- Full VoiceOver labels; hit‑target ≥ 48pt.
- High‑contrast palette variant, test with Color Filters.
- Localize for: en, es, fr, de, hi; right‑to‑left readiness.
- Numerical formats (°C/°F, kg/lb), calendars (Gregorian primary).

---

## 15) App Store Readiness
- **Privacy Labels**: Data Not Collected; no tracking.
- **Review Notes**: Clarify local‑only storage; provide test account with preloaded sample data.
- **Screenshots**: Light & dark, inclusive imagery, copy: “Yours. Private. Powerful.”
- **Age Rating**: 12+ (health content, no user‑generated public content).

---

## 16) QA & Testing
- **Unit tests**: prediction engine, cycle detection edge cases (short/long cycles, anovulatory months).
- **Snapshot tests**: key screens across Dynamic Type sizes and themes.
- **UITests**: logging flows, reminders, export/import.
- **Privacy tests**: static analysis blocks any networking; runtime assertion: no URLSession use in production.

---

## 17) Delivery Plan
- **M1 (4–6 wks)**: Data model, logging, calendar, basic prediction, Today screen, export, local notifications.
- **M2 (3–4 wks)**: Insights v1, TTC mode, BBT, birth control & meds reminders, widgets.
- **M3 (2–3 wks)**: Pregnancy mode (basic), accessibility polish, localization pass, App Store assets.

---

## 18) Future Roadmap (Opt‑In Only)
- iCloud private sync with transparent explainer.
- On‑device ML refinements (Core ML) for irregular cycles.
- Deeper Watch app for on‑wrist logging & BBT capture.
- Perimenopause‑aware insights and education pack (local content).

---

## 19) Copy Examples (Voice & Tone)
- **Reminder**: “Gentle nudge — BBT time if you’re tracking temperature.”
- **Prediction**: “Based on your last 6 cycles, your period is likely **Nov 18–20**.”
- **Safety**: “Estimates help you plan, not diagnose. If something feels off, consider talking with a clinician you trust.”

---

## 20) Engineering Notes & Code Conventions
- SwiftLint, 90‑char soft wrap, preview‑driven SwiftUI.
- Modules: `Core`, `Data`, `Features/Tracking`, `Features/Insights`, `DesignSystem`, `App`.
- Feature flags: `DEBUG_NETWORK` (must be false in release), `ENABLE_HEALTHKIT` (off by default).
- Dependency injection for prediction engine; pure functions where possible for unit testing.

---

## 21) Risks & Mitigations
- **Irregular cycles reduce accuracy** → always show confidence & ranges, never exact dates alone.
- **Data loss risk (local‑only)** → prominent encrypted export; gentle nags until first backup.
- **App Review questions** → clear notes and in‑app Privacy explainer screen.

---

**TL;DR**: Flora delivers a respectful, elegant, fully private cycle tracker with the features people actually use — predictions, logs, insights, reminders — all on‑device, with zero paywalls and zero tracking.

