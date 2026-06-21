import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import 'package:osprey_mvp_app/services/haptic_service.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';

enum CaptureState { idle, cameraActive, recording, saving, error }

class CaptureScreen extends StatefulWidget {
  final InspectionRepository repository;
  const CaptureScreen({super.key, required this.repository});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  CaptureState _state = CaptureState.idle;
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  String? _currentPhotoPath;
  String? _currentAudioPath;
  Timer? _maxDurationTimer;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _maxDurationTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _state == CaptureState.recording) {
      _stopRecording();
    }
  }

  Future<void> _onActionButtonTap() async {
    if (_state != CaptureState.idle) return;

    setState(() => _state = CaptureState.cameraActive);
    HapticService.medium();

    final photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) {
      setState(() => _state = CaptureState.idle);
      return;
    }

    _currentPhotoPath = photo.path;
    await _startRecording();
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      setState(() {
        _state = CaptureState.error;
        _errorMessage = 'Microphone permission required';
      });
      HapticService.error();
      return;
    }

    final audioPath =
        '${widget.repository.audioPath}/recording_temp.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: audioPath,
    );

    _currentAudioPath = audioPath;
    setState(() => _state = CaptureState.recording);
    HapticService.heavy();

    // 5-minute auto-stop
    _maxDurationTimer = Timer(const Duration(minutes: 5), _stopRecording);
  }

  Future<void> _stopRecording() async {
    if (_state != CaptureState.recording) return;

    _maxDurationTimer?.cancel();
    setState(() => _state = CaptureState.saving);

    final path = await _recorder.stop();
    if (path != null) _currentAudioPath = path;

    await _saveInspection();
  }

  Future<void> _saveInspection() async {
    try {
      if (_currentPhotoPath == null || _currentAudioPath == null) {
        throw Exception('Missing media files');
      }
      if (!await File(_currentAudioPath!).exists()) {
        throw Exception('Audio file not found');
      }

      await widget.repository.saveInspection(
        photoPath: _currentPhotoPath!,
        audioPath: _currentAudioPath!,
      );

      HapticService.success();
      setState(() => _state = CaptureState.idle);
    } catch (e) {
      HapticService.error();
      setState(() {
        _state = CaptureState.error;
        _errorMessage = 'Could not save inspection';
      });
    } finally {
      _currentPhotoPath = null;
      _currentAudioPath = null;
    }
  }

  void _dismissError() {
    setState(() => _state = CaptureState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main action button (idle state)
            if (_state == CaptureState.idle || _state == CaptureState.cameraActive)
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.45,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ElevatedButton(
                      onPressed:
                          _state == CaptureState.idle ? _onActionButtonTap : null,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Icon(Icons.camera_alt, size: 48),
                    ),
                  ),
                ),
              ),

            // Recording UI
            if (_state == CaptureState.recording)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Recording...',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),

            // Saving indicator
            if (_state == CaptureState.saving)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Error snackbar
            if (_state == CaptureState.error)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _dismissError,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
