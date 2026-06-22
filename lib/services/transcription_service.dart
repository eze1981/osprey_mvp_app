import 'package:flutter/services.dart';

class TranscriptionService {
  static const _channel = MethodChannel('osprey/transcription');

  /// Transcribes an audio file on-device using iOS SFSpeechRecognizer.
  /// Returns the transcript text, or null if transcription fails.
  static Future<String?> transcribe(String audioFilePath) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'transcribe',
        {'path': audioFilePath},
      );
      return result;
    } on PlatformException {
      return null;
    }
  }
}
