# Requirements Document

## Introduction

Project Osprey is a local-first iOS voice-capture utility built with Flutter. It validates the voice-first field inspection concept by providing an eyes-free, high-durability interface for contractors to capture photos and pair them instantly with dedicated voice memos. The app operates entirely on-device with no backend, no API layer, and no cloud storage. Media metadata is managed via Isar Database and raw files are stored in the iOS application documents directory.

## Glossary

- **App**: The Project Osprey Flutter iOS application
- **Capture_Screen**: The main unified interface dominated by a single action button for initiating the photo-then-voice workflow
- **Gallery_Screen**: The scrollable vertical feed displaying all captured inspection items
- **Inspection_Item**: A paired unit of one photo and one voice memo, linked by metadata
- **Isar_Database**: The local on-device relational database used for persisting Inspection_Item metadata
- **Documents_Directory**: The native iOS application documents directory where raw media files (.jpg and .m4a) are stored
- **Haptic_Feedback**: Native iOS haptic vibration patterns used to signal state transitions

## Requirements

### Requirement 1: Photo Capture Initiation

**User Story:** As a contractor, I want to tap a single large button to capture a photo, so that I can quickly document field conditions without navigating complex menus.

#### Acceptance Criteria

1. THE Capture_Screen SHALL display a single action button with a minimum contrast ratio of 4.5:1 against its background, occupying at least 40% of the screen width and positioned vertically centered within the middle 60% of the screen height.
2. WHEN the action button is tapped, THE App SHALL activate the native iOS camera interface within 1 second.
3. WHEN the user accepts a captured photo, THE App SHALL save the photo as a .jpg file to the Documents_Directory with a filename composed of a UTC timestamp in the format "yyyyMMdd_HHmmss" followed by a unique suffix.
4. WHEN the user cancels the camera without taking a photo, THE App SHALL return to the Capture_Screen without creating an Inspection_Item and without writing any file to the Documents_Directory.
5. IF saving the photo to the Documents_Directory fails, THEN THE App SHALL display an error message indicating the photo could not be saved and SHALL return to the Capture_Screen without creating an Inspection_Item.

### Requirement 2: Automatic Voice Memo Recording

**User Story:** As a contractor, I want voice recording to start automatically after snapping a photo, so that I can describe what I see without extra taps.

#### Acceptance Criteria

1. WHEN a photo is accepted from the camera, THE App SHALL begin recording audio from the native iOS microphone within 500 milliseconds of photo acceptance.
2. WHILE recording is active, THE Capture_Screen SHALL display a visible recording indicator and a stop button; WHILE recording is inactive, THE Capture_Screen SHALL hide the recording indicator and stop button.
3. WHEN the user taps the stop button, THE App SHALL end the recording and save the audio as an .m4a file to the Documents_Directory. IF the audio file fails to save, THEN THE App SHALL display an error message indicating the save failure and discard the incomplete Inspection_Item.
4. WHEN recording is stopped, THE App SHALL create a new Inspection_Item in the Isar_Database linking the photo file path, the audio file path, and a creation timestamp.
5. IF microphone permission is not granted when a photo is accepted, THEN THE App SHALL prompt the user for microphone access and shall not create an Inspection_Item until permission is granted and recording completes.
6. WHEN recording duration reaches 5 minutes, THE App SHALL automatically stop the recording and proceed with saving the audio file and creating the Inspection_Item.
7. IF the App transitions to the background while recording is active, THEN THE App SHALL stop the recording and save the captured audio, then create the Inspection_Item with the audio recorded up to that point.

### Requirement 3: Haptic Feedback State Signals

**User Story:** As a contractor, I want to feel distinct vibrations when the app changes state, so that I can operate the capture flow without looking at the screen.

#### Acceptance Criteria

1. WHEN the native camera interface activates, THE App SHALL trigger an iOS haptic feedback pulse of medium intensity within 100 milliseconds of the state transition.
2. WHEN audio recording begins, THE App SHALL trigger an iOS haptic feedback pulse of heavy intensity within 100 milliseconds of the state transition.
3. WHEN the Inspection_Item is saved successfully, THE App SHALL trigger an iOS haptic feedback success notification within 100 milliseconds of save completion.
4. IF the Inspection_Item save fails, THEN THE App SHALL trigger an iOS haptic feedback error notification to indicate the failure.
5. IF the device haptic engine is unavailable, THEN THE App SHALL continue the capture flow without interruption and shall not display an error to the user.

### Requirement 4: Inspection Gallery Feed

