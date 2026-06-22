import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

import 'package:osprey_mvp_app/models/inspection_item.dart';
import 'package:osprey_mvp_app/services/inspection_repository.dart';

class InspectionDetailScreen extends StatefulWidget {
  final InspectionItem item;
  final InspectionRepository repository;

  const InspectionDetailScreen({
    super.key,
    required this.item,
    required this.repository,
  });

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.durationStream.listen((d) {
      if (mounted && d != null) setState(() => _duration = d);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
        if (state.processingState == ProcessingState.completed) {
          _player.seek(Duration.zero);
          _player.pause();
        }
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      final path = widget.repository.getAudioPath(widget.item);
      if (_player.audioSource == null) {
        await _player.setFilePath(path);
      }
      await _player.play();
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final photoPath = widget.repository.getPhotoPath(widget.item);
    final photoExists = File(photoPath).existsSync();
    final audioPath = widget.repository.getAudioPath(widget.item);
    final audioExists = File(audioPath).existsSync();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_formatTimestamp(widget.item.createdAt)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: photoExists
                  ? Image.file(File(photoPath), fit: BoxFit.cover)
                  : Container(
                      height: 200,
                      color: CupertinoColors.systemGrey4,
                      child: const Center(
                        child: Icon(CupertinoIcons.photo,
                            color: CupertinoColors.systemGrey, size: 48),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Audio player
            if (audioExists)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.darkColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _togglePlayback,
                      child: Icon(
                        _isPlaying
                            ? CupertinoIcons.pause_circle_fill
                            : CupertinoIcons.play_circle_fill,
                        color: CupertinoColors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress bar
                          SizedBox(
                            height: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Stack(
                                children: [
                                  Container(color: CupertinoColors.systemGrey4),
                                  FractionallySizedBox(
                                    widthFactor: _duration.inMilliseconds > 0
                                        ? _position.inMilliseconds /
                                            _duration.inMilliseconds
                                        : 0,
                                    child: Container(
                                        color: CupertinoColors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                            style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (!audioExists)
              const Text('Audio file missing',
                  style: TextStyle(
                      color: CupertinoColors.destructiveRed, fontSize: 14)),
            const SizedBox(height: 16),

            // Transcript
            if (widget.item.transcript != null &&
                widget.item.transcript!.isNotEmpty)
              Text(
                widget.item.transcript!,
                style:
                    const TextStyle(color: CupertinoColors.white, fontSize: 16),
              ),
            if (widget.item.transcript == null ||
                widget.item.transcript!.isEmpty)
              const Text(
                'Transcript not available yet',
                style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
