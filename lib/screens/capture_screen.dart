import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:record/record.dart';

import 'package:osprey_mvp_app/services/haptic_service.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';
import 'package:osprey_mvp_app/services/transcription_service.dart';

enum CaptureState { initializing, idle, recording, saving, error }

class CaptureScreen extends StatefulWidget {
  final InspectionRepository repository;
  final List<CameraDescription> cameras;
  final int? activeInspectionId;
  const CaptureScreen({super.key, required this.repository, required this.cameras, this.activeInspectionId});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  CaptureState _state = CaptureState.initializing;
  CameraController? _cameraController;
  final _recorder = AudioRecorder();
  String? _currentPhotoPath;
  String? _currentAudioPath;
  Timer? _maxDurationTimer;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  String _errorMessage = '';

  bool _hasMicPermission = false;
  bool _showSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _maxDurationTimer?.cancel();
    _elapsedTimer?.cancel();
    _cameraController?.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _state == CaptureState.recording) {
      _stopRecording();
    }
    // Reinitialize camera when app resumes
    if (state == AppLifecycleState.resumed &&
        (_cameraController == null ||
            !_cameraController!.value.isInitialized)) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      if (widget.cameras.isEmpty) {
        setState(() {
          _state = CaptureState.error;
          _errorMessage = 'No camera available';
        });
        return;
      }

      final controller = CameraController(
        widget.cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) return;

      _cameraController = controller;
      _hasMicPermission = await _recorder.hasPermission();
      setState(() => _state = CaptureState.idle);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = CaptureState.error;
        _errorMessage = 'Camera initialization failed';
      });
    }
  }

  Future<void> _onCaptureTap() async {
    if (_state != CaptureState.idle) return;
    if (widget.activeInspectionId == null) {
      setState(() {
        _state = CaptureState.error;
        _errorMessage = 'Create an inspection first';
      });
      return;
    }
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (!_hasMicPermission) {
      _hasMicPermission = await _recorder.hasPermission();
      if (!_hasMicPermission) {
        setState(() {
          _state = CaptureState.error;
          _errorMessage = 'Microphone permission required';
        });
        HapticService.error();
        return;
      }
    }

    HapticService.medium();

    try {
      // Take photo first (shutter sound happens here)
      final photo = await _cameraController!.takePicture();
      _currentPhotoPath = photo.path;

      // Pause preview to show captured frame during recording
      await _cameraController!.pausePreview();

      // Show recording UI immediately, then start recorder
      final audioPath = '${widget.repository.audioPath}/recording_temp.m4a';
      _currentAudioPath = audioPath;
      _elapsed = Duration.zero;
      setState(() => _state = CaptureState.recording);
      HapticService.heavy();

      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: audioPath,
      );

      _maxDurationTimer = Timer(const Duration(minutes: 5), _stopRecording);
    } catch (e) {
      setState(() {
        _state = CaptureState.error;
        _errorMessage = 'Failed to start capture';
      });
      HapticService.error();
    }
  }

  Future<void> _stopRecording() async {
    if (_state != CaptureState.recording) return;

    _maxDurationTimer?.cancel();
    _elapsedTimer?.cancel();
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

      final savedId = await widget.repository.saveInspection(
        inspectionId: widget.activeInspectionId!,
        photoPath: _currentPhotoPath!,
        audioPath: _currentAudioPath!,
      );

      HapticService.success();
      await _cameraController?.resumePreview();
      setState(() {
        _state = CaptureState.idle;
        _showSaved = true;
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showSaved = false);
      });

      // Transcribe in background (fire-and-forget)
      final audioPath = _currentAudioPath!;
      _transcribeInBackground(savedId, audioPath);
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

  Future<void> _transcribeInBackground(int id, String audioPath) async {
    final transcript = await TranscriptionService.transcribe(audioPath);
    if (transcript != null && transcript.isNotEmpty) {
      await widget.repository.updateTranscript(id, transcript);
    }
  }

  void _dismissError() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _cameraController!.resumePreview();
      setState(() => _state = CaptureState.idle);
    } else {
      _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // Live camera preview
            if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),

            // Initializing indicator
            if (_state == CaptureState.initializing)
              const Center(
                child: CupertinoActivityIndicator(
                    radius: 16, color: CupertinoColors.white),
              ),

            // Saved confirmation
            if (_showSaved)
              const Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Text('Saved ✓',
                      style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ),
              ),

            // Capture button (idle)
            if (_state == CaptureState.idle)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _onCaptureTap,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: CupertinoColors.white, width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tap to capture',
                        style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 13)),
                  ],
                ),
              ),

            // Recording UI overlay
            if (_state == CaptureState.recording)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.mic_fill,
                            color: CupertinoColors.destructiveRed, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${_elapsed.inMinutes.toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              color: CupertinoColors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _stopRecording,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: CupertinoColors.destructiveRed, width: 4),
                        ),
                        child: const Center(
                          child: Icon(CupertinoIcons.stop_fill,
                              color: CupertinoColors.destructiveRed, size: 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Saving indicator
            if (_state == CaptureState.saving)
              const Center(
                child: CupertinoActivityIndicator(
                    radius: 16, color: CupertinoColors.white),
              ),

            // Error overlay
            if (_state == CaptureState.error)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.destructiveRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style:
                              const TextStyle(color: CupertinoColors.white),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _dismissError,
                        child: const Icon(CupertinoIcons.xmark,
                            color: CupertinoColors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
