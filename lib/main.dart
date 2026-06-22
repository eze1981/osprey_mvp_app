import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

import 'package:osprey_mvp_app/screens/capture_screen.dart';
import 'package:osprey_mvp_app/screens/inspections_list_screen.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';
import 'package:osprey_mvp_app/services/transcription_service.dart';

final repository = InspectionRepository();
late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final results = await Future.wait([
    availableCameras(),
    repository.init(),
  ]);
  cameras = results[0] as List<CameraDescription>;
  runApp(const OspreyApp());
  _transcribePendingItems();
}

Future<void> _transcribePendingItems() async {
  final items = await repository.getItemsWithoutTranscript();
  for (final item in items) {
    final path = repository.getAudioPath(item);
    final transcript = await TranscriptionService.transcribe(path);
    if (transcript != null && transcript.isNotEmpty) {
      await repository.updateTranscript(item.id, transcript);
    }
  }
}

class OspreyApp extends StatelessWidget {
  const OspreyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Osprey',
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  int? _activeInspectionId;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.camera), label: 'Capture'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.doc_text), label: 'Inspections'),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 0) {
          return CaptureScreen(
            repository: repository,
            cameras: cameras,
            activeInspectionId: _activeInspectionId,
          );
        }
        return InspectionsListScreen(
          repository: repository,
          onSetActive: (id) => setState(() => _activeInspectionId = id),
        );
      },
    );
  }
}
