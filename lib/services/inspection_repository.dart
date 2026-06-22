import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:osprey_mvp_app/models/inspection.dart';
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
      [InspectionSchema, InspectionItemSchema],
      directory: appDir.path,
    );
  }

  String get photosPath => _photosDir.path;
  String get audioPath => _audioDir.path;

  // --- Inspection CRUD ---

  Future<int> createInspection(String name) async {
    final inspection = Inspection()
      ..name = name
      ..createdAt = DateTime.now().toUtc();
    await _isar.writeTxn(() async {
      await _isar.inspections.put(inspection);
    });
    return inspection.id;
  }

  Future<List<Inspection>> getAllInspections() async {
    return _isar.inspections.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> deleteInspection(int inspectionId) async {
    // Delete all items belonging to this inspection
    final items = await getItemsForInspection(inspectionId);
    for (final item in items) {
      await _deleteItemFiles(item);
    }
    await _isar.writeTxn(() async {
      await _isar.inspectionItems
          .filter()
          .inspectionIdEqualTo(inspectionId)
          .deleteAll();
      await _isar.inspections.delete(inspectionId);
    });
  }

  Future<int> getItemCount(int inspectionId) async {
    return _isar.inspectionItems
        .filter()
        .inspectionIdEqualTo(inspectionId)
        .count();
  }

  // --- InspectionItem CRUD ---

  Future<int> saveInspection({
    required int inspectionId,
    required String photoPath,
    required String audioPath,
  }) async {
    final now = DateTime.now().toUtc();
    final timestamp =
        '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}_${now.millisecond}';

    final photoFileName = '$timestamp.jpg';
    final audioFileName = '$timestamp.m4a';

    final photoFile = File(photoPath);
    final audioFile = File(audioPath);

    await photoFile.copy('${_photosDir.path}/$photoFileName');
    await audioFile.copy('${_audioDir.path}/$audioFileName');

    final item = InspectionItem()
      ..inspectionId = inspectionId
      ..photoFileName = photoFileName
      ..audioFileName = audioFileName
      ..createdAt = now;

    await _isar.writeTxn(() async {
      await _isar.inspectionItems.put(item);
    });

    return item.id;
  }

  Future<List<InspectionItem>> getItemsForInspection(int inspectionId) async {
    return _isar.inspectionItems
        .filter()
        .inspectionIdEqualTo(inspectionId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<InspectionItem>> getItemsWithoutTranscript() async {
    return _isar.inspectionItems.filter().transcriptIsNull().findAll();
  }

  Future<void> updateTranscript(int id, String transcript) async {
    await _isar.writeTxn(() async {
      final item = await _isar.inspectionItems.get(id);
      if (item != null) {
        item.transcript = transcript;
        await _isar.inspectionItems.put(item);
      }
    });
  }

  Future<void> deleteItem(int id) async {
    final item = await _isar.inspectionItems.get(id);
    if (item != null) {
      await _deleteItemFiles(item);
      await _isar.writeTxn(() async {
        await _isar.inspectionItems.delete(id);
      });
    }
  }

  Future<void> _deleteItemFiles(InspectionItem item) async {
    final photoFile = File('${_photosDir.path}/${item.photoFileName}');
    final audioFile = File('${_audioDir.path}/${item.audioFileName}');
    if (await photoFile.exists()) await photoFile.delete();
    if (await audioFile.exists()) await audioFile.delete();
  }

  String getPhotoPath(InspectionItem item) =>
      '${_photosDir.path}/${item.photoFileName}';

  String getAudioPath(InspectionItem item) =>
      '${_audioDir.path}/${item.audioFileName}';

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