**User Story:** As a contractor, I want to scroll through my captured inspections in a vertical feed, so that I can review my work in chronological order.

#### Acceptance Criteria

1. THE Gallery_Screen SHALL display all Inspection_Items in a scrollable vertical list ordered by creation timestamp descending (newest first).
2. THE Gallery_Screen SHALL display a square thumbnail of the captured photo for each Inspection_Item, rendered at 80×80 logical pixels.
3. THE Gallery_Screen SHALL display the creation timestamp for each Inspection_Item formatted in the device locale's short date and time pattern (e.g., "MM/dd/yyyy HH:mm" for US locale).
4. WHEN the Isar_Database confirms zero Inspection_Items exist, THE Gallery_Screen SHALL display an empty state message indicating no inspections have been captured.
5. IF the photo file referenced by an Inspection_Item is missing or unreadable from the Documents_Directory, THEN THE Gallery_Screen SHALL display a placeholder image in place of the thumbnail for that Inspection_Item.

### Requirement 5: Inline Audio Playback

**User Story:** As a contractor, I want to play back a voice memo directly from the gallery feed, so that I can listen to my notes without leaving the review screen.

#### Acceptance Criteria

1. THE Gallery_Screen SHALL display an inline audio playback card for each Inspection_Item containing a Play button, a Pause button, and an elapsed-time label showing the current playback position in mm:ss format.
2. WHEN the Play button is tapped and no audio is currently playing, THE App SHALL begin audio playback of the associated .m4a voice memo from the beginning. WHEN the Play button is tapped while the same memo is paused, THE App SHALL resume playback from the paused position.
3. WHEN the Play button is tapped on one Inspection_Item while another Inspection_Item is actively playing, THE App SHALL stop the currently playing item, reset that item's playback card to its initial state, and begin playback of the newly selected item.
4. WHEN the Pause button is tapped during active playback, THE App SHALL pause audio playback at the current position. WHEN the Pause button is tapped while audio is not playing, THE App SHALL take no action.
5. WHEN playback reaches the end of the audio file, THE App SHALL reset the playback card to its initial state with the Play button active and the elapsed-time label showing 00:00.
6. IF the .m4a file associated with an Inspection_Item is missing or unreadable from the Documents_Directory, THEN THE App SHALL display an error indication on the playback card and disable the Play button for that item.

### Requirement 6: Local Data Persistence

**User Story:** As a contractor, I want my captured inspections to persist between app sessions, so that I do not lose work when I close the app.

#### Acceptance Criteria

1. THE Isar_Database SHALL persist all Inspection_Item records across App launches, including after iOS-initiated app termination, such that every record written before termination is retrievable on the next launch.
2. THE App SHALL store each photo .jpg file and each audio .m4a file in the Documents_Directory with a unique filename derived from a UUID, and SHALL store the corresponding file path in the associated Inspection_Item record so that each media file is retrievable via its record.
3. IF the Isar_Database fails to write an Inspection_Item record, THEN THE App SHALL display an error message indicating the record could not be saved, and SHALL retain the captured media files in the Documents_Directory.
4. IF the Documents_Directory is inaccessible for file writing, THEN THE App SHALL display an error message indicating the media file could not be stored, and SHALL not create a partial Inspection_Item in the Isar_Database.
5. IF any failure prevents completing the inspection capture workflow, THEN THE App SHALL display an error message identifying the failed operation (database write, file write, or insufficient storage) to the user.
6. IF the device has insufficient storage space to write a media file or database record, THEN THE App SHALL display an error message indicating insufficient storage and SHALL not create a partial Inspection_Item in the Isar_Database.

### Requirement 7: App Navigation

**User Story:** As a contractor, I want to switch between the capture screen and the gallery, so that I can alternate between capturing and reviewing inspections.

#### Acceptance Criteria

1. THE App SHALL provide a bottom navigation bar with two tabs: one for the Capture_Screen and one for the Gallery_Screen, each displaying an icon and a text label.
2. WHEN the user taps the Capture_Screen tab, THE App SHALL display the Capture_Screen and visually indicate the Capture_Screen tab as active.
3. WHEN the user taps the Gallery_Screen tab, THE App SHALL display the Gallery_Screen and visually indicate the Gallery_Screen tab as active.
4. THE App SHALL launch with the Capture_Screen as the default active tab.
5. WHILE the user is on any tab, THE App SHALL keep the bottom navigation bar visible.
6. WHEN the user switches tabs, THE App SHALL preserve the state of the previously active screen so that returning to it restores its prior content.
