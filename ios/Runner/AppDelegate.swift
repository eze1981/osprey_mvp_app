import Flutter
import UIKit
import Speech

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "TranscriptionPlugin")!.messenger()
    let channel = FlutterMethodChannel(name: "osprey/transcription", binaryMessenger: messenger)

    channel.setMethodCallHandler { (call, result) in
      if call.method == "transcribe" {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
          result(FlutterError(code: "INVALID_ARG", message: "Missing path", details: nil))
          return
        }
        self.transcribeFile(path: path, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func transcribeFile(path: String, result: @escaping FlutterResult) {
    guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
      SFSpeechRecognizer.requestAuthorization { status in
        if status == .authorized {
          self.transcribeFile(path: path, result: result)
        } else {
          result(FlutterError(code: "PERMISSION", message: "Speech recognition not authorized", details: nil))
        }
      }
      return
    }

    guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
      result(FlutterError(code: "UNAVAILABLE", message: "Speech recognizer unavailable", details: nil))
      return
    }

    let url = URL(fileURLWithPath: path)
    let request = SFSpeechURLRecognitionRequest(url: url)
    request.requiresOnDeviceRecognition = true

    recognizer.recognitionTask(with: request) { (speechResult, error) in
      if let error = error {
        result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
        return
      }
      if let speechResult = speechResult, speechResult.isFinal {
        result(speechResult.bestTranscription.formattedString)
      }
    }
  }
}
