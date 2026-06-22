import 'package:isar_community/isar.dart';

part 'inspection_item.g.dart';

@collection
class InspectionItem {
  Id id = Isar.autoIncrement;

  @Index()
  late int inspectionId;

  late String photoFileName;
  late String audioFileName;
  String? transcript;

  @Index()
  late DateTime createdAt;
}
