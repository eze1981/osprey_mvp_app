import 'package:isar_community/isar.dart';

part 'inspection.g.dart';

@collection
class Inspection {
  Id id = Isar.autoIncrement;

  late String name;

  @Index()
  late DateTime createdAt;
}
