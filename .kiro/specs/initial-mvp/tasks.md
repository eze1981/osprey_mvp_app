# Implementation Plan: Initial MVP

## Overview

Build the Project Osprey local-first iOS voice-capture inspection app for commercial roofing contractors. Cupertino design, live camera preview, on-device transcription, PDF export. All tasks below are COMPLETE for the current implementation.

## Completed Tasks

- [x] 1. Set up project dependencies
  - Added `isar_community`, `isar_community_flutter_libs`, `path_provider`
  - Added `record`, `just_audio`, `camera`
  - Added `pdf`, `share_plus`
  - Added `isar_community_generator`, `build_runner` (dev)

- [x] 2. Implement data model and repository
  - InspectionItem Isar collection: id, photoFileName, audioFileName, transcript?, createdAt (indexed)
  - InspectionRepository: init, saveInspection (returns id), getAllItems, getItemsWithoutTranscript, updateTranscript, deleteInspection, getPhotoPath, getAudioPath
  - Timestamp filenames: `yyyyMMdd_HHmmss_SSS`

- [x] 3. Implement HapticService
  - Static methods: medium, heavy, success, error
  - Fire-and-forget, exceptions swallowed

- [x] 4. Implement CaptureScreen with live camera preview
  - State machine: initializing → idle → recording → saving → error
  - Full-screen CameraPreview, cameras list passed from main
  - Mic permission pre-checked at init
  - Photo taken inline, then recording starts (shutter sound before recorder)
  - 5-minute auto-stop, app lifecycle handling

- [x] 5. Implement on-device transcription
  - Platform channel `osprey/transcription` in AppDelegate.swift
  - SFSpeechURLRecognitionRequest with requiresOnDeviceRecognition
  - TranscriptionService Dart wrapper
  - Fire-and-forget after save
  - Pending transcription retry on app launch

- [x] 6. Implement InspectionScreen (renamed from Gallery)
  - 64x64 thumbnails, timestamp, transcript preview (2 lines)
  - Tap → InspectionDetailScreen
  - Swipe-left delete with Dismissible + confirmation dialog
  - Pull-to-refresh
  - Share button → PDF export with loading indicator

- [x] 7. Implement InspectionDetailScreen
  - Full-size photo
  - Audio player: play/pause, progress bar, elapsed/total time
  - Complete transcript text

- [x] 8. Implement PDF export
  - PdfExportService: A4 multi-page, timestamp + photo + transcript per item
  - Share via share_plus (Share.shareXFiles)
  - Loading spinner during generation

- [x] 9. Implement app shell and navigation
  - CupertinoApp + CupertinoTabScaffold
  - Two tabs: Capture (camera icon), Inspection (doc_text icon)
  - Parallel init: availableCameras() + repository.init()
  - Reload inspection list on tab switch

- [x] 10. Configure iOS permissions
  - NSCameraUsageDescription
  - NSMicrophoneUsageDescription
  - NSSpeechRecognitionUsageDescription

## Pending Tasks

- [ ] 11. Demo UX improvements (DONE)
  - [x] 11.1 Item count in Inspection screen header
  - [x] 11.2 Recording elapsed timer
  - [x] 11.3 "Saved ✓" confirmation
  - [x] 11.4 "Tap to capture" hint
  - [x] 11.5 Improved PDF header with count and time range

- [ ] 12. Multiple inspections support
  - [ ] 12.1 Create Inspection Isar model (id, name, createdAt)
  - [ ] 12.2 Add inspectionId field to InspectionItem, regenerate schema
  - [ ] 12.3 Update InspectionRepository with inspection CRUD methods
  - [ ] 12.4 Create InspectionsListScreen (list, create, delete inspections)
  - [ ] 12.5 Update CaptureScreen to require active inspection ID
  - [ ] 12.6 Update InspectionScreen to filter items by inspectionId
  - [ ] 12.7 Update main.dart navigation (Inspections tab → list → items)
  - [ ] 12.8 Handle "no active inspection" state on Capture tab

## Notes

- iOS-only, local-first, no network dependencies
- Cupertino design throughout
- Target user: commercial roofing contractors
- Timestamp filename format: `yyyyMMdd_HHmmss_SSS` (UTC + milliseconds)
