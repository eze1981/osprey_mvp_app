// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInspectionItemCollection on Isar {
  IsarCollection<InspectionItem> get inspectionItems => this.collection();
}

const InspectionItemSchema = CollectionSchema(
  name: r'InspectionItem',
  id: -6751097337301253472,
  properties: {
    r'audioFileName': PropertySchema(
      id: 0,
      name: r'audioFileName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'photoFileName': PropertySchema(
      id: 2,
      name: r'photoFileName',
      type: IsarType.string,
    ),
  },

  estimateSize: _inspectionItemEstimateSize,
  serialize: _inspectionItemSerialize,
  deserialize: _inspectionItemDeserialize,
  deserializeProp: _inspectionItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _inspectionItemGetId,
  getLinks: _inspectionItemGetLinks,
  attach: _inspectionItemAttach,
  version: '3.3.2',
);

int _inspectionItemEstimateSize(
  InspectionItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.audioFileName.length * 3;
  bytesCount += 3 + object.photoFileName.length * 3;
  return bytesCount;
}

void _inspectionItemSerialize(
  InspectionItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.audioFileName);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.photoFileName);
}

InspectionItem _inspectionItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InspectionItem();
  object.audioFileName = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.photoFileName = reader.readString(offsets[2]);
  return object;
}

P _inspectionItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inspectionItemGetId(InspectionItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inspectionItemGetLinks(InspectionItem object) {
  return [];
}

void _inspectionItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  InspectionItem object,
) {
  object.id = id;
}

extension InspectionItemQueryWhereSort
    on QueryBuilder<InspectionItem, InspectionItem, QWhere> {
  QueryBuilder<InspectionItem, InspectionItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension InspectionItemQueryWhere
    on QueryBuilder<InspectionItem, InspectionItem, QWhereClause> {
  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause>
  createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'createdAt', value: [createdAt]),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause>
  createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause>
  createdAtGreaterThan(DateTime createdAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [createdAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause>
  createdAtLessThan(DateTime createdAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [],
          upper: [createdAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterWhereClause>
  createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [lowerCreatedAt],
          includeLower: includeLower,
          upper: [upperCreatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension InspectionItemQueryFilter
    on QueryBuilder<InspectionItem, InspectionItem, QFilterCondition> {
  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'audioFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'audioFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'audioFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'audioFileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'audioFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'audioFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'audioFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'audioFileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audioFileName', value: ''),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  audioFileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'audioFileName', value: ''),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'photoFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'photoFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'photoFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'photoFileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'photoFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'photoFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'photoFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'photoFileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'photoFileName', value: ''),
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterFilterCondition>
  photoFileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'photoFileName', value: ''),
      );
    });
  }
}

extension InspectionItemQueryObject
    on QueryBuilder<InspectionItem, InspectionItem, QFilterCondition> {}

extension InspectionItemQueryLinks
    on QueryBuilder<InspectionItem, InspectionItem, QFilterCondition> {}

extension InspectionItemQuerySortBy
    on QueryBuilder<InspectionItem, InspectionItem, QSortBy> {
  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  sortByAudioFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFileName', Sort.asc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  sortByAudioFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFileName', Sort.desc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  sortByPhotoFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoFileName', Sort.asc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  sortByPhotoFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoFileName', Sort.desc);
    });
  }
}

extension InspectionItemQuerySortThenBy
    on QueryBuilder<InspectionItem, InspectionItem, QSortThenBy> {
  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  thenByAudioFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFileName', Sort.asc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  thenByAudioFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFileName', Sort.desc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  thenByPhotoFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoFileName', Sort.asc);
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QAfterSortBy>
  thenByPhotoFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoFileName', Sort.desc);
    });
  }
}

extension InspectionItemQueryWhereDistinct
    on QueryBuilder<InspectionItem, InspectionItem, QDistinct> {
  QueryBuilder<InspectionItem, InspectionItem, QDistinct>
  distinctByAudioFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'audioFileName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InspectionItem, InspectionItem, QDistinct>
  distinctByPhotoFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'photoFileName',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension InspectionItemQueryProperty
    on QueryBuilder<InspectionItem, InspectionItem, QQueryProperty> {
  QueryBuilder<InspectionItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InspectionItem, String, QQueryOperations>
  audioFileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioFileName');
    });
  }

  QueryBuilder<InspectionItem, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InspectionItem, String, QQueryOperations>
  photoFileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoFileName');
    });
  }
}
