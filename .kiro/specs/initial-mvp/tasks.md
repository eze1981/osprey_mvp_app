# Implementation Plan: Initial MVP

## Overview

Build the Project Osprey local-first iOS voice-capture inspection app. Implementation proceeds bottom-up: data layer, then services, then UI screens, then navigation shell. Files are created only when implementing actual functionality — no placeholder scaffolding.

## Tasks

- [ ] 1. Set up project dependencies
  - [ ] 1.1 Add required packages to pubspec.yaml
    - Add `isar`, `isar_flutter_libs`, `path_provider` to dependencies
    - Add `record`, `just_audio`, `image_picker` to dependencies
    - Add `isar_generator`, `build_runner` to dev_dependencies
    - Run `flutter pub get`

- [ ] 2. Implement data model and repository
  - [ ] 2.1 Define InspectionItem Isar collection
    - Create `lib/models/inspection_item.dart`
    - Fields: `Id id`, `String photoFileName`, `String audioFileName`, `DateTime createdAt`
    - Index on `createdAt` for descending sort
    - Run `dart run build_runner build`

  - [ ] 2.2 Implement InspectionRepository
    - Create `lib/services/inspection_repository.dart`
    - `init()`: opens Isar, ensures `photos/` and `audio/` subdirectories exist
    - `saveInspection()`: copies files to Documents Directory with timestamp filenames (`yyyyMMdd_HHmmss_SSS`), writes Isar record; no record if file write fails
    - `getAllItems()`: returns items ordered by `createdAt` descending
    - `deleteInspection(int id)`: removes Isar record and associated files

- [ ] 3. Implement HapticService
  - [ ] 3.1 Create HapticService
    - Create `lib/services/haptic_service.dart`
    - Static methods: `medium()`, `heavy()`, `success()`, `error()`
    - All wrap `HapticFeedback` in try-catch (fire-and-forget)

- [ ] 4. Implement CaptureScreen
  - [ ] 4.1 Create CaptureScreen with state machine
    - Create `lib/screens/capture_screen.dart`
    - `enum CaptureState { idle, cameraActive, recording, saving, error }`
    - Large centered action button (≥40% width, middle 60% height)
    - Recording indicator + stop button (visible when recording)
    - Error shown via SnackBar

  - [ ] 4.2 Implement capture flow transitions
    - Tap → haptic medium → launch camera
    - Photo accepted → haptic heavy → start audio recording
    - Photo cancelled → return to idle
    - Stop → save audio → save to repository → haptic success → idle
    - 5-minute auto-stop via Timer
    - App lifecycle: auto-stop recording on background

- [ ] 5. Implement GalleryScreen
  - [ ] 5.1 Create GalleryScreen with playback
    - Create `lib/screens/gallery_screen.dart`
    - Load items from repository on init
    - ListView with 80x80 thumbnail, timestamp, play/pause + elapsed time
    - Single AudioPlayer for exclusive playback
    - Empty state message when zero items
    - Placeholder for missing photos, disabled play for missing audio

- [ ] 6. Implement app shell and navigation
  - [ ] 6.1 Wire up main.dart
    - Replace demo code with BottomNavigationBar (Capture + Gallery tabs)
    - IndexedStack for state preservation
    - Initialize InspectionRepository in main() before runApp()
    - Default to Capture tab

- [ ] 7. Add iOS permissions
  - [ ] 7.1 Configure Info.plist
    - Add `NSCameraUsageDescription`
    - Add `NSMicrophoneUsageDescription`

- [ ] 8. Write tests
  - [ ] 8.1 Widget tests
    - Action button sizing, nav bar structure, empty gallery state
  - [ ] 8.2 Unit tests
    - HapticService method calls and exception handling
    - Repository save/query logic

## Notes

- Files are created only when their task is reached — no upfront scaffolding
- Timestamp filename format: `yyyyMMdd_HHmmss_SSS` (UTC + milliseconds)
- All tasks reference requirements from requirements.md
- iOS-only, local-first, no network dependencies
