import 'package:isar_community/isar.dart';

part 'inspection_item.g.dart';

@collection
class InspectionItem {
  Id id = Isar.autoIncrement;

  late String photoFileName;
  late String audioFileName;

  @Index()
  late DateTime createdAt;
}
