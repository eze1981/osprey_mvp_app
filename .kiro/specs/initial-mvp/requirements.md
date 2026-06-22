# Requirements Document

## Introduction

Project Osprey is a local-first iOS voice-capture utility built with Flutter for commercial roofing contractors. It validates the voice-first field inspection concept by providing an eyes-free, high-durability interface to capture photos paired with voice memos that are automatically transcribed on-device. The app operates entirely on-device with no backend, no API layer, and no cloud storage. Media metadata is managed via Isar Database and raw files are stored in the iOS application documents directory.

## Glossary

- **App**: The Project Osprey Flutter iOS application (Cupertino design)
- **Capture_Screen**: The main interface showing a live camera preview with a capture button for initiating the photo-then-voice workflow
- **Inspection_Screen**: The scrollable vertical feed displaying all captured inspection items with transcript previews
- **Inspection_Detail_Screen**: Full-view screen showing photo, audio player with progress, and complete transcript
- **Inspection_Item**: A paired unit of one photo, one voice memo, and an optional transcript, linked by metadata
- **Isar_Database**: The local on-device database used for persisting Inspection_Item metadata
- **Documents_Directory**: The native iOS application documents directory where raw media files (.jpg and .m4a) are stored
- **Haptic_Feedback**: Native iOS haptic vibration patterns used to signal state transitions
- **Transcription**: On-device speech-to-text conversion using iOS SFSpeechRecognizer

## Requirements

### Requirement 1: Photo Capture with Live Preview

**User Story:** As a roofing contractor, I want to see a live camera preview and tap a single button to capture a photo, so that I can quickly document field conditions without navigating complex menus.

#### Acceptance Criteria

1. THE Capture_Screen SHALL display a full-screen live camera preview as the background.
2. THE Capture_Screen SHALL display a capture button overlaid at the bottom center of the screen.
3. WHEN the capture button is tapped, THE App SHALL take a photo inline (without launching a separate camera app) and immediately transition to audio recording.
4. WHEN the user accepts a captured photo, THE App SHALL save the photo as a .jpg file to the Documents_Directory with a filename composed of a UTC timestamp in the format "yyyyMMdd_HHmmss_SSS".
5. IF saving the photo fails, THEN THE App SHALL display an error message and return to the idle state.
6. THE camera SHALL reinitialize when the app resumes from background.

### Requirement 2: Automatic Voice Memo Recording

**User Story:** As a roofing contractor, I want voice recording to start automatically after snapping a photo, so that I can describe what I see without extra taps.

#### Acceptance Criteria

1. WHEN a photo is captured, THE App SHALL begin recording audio from the native iOS microphone immediately after the photo is saved.
2. WHILE recording is active, THE Capture_Screen SHALL display a visible recording indicator and a stop button.
3. WHEN the user taps the stop button, THE App SHALL end the recording and save the audio as an .m4a file to the Documents_Directory.
4. WHEN recording is stopped, THE App SHALL create a new Inspection_Item in the Isar_Database linking the photo file path, the audio file path, and a creation timestamp.
5. IF microphone permission is not granted, THEN THE App SHALL display an error and not proceed with capture.
6. WHEN recording duration reaches 5 minutes, THE App SHALL automatically stop the recording and save.
7. IF the App transitions to the background while recording is active, THEN THE App SHALL stop and save the recording.

### Requirement 3: Haptic Feedback State Signals

**User Story:** As a roofing contractor, I want to feel distinct vibrations when the app changes state, so that I can operate the capture flow without looking at the screen.

#### Acceptance Criteria

1. WHEN the capture button is tapped, THE App SHALL trigger a medium intensity haptic.
2. WHEN audio recording begins, THE App SHALL trigger a heavy intensity haptic.
3. WHEN the Inspection_Item is saved successfully, THE App SHALL trigger a success haptic.
4. IF a save fails, THEN THE App SHALL trigger an error haptic.
5. IF the device haptic engine is unavailable, THEN THE App SHALL continue without interruption.

### Requirement 4: On-Device Speech Transcription

**User Story:** As a roofing contractor, I want my voice memos automatically transcribed to text on my device, so that I can read my notes without playing audio.

#### Acceptance Criteria

1. WHEN an Inspection_Item is saved, THE App SHALL transcribe the audio file on-device using iOS SFSpeechRecognizer in the background.
2. THE transcription SHALL run entirely on-device (requiresOnDeviceRecognition = true) with no network calls.
3. THE transcript text SHALL be stored in the Inspection_Item record in the Isar_Database.
4. THE transcription SHALL NOT block the UI — the user can continue capturing immediately.
5. WHEN the App launches, it SHALL transcribe any items that do not yet have a transcript (retry pending items).
6. IF transcription fails (permission denied, unavailable), THE App SHALL leave the transcript field null and continue without error.

### Requirement 5: Inspection Feed

**User Story:** As a roofing contractor, I want to scroll through my captured inspection items, so that I can review my work in chronological order.

#### Acceptance Criteria

