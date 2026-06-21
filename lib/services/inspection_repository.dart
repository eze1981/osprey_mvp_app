import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:osprey_mvp_app/models/inspection_item.dart';

class InspectionRepository {
  late Isar _isar;
  late Directory _photosDir;
  late Directory _audioDir;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _photosDir = Directory('${appDir.path}/photos');
    _audioDir = Directory('${appDir.path}/audio');
    await _photosDir.create(recursive: true);
    await _audioDir.create(recursive: true);

    _isar = await Isar.open(
      [InspectionItemSchema],
      directory: appDir.path,
    );
  }

  String get photosPath => _photosDir.path;
  String get audioPath => _audioDir.path;

  Future<void> saveInspection({
    required String photoPath,
    required String audioPath,
  }) async {
    final now = DateTime.now().toUtc();
    final timestamp =
        '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}_${now.millisecond}';

    final photoFileName = '$timestamp.jpg';
    final audioFileName = '$timestamp.m4a';

    // Copy files to documents directory
    final photoFile = File(photoPath);
    final audioFile = File(audioPath);

    await photoFile.copy('${_photosDir.path}/$photoFileName');
    await audioFile.copy('${_audioDir.path}/$audioFileName');

    // Write Isar record only after files are on disk
    final item = InspectionItem()
      ..photoFileName = photoFileName
      ..audioFileName = audioFileName
      ..createdAt = now;

    await _isar.writeTxn(() async {
      await _isar.inspectionItems.put(item);
    });
  }

  Future<List<InspectionItem>> getAllItems() async {
    return _isar.inspectionItems.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> deleteInspection(int id) async {
    final item = await _isar.inspectionItems.get(id);
    if (item != null) {
      final photoFile = File('${_photosDir.path}/${item.photoFileName}');
      final audioFile = File('${_audioDir.path}/${item.audioFileName}');
      if (await photoFile.exists()) await photoFile.delete();
      if (await audioFile.exists()) await audioFile.delete();
      await _isar.writeTxn(() async {
        await _isar.inspectionItems.delete(id);
      });
    }
  }

  String getPhotoPath(InspectionItem item) =>
      '${_photosDir.path}/${item.photoFileName}';

  String getAudioPath(InspectionItem item) =>
      '${_audioDir.path}/${item.audioFileName}';

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
