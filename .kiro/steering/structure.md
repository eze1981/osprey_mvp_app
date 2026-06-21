# Project Structure

## Directory Layout

```
lib/
  main.dart          — App entry point and root widget
test/
  widget_test.dart   — Widget tests
ios/                 — iOS platform files
.kiro/
  steering/          — Steering files (product, tech, structure)
  specs/             — Feature specifications
  settings/          — Kiro configuration
```

## Conventions

- **File naming**: snake_case for all Dart files
- **Widget organization**: One widget per file for non-trivial widgets
- **State management**: setState for MVP simplicity (no external state management package)
- **Imports**: Use package imports (`package:osprey_mvp_app/...`)

## Architecture

- Single-screen MVP with two main views: Capture and Gallery
- Simple widget tree — avoid deep nesting or over-abstraction
- Keep business logic minimal and co-located with UI for MVP scope
- Platform interaction via Flutter plugins (camera, audio, haptics)