1. THE Inspection_Screen SHALL display all Inspection_Items in a scrollable list ordered by creation timestamp descending.
2. Each item SHALL display a 64x64 thumbnail and a preview of the transcript text (first 2 lines).
3. Items without a transcript SHALL display "Transcribing..." in italic.
4. WHEN an item is tapped, THE App SHALL navigate to the Inspection_Detail_Screen.
5. THE Inspection_Screen SHALL support pull-to-refresh to reload items.
6. WHEN zero items exist, THE App SHALL display an empty state message.

### Requirement 6: Inspection Detail View

**User Story:** As a roofing contractor, I want to view the full details of an inspection item, so that I can see the photo, listen to the audio, and read the complete transcript.

#### Acceptance Criteria

1. THE Inspection_Detail_Screen SHALL display the full-size photo.
2. THE Inspection_Detail_Screen SHALL display an audio player with play/pause, a progress bar, and elapsed/total time.
3. THE Inspection_Detail_Screen SHALL display the complete transcript text (scrollable).
4. IF the transcript is not yet available, THE screen SHALL display "Transcript not available yet".

### Requirement 7: Delete Inspection Items

**User Story:** As a roofing contractor, I want to delete inspection items I no longer need, using the familiar iOS swipe gesture.

#### Acceptance Criteria

1. WHEN the user swipes an item left on the Inspection_Screen, THE App SHALL reveal a red delete background.
2. BEFORE deleting, THE App SHALL display a confirmation dialog.
3. WHEN confirmed, THE App SHALL delete the Isar record and associated media files (photo and audio).
4. THE deleted item SHALL animate out of the list.

### Requirement 8: PDF Export

**User Story:** As a roofing contractor, I want to export my inspection as a PDF report, so that I can share it with building owners or insurance adjusters.

#### Acceptance Criteria

1. THE Inspection_Screen SHALL display a share/export button in the navigation bar when items exist.
2. WHEN the export button is tapped, THE App SHALL generate a PDF document containing all inspection items.
3. THE PDF SHALL include: a title header, and for each item: timestamp, photo, and transcript text.
4. WHILE the PDF is generating, THE App SHALL display a loading indicator.
5. WHEN the PDF is ready, THE App SHALL present the iOS share sheet for the user to share/save the file.

### Requirement 9: App Navigation

**User Story:** As a roofing contractor, I want to switch between capture and inspection review with a tab bar.

#### Acceptance Criteria

1. THE App SHALL provide a bottom tab bar with two tabs: Capture and Inspection.
2. THE App SHALL use Cupertino (iOS-native) design throughout.
3. THE App SHALL launch with the Capture tab as the default.
4. WHEN switching to the Inspection tab, THE App SHALL reload the items list.

### Requirement 10: Local Data Persistence

**User Story:** As a roofing contractor, I want my captured inspections to persist between app sessions.

#### Acceptance Criteria

1. THE Isar_Database SHALL persist all records across app launches.
2. Media files SHALL be stored in the Documents_Directory with timestamp-based filenames (yyyyMMdd_HHmmss_SSS).
3. An Inspection_Item SHALL only be written to Isar after both media files exist on disk.
4. IF the Isar write fails, media files SHALL be retained on disk.
5. IF file write fails, no Isar record SHALL be created.



### Requirement 11: Demo UX Polish

**User Story:** As a roofing contractor demoing the app to a building owner, I want clear visual feedback at every step so the app feels professional and self-explanatory.

#### Acceptance Criteria

1. THE Inspection_Screen SHALL display a count of captured items (e.g. "12 items") in the navigation bar area.
2. WHILE recording audio on the Capture_Screen, THE App SHALL display an elapsed timer (mm:ss) that counts up in real-time.
3. WHEN an Inspection_Item is saved successfully, THE Capture_Screen SHALL briefly display a "Saved ✓" confirmation overlay before returning to idle.
4. WHEN the Capture_Screen is in idle state, THE App SHALL display a subtle "Tap to capture" label below the capture button to guide first-time users.
5. THE PDF report header SHALL include the total number of items and the date range (earliest to latest item timestamp).



### Requirement 12: Multiple Inspections

**User Story:** As a roofing contractor, I want to organize my captures into separate inspections (one per job/site), so that I can keep reports for different buildings separate.

#### Acceptance Criteria

1. THE App SHALL support multiple inspections, each identified by a name and creation timestamp.
2. THE App SHALL display an Inspections List showing all inspections ordered by creation date descending, with name, item count, and date.
3. WHEN the user taps "New Inspection", THE App SHALL prompt for an inspection name and create a new inspection that becomes the active inspection.
4. WHEN the user captures a photo+voice memo, THE App SHALL associate the Inspection_Item with the currently active inspection.
5. WHEN the user taps an inspection in the list, THE App SHALL navigate to the Inspection Screen showing only items belonging to that inspection.
6. THE PDF export SHALL generate a report for the currently viewed inspection only.
7. THE Inspection tab SHALL show the Inspections List as its root, with navigation to individual inspections.
8. IF no active inspection exists when the user tries to capture, THE App SHALL prompt the user to create one first.
9. THE user SHALL be able to delete an entire inspection (including all its items and media files) via swipe-left.
