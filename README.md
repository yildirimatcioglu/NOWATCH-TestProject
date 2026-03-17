# NOWATCH-TestProject

This is a refreshed version of the NOWATCH iOS technical assignment that I originally completed in 2024.  
I revisited the project to modernise the implementation, fix some subtle bugs, and bring the UI closer to the look and feel of the shipping NOWATCH app.

Below is a summary of what changed compared with my original submission.

---

## Functional changes

- **Data import is idempotent**
  - CSV is imported only once on first launch (`ImportService.importHeartRateFromFileIfNeeded()`), rather than re‑importing 44k rows every time.
  - Import runs on a background `NSManagedObjectContext` using Swift Concurrency.

- **Heart‑rate fetching is correct for the selected day**
  - The previous version used a Combine sink on `@Published selectedDate`, which fired in `willSet` and sometimes read a stale date.
  - The updated version moves the reaction into the view layer using `.onChange(of: selectedDate)`, so Core Data queries always match the actual selected date.

- **Live data only for “today”**
  - Random heart‑rate values are only emitted and stored when the selected date is today.
  - Switching to any other date automatically stops the live stream.

---

## Swift Concurrency & architecture

- **Async live data emitter**
  - Replaced the old `DispatchSourceTimer`-based property wrapper with a small `HeartRateEmitter.stream(interval:)` built on `AsyncStream<Int>`.
  - This removes retain cycles and makes cancellation automatic when the `Task` or view disappears.

- **Async CSV import**
  - `ImportService` now exposes an `async` API and performs all Core Data writes on a background context inside `context.perform {}` blocks.
  - The view model coordinates this via `await importHeartRateFromFileIfNeeded()` on first appearance.

- **@MainActor view model**
  - `HeartRateViewModel` is annotated with `@MainActor` and exposes a small API:
    - `loadInitialData() async`
    - `fetchHeartRates()`
    - `storeLiveData(liveHeartRate:)`
  - Core Data access is isolated to `HeartRateService`, which is injected for testability.

---

## UI / UX changes (NOWATCH-inspired)

- **Dark theme**
  - The app now runs in a dark colour scheme (`.preferredColorScheme(.dark)`).
  - Introduced a small `NowatchTheme` helper with the main background, card and accent colours.

- **Chart redesign**
  - The heart‑rate chart uses SwiftUI Charts with:
    - A warm yellow→orange→red line gradient.
    - A soft amber area fill under the curve.
    - A draggable selection overlay: dragging over the chart shows a vertical rule and point marker at the nearest reading.
  - The BPM header updates in real time as you scrub, similar to the timeline view in the production NOWATCH app.

- **HR statistics row**
  - Added a stats row under the chart showing **HR Max / HR Avg / HR Min** for the currently loaded day.
  - Each stat uses a large rounded number and a small coloured bar, echoing the activity detail design in the real app.

- **Refined header + live indicator**
  - The date picker has been moved into a compact header section with a subtle “LIVE” indicator when viewing today:
    - Small pulsing orange dot + “LIVE” label.
    - The pulse is implemented as a lightweight `ViewModifier` (`PulseEffect`).

---

## Accessibility

- Added explicit **accessibility identifiers** for UI tests (e.g. `datePicker`, `heartRateChart`, `bpmHeader`, `emptyState`, `liveIndicator`).
- Combined and labelled key elements for VoiceOver:
  - BPM header (“Current heart rate: N beats per minute”).
  - Chart summary (“Max / average / min BPM”).
  - Empty state (“No heart rate data available for the selected date”).

---

## Testing

- **Unit tests**
  - Updated service and view‑model tests to match the async import and new service APIs.
  - Added coverage for error paths (e.g. failed `storeLiveData`).

- **UI tests**
  - New UI tests in `NOWATCH-TestProjectUITests` verify:
    - The app transitions from loading → chart or empty state.
    - The live indicator and BPM header appear for today.
    - The chart exposes a non‑empty accessibility label for VoiceOver.

Together these changes bring the assignment closer to how I would structure and ship a small, production‑quality SwiftUI/Core Data feature in 2026, while staying within the original scope of the brief.
