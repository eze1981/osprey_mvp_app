import 'package:flutter/material.dart';

import 'package:osprey_mvp_app/screens/capture_screen.dart';
import 'package:osprey_mvp_app/screens/gallery_screen.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';

final repository = InspectionRepository();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await repository.init();
  runApp(const OspreyApp());
}

class OspreyApp extends StatelessWidget {
  const OspreyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Osprey',
      theme: ThemeData.dark(),
      home: const AppShell(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CaptureScreen(repository: repository),
          GalleryScreen(repository: repository),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Capture'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Gallery'),
        ],
      ),
    );
  }
}
