# Technology Stack

## Framework

- **Flutter** (Dart SDK ^3.12.2)
- **Platform**: iOS only (MVP)

## Dependencies

- `cupertino_icons` — iOS-style icons
- `flutter_lints` — lint rules (dev)

## Planned Dependencies (per spec)

- `isar` / `isar_flutter_libs` — local database for inspection item metadata
- `path_provider` — access to iOS documents directory
- Native iOS camera and microphone via platform channels or plugins

## Data Storage

- **Metadata**: Isar Database (on-device)
- **Media files**: iOS application documents directory (.jpg photos, .m4a audio)
- **No cloud/backend** — entirely local-first

## Development Tools

- Flutter CLI for build/run
- Xcode for iOS deployment
- `analysis_options.yaml` with flutter_lints

## Constraints

- iOS only for MVP
- No network calls or external services
- All data must persist locally on-device
