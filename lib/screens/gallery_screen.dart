import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:osprey_mvp_app/models/inspection_item.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';

class GalleryScreen extends StatefulWidget {
  final InspectionRepository repository;
  const GalleryScreen({super.key, required this.repository});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<InspectionItem> _items = [];
  final _player = AudioPlayer();
  int? _playingId;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _playingId = null);
        _position = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await widget.repository.getAllItems();
    if (mounted) setState(() => _items = items);
  }

  Future<void> _play(InspectionItem item) async {
    if (_playingId == item.id) {
      await _player.pause();
      setState(() => _playingId = null);
      return;
    }
    final path = widget.repository.getAudioPath(item);
    if (!await File(path).exists()) return;
    await _player.stop();
    await _player.setFilePath(path);
    await _player.play();
    setState(() => _playingId = item.id);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Inspections'),
        backgroundColor: Colors.grey.shade900,
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text('No inspections yet',
                  style: TextStyle(color: Colors.white54, fontSize: 16)),
            )
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) => _buildCard(_items[index]),
              ),
            ),
    );
  }

  Widget _buildCard(InspectionItem item) {
    final photoPath = widget.repository.getPhotoPath(item);
    final photoExists = File(photoPath).existsSync();
    final audioPath = widget.repository.getAudioPath(item);
    final audioExists = File(audioPath).existsSync();
    final isPlaying = _playingId == item.id;

    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: photoExists
                    ? Image.file(File(photoPath), fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.broken_image,
                            color: Colors.white38)),
              ),
            ),
            const SizedBox(width: 12),
            // Info + playback
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTimestamp(item.createdAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                          color: audioExists ? Colors.white : Colors.white24,
                          size: 36,
                        ),
                        onPressed: audioExists ? () => _play(item) : null,
                      ),
                      if (isPlaying)
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                      if (!audioExists)
                        const Text('Audio missing',
                            style:
                                TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
