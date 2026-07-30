# JSONFormatter Staged Implementation Plan

## Summary

Build a simple native macOS SwiftUI app from the current template project. The app will use a two-pane editor/output layout matching the sketch, validate JSON automatically as source text changes, pretty-print valid JSON, show clear parse errors for invalid JSON, support opening/dropping `.json` files, and export the formatted result.

Current project state:

- Single macOS app target: `JSONFormatter`
- Current UI is the default `ContentView`
- `JSONFormatterApp` only hosts `ContentView`
- No test target is currently visible
- Baseline build succeeds

## Stage 1: Core JSON Formatting Model

Create the app's JSON formatting domain before building the UI.

Key changes:

- Add a small model/service responsible for:
  - Accepting raw source text
  - Treating empty input as an idle/waiting state
  - Parsing JSON with `JSONSerialization`
  - Pretty-printing valid JSON using stable indentation
  - Returning invalid-state details with a user-facing error message
- Define a simple result type, for example:
  - `idle`
  - `valid(formatted: String)`
  - `invalid(message: String, line: Int?, column: Int?, snippet: String?)`
- Add line/column extraction when Foundation exposes parse-location details in the thrown error; otherwise fall back to a clear parser message without fake positions.

Manual verification after build:

- App still launches.
- Known valid JSON formats correctly through temporary preview/sample wiring or a lightweight local check.
- Known invalid JSON returns an error state.

## Stage 2: Main Two-Pane SwiftUI Layout

Replace the placeholder UI with the native two-pane interface from the sketch.

Key changes:

- Use a horizontally split layout with equal left/right panes that resize gracefully.
- Left pane:
  - Header: "Source JSON"
  - Editable `TextEditor` bound to source text
  - Empty-state drop affordance when no source text exists
  - Status indicator showing Ready, Valid, or Error
- Right pane:
  - Header: "Formatted Result"
  - Read-only output display
  - Empty state: "Formatted JSON appears here"
  - Error state with message and optional line/column
  - Status indicator showing Waiting, Valid, or Error
- Use system colors/materials and semantic foreground/background styling so Light and Dark Mode work naturally.
- Keep visual styling native macOS: toolbar, split panes, bordered sections, SF Symbols, and restrained spacing.

Manual verification after build:

- Window opens with two panes and empty states.
- Typing in the left pane updates the right pane.
- Formatted output cannot be edited.
- Resizing keeps headers, editors, and empty states usable.

## Stage 3: Automatic Validation Behavior

Make validation robust and responsive as users type or paste.

Key changes:

- Store source text and validation state in simple SwiftUI state or a small `@Observable` view model.
- Validate automatically whenever source text changes.
- Use Swift concurrency for debounced validation so repeated typing does not trigger unnecessary work.
- Keep UI updates on the main actor.
- Cancel stale validation tasks when newer source changes arrive.

Manual verification after build:

- Pasting valid compact JSON pretty-prints it.
- Editing valid JSON into invalid JSON quickly updates to an error.
- Fixing invalid JSON restores formatted output.
- Emptying the source returns the output pane to Waiting.

## Stage 4: Open and Drag-and-Drop JSON Files

Add native file input.

Key changes:

- Add a toolbar "Open" action using SwiftUI `fileImporter`.
- Restrict open/import to JSON-compatible content types where possible, with plain text fallback only if needed for `.json` recognition.
- Read selected files asynchronously using `String(contentsOf:encoding:)` or equivalent async-safe file loading.
- Add drag-and-drop support using SwiftUI `dropDestination` for file URLs.
- Load the first dropped JSON file into the editable source pane.
- Show a clear file-read error if the file cannot be loaded as UTF-8 text.

Manual verification after build:

- Open a valid `.json` file and confirm it appears in the left pane and formatted output appears on the right.
- Open/drop invalid JSON and confirm the parse error appears.
- Drop a non-JSON file and confirm it is rejected or produces a clear load/validation message.
- Confirm source remains editable after loading.

## Stage 5: Save or Export Formatted JSON

Add native export for the read-only formatted result.

Key changes:

- Add toolbar "Export" or "Save Formatted" action using SwiftUI `fileExporter`.
- Export only when the current JSON state is valid.
- Use a lightweight `FileDocument` or `Transferable` wrapper for the formatted string.
- Default filename: `formatted.json`.
- Disable export when there is no valid formatted output.
- Surface export errors in the UI using a small alert or status message.

Manual verification after build:

- Export is disabled for empty or invalid input.
- Export writes the pretty-printed JSON for valid input.
- Reopening the exported file shows formatted JSON.
- Canceling export does not show an error.

## Stage 6: Error Presentation and Polish

Improve the invalid JSON experience and match the sketch more closely.

Key changes:

- Show parser message prominently in the right pane.
- When line/column are available, display them as `Line X, Column Y`.
- Show a short source excerpt around the error when possible.
- Add a subtle inline marker style in the source pane using surrounding text context if direct `TextEditor` highlighting is not practical in pure SwiftUI.
- Add native toolbar/title polish:
  - App title `JSONFormatter`
  - Toolbar actions: Open, Export
  - Header tagline: "Validate and format JSON"
- Add accessibility labels for toolbar buttons, status indicators, drop area, source editor, and output area.

Manual verification after build:

- Invalid JSON shows a clear error and location when available.
- Light and Dark Mode both remain readable.
- Keyboard focus/editing in the source pane works normally.
- Empty, valid, invalid, open, drop, and export states are all understandable.

## Stage 7: Testing and Final Build Verification

Add focused automated coverage if the project structure supports it without overcomplicating the app.

Key changes:

- If adding a test target is acceptable, add Swift Testing unit tests for the formatter model:
  - Empty input returns idle
  - Valid object pretty-prints
  - Valid array pretty-prints
  - Invalid JSON returns invalid state
  - Error line/column extraction is covered when available
- If not adding a test target, keep validation as manual plus full app builds at each stage.
- Run `BuildProject` after every stage and final completion.

Manual verification:

- Build succeeds after every stage.
- Final app manually verifies:
  - Type/paste JSON
  - Open file
  - Drop file
  - Auto-validation
  - Pretty-printing
  - Invalid error display
  - Read-only output
  - Export
  - Window resizing
  - Light/Dark Mode

## Assumptions

- "format the source code according to poinmt out the error" means: when possible, identify and point out the parsing error location in the source context, not automatically rewrite invalid source.
- The implementation should remain a regular single-window SwiftUI app, not a full document-based `DocumentGroup` app.
- No third-party dependencies will be added.
- The formatted JSON indentation default will be 4 spaces unless you prefer 2 spaces.
- Export will save the formatted output only, while opened/dropped source remains editable in the left pane.
