// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GlobalDB.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMediaPlaylistDBCollection on Isar {
  IsarCollection<MediaPlaylistDB> get mediaPlaylistDBs => this.collection();
}

const MediaPlaylistDBSchema = CollectionSchema(
  name: r'MediaPlaylistDB',
  id: 6090471689057609940,
  properties: {
    r'hashCode': PropertySchema(
      id: 0,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'lastUpdated': PropertySchema(
      id: 1,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'mediaRanks': PropertySchema(
      id: 2,
      name: r'mediaRanks',
      type: IsarType.longList,
    ),
    r'playlistName': PropertySchema(
      id: 3,
      name: r'playlistName',
      type: IsarType.string,
    )
  },
  estimateSize: _mediaPlaylistDBEstimateSize,
  serialize: _mediaPlaylistDBSerialize,
  deserialize: _mediaPlaylistDBDeserialize,
  deserializeProp: _mediaPlaylistDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {
    r'mediaItems': LinkSchema(
      id: -3256593681391473623,
      name: r'mediaItems',
      target: r'MediaItemDB',
      single: false,
      linkName: r'mediaInPlaylistsDB',
    )
  },
  embeddedSchemas: {},
  getId: _mediaPlaylistDBGetId,
  getLinks: _mediaPlaylistDBGetLinks,
  attach: _mediaPlaylistDBAttach,
  version: '3.1.8',
);

int _mediaPlaylistDBEstimateSize(
  MediaPlaylistDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mediaRanks.length * 8;
  bytesCount += 3 + object.playlistName.length * 3;
  return bytesCount;
}

void _mediaPlaylistDBSerialize(
  MediaPlaylistDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hashCode);
  writer.writeDateTime(offsets[1], object.lastUpdated);
  writer.writeLongList(offsets[2], object.mediaRanks);
  writer.writeString(offsets[3], object.playlistName);
}

MediaPlaylistDB _mediaPlaylistDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MediaPlaylistDB(
    lastUpdated: reader.readDateTimeOrNull(offsets[1]),
    playlistName: reader.readString(offsets[3]),
  );
  object.mediaRanks = reader.readLongList(offsets[2]) ?? [];
  return object;
}

P _mediaPlaylistDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLongList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mediaPlaylistDBGetId(MediaPlaylistDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _mediaPlaylistDBGetLinks(MediaPlaylistDB object) {
  return [object.mediaItems];
}

void _mediaPlaylistDBAttach(
    IsarCollection<dynamic> col, Id id, MediaPlaylistDB object) {
  object.mediaItems
      .attach(col, col.isar.collection<MediaItemDB>(), r'mediaItems', id);
}

extension MediaPlaylistDBQueryWhereSort
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QWhere> {
  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MediaPlaylistDBQueryWhere
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QWhereClause> {
  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MediaPlaylistDBQueryFilter
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QFilterCondition> {
  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaRanks',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaRanks',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaRanks',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaRanks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaRanks',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaRanks',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaRanks',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaRanks',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaRanks',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaRanksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaRanks',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playlistName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistName',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      playlistNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playlistName',
        value: '',
      ));
    });
  }
}

extension MediaPlaylistDBQueryObject
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QFilterCondition> {}

extension MediaPlaylistDBQueryLinks
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QFilterCondition> {
  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaItems(FilterQuery<MediaItemDB> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'mediaItems');
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaItemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaItems', length, true, length, true);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaItemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaItems', 0, true, 0, true);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaItemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaItems', 0, false, 999999, true);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaItemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaItems', 0, true, length, include);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaItemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaItems', length, include, 999999, true);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterFilterCondition>
      mediaItemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'mediaItems', lower, includeLower, upper, includeUpper);
    });
  }
}

extension MediaPlaylistDBQuerySortBy
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QSortBy> {
  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      sortByPlaylistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.asc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      sortByPlaylistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.desc);
    });
  }
}

extension MediaPlaylistDBQuerySortThenBy
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QSortThenBy> {
  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      thenByPlaylistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.asc);
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QAfterSortBy>
      thenByPlaylistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.desc);
    });
  }
}

extension MediaPlaylistDBQueryWhereDistinct
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QDistinct> {
  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QDistinct>
      distinctByMediaRanks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaRanks');
    });
  }

  QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QDistinct>
      distinctByPlaylistName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistName', caseSensitive: caseSensitive);
    });
  }
}

extension MediaPlaylistDBQueryProperty
    on QueryBuilder<MediaPlaylistDB, MediaPlaylistDB, QQueryProperty> {
  QueryBuilder<MediaPlaylistDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<MediaPlaylistDB, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<MediaPlaylistDB, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<MediaPlaylistDB, List<int>, QQueryOperations>
      mediaRanksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaRanks');
    });
  }

  QueryBuilder<MediaPlaylistDB, String, QQueryOperations>
      playlistNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistName');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaylistsInfoDBCollection on Isar {
  IsarCollection<PlaylistsInfoDB> get playlistsInfoDBs => this.collection();
}

const PlaylistsInfoDBSchema = CollectionSchema(
  name: r'PlaylistsInfoDB',
  id: 1617157397511618734,
  properties: {
    r'artURL': PropertySchema(
      id: 0,
      name: r'artURL',
      type: IsarType.string,
    ),
    r'artists': PropertySchema(
      id: 1,
      name: r'artists',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 3,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'isAlbum': PropertySchema(
      id: 4,
      name: r'isAlbum',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 5,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'permaURL': PropertySchema(
      id: 6,
      name: r'permaURL',
      type: IsarType.string,
    ),
    r'playlistName': PropertySchema(
      id: 7,
      name: r'playlistName',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 8,
      name: r'source',
      type: IsarType.string,
    )
  },
  estimateSize: _playlistsInfoDBEstimateSize,
  serialize: _playlistsInfoDBSerialize,
  deserialize: _playlistsInfoDBDeserialize,
  deserializeProp: _playlistsInfoDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _playlistsInfoDBGetId,
  getLinks: _playlistsInfoDBGetLinks,
  attach: _playlistsInfoDBAttach,
  version: '3.1.8',
);

int _playlistsInfoDBEstimateSize(
  PlaylistsInfoDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.artURL;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artists;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.permaURL;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.playlistName.length * 3;
  {
    final value = object.source;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _playlistsInfoDBSerialize(
  PlaylistsInfoDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artURL);
  writer.writeString(offsets[1], object.artists);
  writer.writeString(offsets[2], object.description);
  writer.writeLong(offsets[3], object.hashCode);
  writer.writeBool(offsets[4], object.isAlbum);
  writer.writeDateTime(offsets[5], object.lastUpdated);
  writer.writeString(offsets[6], object.permaURL);
  writer.writeString(offsets[7], object.playlistName);
  writer.writeString(offsets[8], object.source);
}

PlaylistsInfoDB _playlistsInfoDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlaylistsInfoDB(
    artURL: reader.readStringOrNull(offsets[0]),
    artists: reader.readStringOrNull(offsets[1]),
    description: reader.readStringOrNull(offsets[2]),
    isAlbum: reader.readBoolOrNull(offsets[4]),
    lastUpdated: reader.readDateTime(offsets[5]),
    permaURL: reader.readStringOrNull(offsets[6]),
    playlistName: reader.readString(offsets[7]),
    source: reader.readStringOrNull(offsets[8]),
  );
  return object;
}

P _playlistsInfoDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playlistsInfoDBGetId(PlaylistsInfoDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _playlistsInfoDBGetLinks(PlaylistsInfoDB object) {
  return [];
}

void _playlistsInfoDBAttach(
    IsarCollection<dynamic> col, Id id, PlaylistsInfoDB object) {}

extension PlaylistsInfoDBQueryWhereSort
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QWhere> {
  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlaylistsInfoDBQueryWhere
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QWhereClause> {
  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlaylistsInfoDBQueryFilter
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QFilterCondition> {
  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artURL',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artURL',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artURL',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artURL',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artists',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artists',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artists',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artists',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artists',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      artistsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artists',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      isAlbumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isAlbum',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      isAlbumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isAlbum',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      isAlbumEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAlbum',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'permaURL',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'permaURL',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permaURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'permaURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permaURL',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      permaURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'permaURL',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playlistName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      playlistNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playlistName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }
}

extension PlaylistsInfoDBQueryObject
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QFilterCondition> {}

extension PlaylistsInfoDBQueryLinks
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QFilterCondition> {}

extension PlaylistsInfoDBQuerySortBy
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QSortBy> {
  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> sortByArtURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artURL', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByArtURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artURL', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> sortByArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artists', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artists', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> sortByIsAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlbum', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByIsAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlbum', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByPermaURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByPermaURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByPlaylistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortByPlaylistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }
}

extension PlaylistsInfoDBQuerySortThenBy
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QSortThenBy> {
  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> thenByArtURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artURL', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByArtURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artURL', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> thenByArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artists', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artists', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> thenByIsAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlbum', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByIsAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlbum', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByPermaURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByPermaURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByPlaylistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenByPlaylistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.desc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }
}

extension PlaylistsInfoDBQueryWhereDistinct
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct> {
  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct> distinctByArtURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct> distinctByArtists(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artists', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct>
      distinctByIsAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAlbum');
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct> distinctByPermaURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permaURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct>
      distinctByPlaylistName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }
}

extension PlaylistsInfoDBQueryProperty
    on QueryBuilder<PlaylistsInfoDB, PlaylistsInfoDB, QQueryProperty> {
  QueryBuilder<PlaylistsInfoDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<PlaylistsInfoDB, String?, QQueryOperations> artURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artURL');
    });
  }

  QueryBuilder<PlaylistsInfoDB, String?, QQueryOperations> artistsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artists');
    });
  }

  QueryBuilder<PlaylistsInfoDB, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<PlaylistsInfoDB, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<PlaylistsInfoDB, bool?, QQueryOperations> isAlbumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAlbum');
    });
  }

  QueryBuilder<PlaylistsInfoDB, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<PlaylistsInfoDB, String?, QQueryOperations> permaURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permaURL');
    });
  }

  QueryBuilder<PlaylistsInfoDB, String, QQueryOperations>
      playlistNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistName');
    });
  }

  QueryBuilder<PlaylistsInfoDB, String?, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMediaItemDBCollection on Isar {
  IsarCollection<MediaItemDB> get mediaItemDBs => this.collection();
}

const MediaItemDBSchema = CollectionSchema(
  name: r'MediaItemDB',
  id: 7205399312875226514,
  properties: {
    r'album': PropertySchema(
      id: 0,
      name: r'album',
      type: IsarType.string,
    ),
    r'artURL': PropertySchema(
      id: 1,
      name: r'artURL',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 2,
      name: r'artist',
      type: IsarType.string,
    ),
    r'duration': PropertySchema(
      id: 3,
      name: r'duration',
      type: IsarType.long,
    ),
    r'genre': PropertySchema(
      id: 4,
      name: r'genre',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 5,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'isLiked': PropertySchema(
      id: 6,
      name: r'isLiked',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 7,
      name: r'language',
      type: IsarType.string,
    ),
    r'mediaID': PropertySchema(
      id: 8,
      name: r'mediaID',
      type: IsarType.string,
    ),
    r'permaURL': PropertySchema(
      id: 9,
      name: r'permaURL',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 10,
      name: r'source',
      type: IsarType.string,
    ),
    r'streamingURL': PropertySchema(
      id: 11,
      name: r'streamingURL',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _mediaItemDBEstimateSize,
  serialize: _mediaItemDBSerialize,
  deserialize: _mediaItemDBDeserialize,
  deserializeProp: _mediaItemDBDeserializeProp,
  idName: r'id',
  indexes: {
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'mediaInPlaylistsDB': LinkSchema(
      id: 6308841877349556711,
      name: r'mediaInPlaylistsDB',
      target: r'MediaPlaylistDB',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _mediaItemDBGetId,
  getLinks: _mediaItemDBGetLinks,
  attach: _mediaItemDBAttach,
  version: '3.1.8',
);

int _mediaItemDBEstimateSize(
  MediaItemDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.album.length * 3;
  bytesCount += 3 + object.artURL.length * 3;
  bytesCount += 3 + object.artist.length * 3;
  bytesCount += 3 + object.genre.length * 3;
  bytesCount += 3 + object.language.length * 3;
  bytesCount += 3 + object.mediaID.length * 3;
  bytesCount += 3 + object.permaURL.length * 3;
  {
    final value = object.source;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.streamingURL.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _mediaItemDBSerialize(
  MediaItemDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.album);
  writer.writeString(offsets[1], object.artURL);
  writer.writeString(offsets[2], object.artist);
  writer.writeLong(offsets[3], object.duration);
  writer.writeString(offsets[4], object.genre);
  writer.writeLong(offsets[5], object.hashCode);
  writer.writeBool(offsets[6], object.isLiked);
  writer.writeString(offsets[7], object.language);
  writer.writeString(offsets[8], object.mediaID);
  writer.writeString(offsets[9], object.permaURL);
  writer.writeString(offsets[10], object.source);
  writer.writeString(offsets[11], object.streamingURL);
  writer.writeString(offsets[12], object.title);
}

MediaItemDB _mediaItemDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MediaItemDB(
    album: reader.readString(offsets[0]),
    artURL: reader.readString(offsets[1]),
    artist: reader.readString(offsets[2]),
    duration: reader.readLongOrNull(offsets[3]),
    genre: reader.readString(offsets[4]),
    id: id,
    isLiked: reader.readBool(offsets[6]),
    language: reader.readString(offsets[7]),
    mediaID: reader.readString(offsets[8]),
    permaURL: reader.readString(offsets[9]),
    source: reader.readStringOrNull(offsets[10]),
    streamingURL: reader.readString(offsets[11]),
    title: reader.readString(offsets[12]),
  );
  return object;
}

P _mediaItemDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mediaItemDBGetId(MediaItemDB object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _mediaItemDBGetLinks(MediaItemDB object) {
  return [object.mediaInPlaylistsDB];
}

void _mediaItemDBAttach(
    IsarCollection<dynamic> col, Id id, MediaItemDB object) {
  object.id = id;
  object.mediaInPlaylistsDB.attach(
      col, col.isar.collection<MediaPlaylistDB>(), r'mediaInPlaylistsDB', id);
}

extension MediaItemDBQueryWhereSort
    on QueryBuilder<MediaItemDB, MediaItemDB, QWhere> {
  QueryBuilder<MediaItemDB, MediaItemDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MediaItemDBQueryWhere
    on QueryBuilder<MediaItemDB, MediaItemDB, QWhereClause> {
  QueryBuilder<MediaItemDB, MediaItemDB, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterWhereClause> titleEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterWhereClause> titleNotEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MediaItemDBQueryFilter
    on QueryBuilder<MediaItemDB, MediaItemDB, QFilterCondition> {
  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> albumEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      albumGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> albumLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> albumBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'album',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> albumContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> albumMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'album',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artURLEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      artURLGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artURLLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artURLBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      artURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artURLContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artURLMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      artURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artURL',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      artURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artURL',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artistEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      artistGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artistLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artistBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artistContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> artistMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> durationEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> genreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      genreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> genreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> genreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> genreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> genreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> genreContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> genreMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> genreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      genreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> hashCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> isLikedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLiked',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> languageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> mediaIDEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaIDGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> mediaIDLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> mediaIDBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaID',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaIDStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> mediaIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> mediaIDContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> mediaIDMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaID',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaID',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaID',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> permaURLEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      permaURLGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      permaURLLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> permaURLBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permaURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      permaURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      permaURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      permaURLContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> permaURLMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'permaURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      permaURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permaURL',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      permaURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'permaURL',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> sourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      sourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> sourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      sourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> sourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> sourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> sourceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> sourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamingURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamingURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamingURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamingURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streamingURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streamingURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamingURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamingURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamingURL',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      streamingURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamingURL',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension MediaItemDBQueryObject
    on QueryBuilder<MediaItemDB, MediaItemDB, QFilterCondition> {}

extension MediaItemDBQueryLinks
    on QueryBuilder<MediaItemDB, MediaItemDB, QFilterCondition> {
  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaInPlaylistsDB(FilterQuery<MediaPlaylistDB> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'mediaInPlaylistsDB');
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaInPlaylistsDBLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'mediaInPlaylistsDB', length, true, length, true);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaInPlaylistsDBIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaInPlaylistsDB', 0, true, 0, true);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaInPlaylistsDBIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaInPlaylistsDB', 0, false, 999999, true);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaInPlaylistsDBLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaInPlaylistsDB', 0, true, length, include);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaInPlaylistsDBLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'mediaInPlaylistsDB', length, include, 999999, true);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterFilterCondition>
      mediaInPlaylistsDBLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'mediaInPlaylistsDB', lower, includeLower, upper, includeUpper);
    });
  }
}

extension MediaItemDBQuerySortBy
    on QueryBuilder<MediaItemDB, MediaItemDB, QSortBy> {
  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByArtURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artURL', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByArtURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artURL', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByIsLiked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiked', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByIsLikedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiked', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByMediaID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaID', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByMediaIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaID', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByPermaURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByPermaURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByStreamingURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamingURL', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy>
      sortByStreamingURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamingURL', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension MediaItemDBQuerySortThenBy
    on QueryBuilder<MediaItemDB, MediaItemDB, QSortThenBy> {
  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByArtURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artURL', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByArtURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artURL', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByIsLiked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiked', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByIsLikedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiked', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByMediaID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaID', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByMediaIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaID', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByPermaURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByPermaURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByStreamingURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamingURL', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy>
      thenByStreamingURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamingURL', Sort.desc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension MediaItemDBQueryWhereDistinct
    on QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> {
  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByAlbum(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByArtURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByGenre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByIsLiked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLiked');
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByMediaID(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByPermaURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permaURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByStreamingURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamingURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaItemDB, MediaItemDB, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension MediaItemDBQueryProperty
    on QueryBuilder<MediaItemDB, MediaItemDB, QQueryProperty> {
  QueryBuilder<MediaItemDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> artURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artURL');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<MediaItemDB, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> genreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genre');
    });
  }

  QueryBuilder<MediaItemDB, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<MediaItemDB, bool, QQueryOperations> isLikedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLiked');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> mediaIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaID');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> permaURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permaURL');
    });
  }

  QueryBuilder<MediaItemDB, String?, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> streamingURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamingURL');
    });
  }

  QueryBuilder<MediaItemDB, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsStrDBCollection on Isar {
  IsarCollection<AppSettingsStrDB> get appSettingsStrDBs => this.collection();
}

const AppSettingsStrDBSchema = CollectionSchema(
  name: r'AppSettingsStrDB',
  id: -9186585785377851692,
  properties: {
    r'hashCode': PropertySchema(
      id: 0,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'lastUpdated': PropertySchema(
      id: 1,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'settingName': PropertySchema(
      id: 2,
      name: r'settingName',
      type: IsarType.string,
    ),
    r'settingValue': PropertySchema(
      id: 3,
      name: r'settingValue',
      type: IsarType.string,
    ),
    r'settingValue2': PropertySchema(
      id: 4,
      name: r'settingValue2',
      type: IsarType.string,
    )
  },
  estimateSize: _appSettingsStrDBEstimateSize,
  serialize: _appSettingsStrDBSerialize,
  deserialize: _appSettingsStrDBDeserialize,
  deserializeProp: _appSettingsStrDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsStrDBGetId,
  getLinks: _appSettingsStrDBGetLinks,
  attach: _appSettingsStrDBAttach,
  version: '3.1.8',
);

int _appSettingsStrDBEstimateSize(
  AppSettingsStrDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.settingName.length * 3;
  bytesCount += 3 + object.settingValue.length * 3;
  {
    final value = object.settingValue2;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _appSettingsStrDBSerialize(
  AppSettingsStrDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hashCode);
  writer.writeDateTime(offsets[1], object.lastUpdated);
  writer.writeString(offsets[2], object.settingName);
  writer.writeString(offsets[3], object.settingValue);
  writer.writeString(offsets[4], object.settingValue2);
}

AppSettingsStrDB _appSettingsStrDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsStrDB(
    lastUpdated: reader.readDateTimeOrNull(offsets[1]),
    settingName: reader.readString(offsets[2]),
    settingValue: reader.readString(offsets[3]),
    settingValue2: reader.readStringOrNull(offsets[4]),
  );
  return object;
}

P _appSettingsStrDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsStrDBGetId(AppSettingsStrDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _appSettingsStrDBGetLinks(AppSettingsStrDB object) {
  return [];
}

void _appSettingsStrDBAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsStrDB object) {}

extension AppSettingsStrDBQueryWhereSort
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QWhere> {
  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsStrDBQueryWhere
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QWhereClause> {
  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsStrDBQueryFilter
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QFilterCondition> {
  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settingValue2',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settingValue2',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingValue2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingValue2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingValue2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingValue2',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingValue2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingValue2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingValue2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingValue2',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingValue2',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterFilterCondition>
      settingValue2IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingValue2',
        value: '',
      ));
    });
  }
}

extension AppSettingsStrDBQueryObject
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QFilterCondition> {}

extension AppSettingsStrDBQueryLinks
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QFilterCondition> {}

extension AppSettingsStrDBQuerySortBy
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QSortBy> {
  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortBySettingName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingName', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortBySettingNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingName', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortBySettingValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortBySettingValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortBySettingValue2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue2', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      sortBySettingValue2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue2', Sort.desc);
    });
  }
}

extension AppSettingsStrDBQuerySortThenBy
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QSortThenBy> {
  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenBySettingName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingName', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenBySettingNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingName', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenBySettingValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenBySettingValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenBySettingValue2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue2', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QAfterSortBy>
      thenBySettingValue2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue2', Sort.desc);
    });
  }
}

extension AppSettingsStrDBQueryWhereDistinct
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QDistinct> {
  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QDistinct>
      distinctBySettingName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QDistinct>
      distinctBySettingValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QDistinct>
      distinctBySettingValue2({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingValue2',
          caseSensitive: caseSensitive);
    });
  }
}

extension AppSettingsStrDBQueryProperty
    on QueryBuilder<AppSettingsStrDB, AppSettingsStrDB, QQueryProperty> {
  QueryBuilder<AppSettingsStrDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<AppSettingsStrDB, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<AppSettingsStrDB, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<AppSettingsStrDB, String, QQueryOperations>
      settingNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingName');
    });
  }

  QueryBuilder<AppSettingsStrDB, String, QQueryOperations>
      settingValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingValue');
    });
  }

  QueryBuilder<AppSettingsStrDB, String?, QQueryOperations>
      settingValue2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingValue2');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsBoolDBCollection on Isar {
  IsarCollection<AppSettingsBoolDB> get appSettingsBoolDBs => this.collection();
}

const AppSettingsBoolDBSchema = CollectionSchema(
  name: r'AppSettingsBoolDB',
  id: -3642544654543208017,
  properties: {
    r'hashCode': PropertySchema(
      id: 0,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'settingName': PropertySchema(
      id: 1,
      name: r'settingName',
      type: IsarType.string,
    ),
    r'settingValue': PropertySchema(
      id: 2,
      name: r'settingValue',
      type: IsarType.bool,
    )
  },
  estimateSize: _appSettingsBoolDBEstimateSize,
  serialize: _appSettingsBoolDBSerialize,
  deserialize: _appSettingsBoolDBDeserialize,
  deserializeProp: _appSettingsBoolDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsBoolDBGetId,
  getLinks: _appSettingsBoolDBGetLinks,
  attach: _appSettingsBoolDBAttach,
  version: '3.1.8',
);

int _appSettingsBoolDBEstimateSize(
  AppSettingsBoolDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.settingName.length * 3;
  return bytesCount;
}

void _appSettingsBoolDBSerialize(
  AppSettingsBoolDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hashCode);
  writer.writeString(offsets[1], object.settingName);
  writer.writeBool(offsets[2], object.settingValue);
}

AppSettingsBoolDB _appSettingsBoolDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsBoolDB(
    settingName: reader.readString(offsets[1]),
    settingValue: reader.readBool(offsets[2]),
  );
  return object;
}

P _appSettingsBoolDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsBoolDBGetId(AppSettingsBoolDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _appSettingsBoolDBGetLinks(
    AppSettingsBoolDB object) {
  return [];
}

void _appSettingsBoolDBAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsBoolDB object) {}

extension AppSettingsBoolDBQueryWhereSort
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QWhere> {
  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsBoolDBQueryWhere
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QWhereClause> {
  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsBoolDBQueryFilter
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QFilterCondition> {
  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterFilterCondition>
      settingValueEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingValue',
        value: value,
      ));
    });
  }
}

extension AppSettingsBoolDBQueryObject
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QFilterCondition> {}

extension AppSettingsBoolDBQueryLinks
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QFilterCondition> {}

extension AppSettingsBoolDBQuerySortBy
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QSortBy> {
  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      sortBySettingName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingName', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      sortBySettingNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingName', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      sortBySettingValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      sortBySettingValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue', Sort.desc);
    });
  }
}

extension AppSettingsBoolDBQuerySortThenBy
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QSortThenBy> {
  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      thenBySettingName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingName', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      thenBySettingNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingName', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      thenBySettingValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QAfterSortBy>
      thenBySettingValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingValue', Sort.desc);
    });
  }
}

extension AppSettingsBoolDBQueryWhereDistinct
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QDistinct> {
  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QDistinct>
      distinctBySettingName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QDistinct>
      distinctBySettingValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingValue');
    });
  }
}

extension AppSettingsBoolDBQueryProperty
    on QueryBuilder<AppSettingsBoolDB, AppSettingsBoolDB, QQueryProperty> {
  QueryBuilder<AppSettingsBoolDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<AppSettingsBoolDB, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<AppSettingsBoolDB, String, QQueryOperations>
      settingNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingName');
    });
  }

  QueryBuilder<AppSettingsBoolDB, bool, QQueryOperations>
      settingValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingValue');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChartsCacheDBCollection on Isar {
  IsarCollection<ChartsCacheDB> get chartsCacheDBs => this.collection();
}

const ChartsCacheDBSchema = CollectionSchema(
  name: r'ChartsCacheDB',
  id: 7045537303772603982,
  properties: {
    r'chartItems': PropertySchema(
      id: 0,
      name: r'chartItems',
      type: IsarType.objectList,
      target: r'ChartItemDB',
    ),
    r'chartName': PropertySchema(
      id: 1,
      name: r'chartName',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'permaURL': PropertySchema(
      id: 3,
      name: r'permaURL',
      type: IsarType.string,
    )
  },
  estimateSize: _chartsCacheDBEstimateSize,
  serialize: _chartsCacheDBSerialize,
  deserialize: _chartsCacheDBDeserialize,
  deserializeProp: _chartsCacheDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {r'ChartItemDB': ChartItemDBSchema},
  getId: _chartsCacheDBGetId,
  getLinks: _chartsCacheDBGetLinks,
  attach: _chartsCacheDBAttach,
  version: '3.1.8',
);

int _chartsCacheDBEstimateSize(
  ChartsCacheDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chartItems.length * 3;
  {
    final offsets = allOffsets[ChartItemDB]!;
    for (var i = 0; i < object.chartItems.length; i++) {
      final value = object.chartItems[i];
      bytesCount += ChartItemDBSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.chartName.length * 3;
  {
    final value = object.permaURL;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _chartsCacheDBSerialize(
  ChartsCacheDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<ChartItemDB>(
    offsets[0],
    allOffsets,
    ChartItemDBSchema.serialize,
    object.chartItems,
  );
  writer.writeString(offsets[1], object.chartName);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeString(offsets[3], object.permaURL);
}

ChartsCacheDB _chartsCacheDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChartsCacheDB(
    chartItems: reader.readObjectList<ChartItemDB>(
          offsets[0],
          ChartItemDBSchema.deserialize,
          allOffsets,
          ChartItemDB(),
        ) ??
        [],
    chartName: reader.readString(offsets[1]),
    lastUpdated: reader.readDateTime(offsets[2]),
    permaURL: reader.readStringOrNull(offsets[3]),
  );
  return object;
}

P _chartsCacheDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<ChartItemDB>(
            offset,
            ChartItemDBSchema.deserialize,
            allOffsets,
            ChartItemDB(),
          ) ??
          []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chartsCacheDBGetId(ChartsCacheDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _chartsCacheDBGetLinks(ChartsCacheDB object) {
  return [];
}

void _chartsCacheDBAttach(
    IsarCollection<dynamic> col, Id id, ChartsCacheDB object) {}

extension ChartsCacheDBQueryWhereSort
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QWhere> {
  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChartsCacheDBQueryWhere
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QWhereClause> {
  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChartsCacheDBQueryFilter
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QFilterCondition> {
  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartItemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chartItems',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartItemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chartItems',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartItemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chartItems',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartItemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chartItems',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartItemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chartItems',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartItemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chartItems',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chartName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chartName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chartName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chartName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chartName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chartName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chartName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chartName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chartName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chartName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'permaURL',
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'permaURL',
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permaURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'permaURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'permaURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permaURL',
        value: '',
      ));
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      permaURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'permaURL',
        value: '',
      ));
    });
  }
}

extension ChartsCacheDBQueryObject
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QFilterCondition> {
  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterFilterCondition>
      chartItemsElement(FilterQuery<ChartItemDB> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'chartItems');
    });
  }
}

extension ChartsCacheDBQueryLinks
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QFilterCondition> {}

extension ChartsCacheDBQuerySortBy
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QSortBy> {
  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy> sortByChartName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chartName', Sort.asc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy>
      sortByChartNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chartName', Sort.desc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy> sortByPermaURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.asc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy>
      sortByPermaURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.desc);
    });
  }
}

extension ChartsCacheDBQuerySortThenBy
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QSortThenBy> {
  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy> thenByChartName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chartName', Sort.asc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy>
      thenByChartNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chartName', Sort.desc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy> thenByPermaURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.asc);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QAfterSortBy>
      thenByPermaURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permaURL', Sort.desc);
    });
  }
}

extension ChartsCacheDBQueryWhereDistinct
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QDistinct> {
  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QDistinct> distinctByChartName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chartName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<ChartsCacheDB, ChartsCacheDB, QDistinct> distinctByPermaURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permaURL', caseSensitive: caseSensitive);
    });
  }
}

extension ChartsCacheDBQueryProperty
    on QueryBuilder<ChartsCacheDB, ChartsCacheDB, QQueryProperty> {
  QueryBuilder<ChartsCacheDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ChartsCacheDB, List<ChartItemDB>, QQueryOperations>
      chartItemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chartItems');
    });
  }

  QueryBuilder<ChartsCacheDB, String, QQueryOperations> chartNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chartName');
    });
  }

  QueryBuilder<ChartsCacheDB, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<ChartsCacheDB, String?, QQueryOperations> permaURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permaURL');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecentlyPlayedDBCollection on Isar {
  IsarCollection<RecentlyPlayedDB> get recentlyPlayedDBs => this.collection();
}

const RecentlyPlayedDBSchema = CollectionSchema(
  name: r'RecentlyPlayedDB',
  id: -815534397388884072,
  properties: {
    r'lastPlayed': PropertySchema(
      id: 0,
      name: r'lastPlayed',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _recentlyPlayedDBEstimateSize,
  serialize: _recentlyPlayedDBSerialize,
  deserialize: _recentlyPlayedDBDeserialize,
  deserializeProp: _recentlyPlayedDBDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'mediaItem': LinkSchema(
      id: 5428180275953081554,
      name: r'mediaItem',
      target: r'MediaItemDB',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _recentlyPlayedDBGetId,
  getLinks: _recentlyPlayedDBGetLinks,
  attach: _recentlyPlayedDBAttach,
  version: '3.1.8',
);

int _recentlyPlayedDBEstimateSize(
  RecentlyPlayedDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _recentlyPlayedDBSerialize(
  RecentlyPlayedDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastPlayed);
}

RecentlyPlayedDB _recentlyPlayedDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecentlyPlayedDB(
    id: id,
    lastPlayed: reader.readDateTime(offsets[0]),
  );
  return object;
}

P _recentlyPlayedDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recentlyPlayedDBGetId(RecentlyPlayedDB object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _recentlyPlayedDBGetLinks(RecentlyPlayedDB object) {
  return [object.mediaItem];
}

void _recentlyPlayedDBAttach(
    IsarCollection<dynamic> col, Id id, RecentlyPlayedDB object) {
  object.id = id;
  object.mediaItem
      .attach(col, col.isar.collection<MediaItemDB>(), r'mediaItem', id);
}

extension RecentlyPlayedDBQueryWhereSort
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QWhere> {
  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecentlyPlayedDBQueryWhere
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QWhereClause> {
  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RecentlyPlayedDBQueryFilter
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QFilterCondition> {
  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      lastPlayedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      lastPlayedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      lastPlayedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      lastPlayedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RecentlyPlayedDBQueryObject
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QFilterCondition> {}

extension RecentlyPlayedDBQueryLinks
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QFilterCondition> {
  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      mediaItem(FilterQuery<MediaItemDB> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'mediaItem');
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterFilterCondition>
      mediaItemIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'mediaItem', 0, true, 0, true);
    });
  }
}

extension RecentlyPlayedDBQuerySortBy
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QSortBy> {
  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterSortBy>
      sortByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterSortBy>
      sortByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }
}

extension RecentlyPlayedDBQuerySortThenBy
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QSortThenBy> {
  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterSortBy>
      thenByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QAfterSortBy>
      thenByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }
}

extension RecentlyPlayedDBQueryWhereDistinct
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QDistinct> {
  QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QDistinct>
      distinctByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayed');
    });
  }
}

extension RecentlyPlayedDBQueryProperty
    on QueryBuilder<RecentlyPlayedDB, RecentlyPlayedDB, QQueryProperty> {
  QueryBuilder<RecentlyPlayedDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecentlyPlayedDB, DateTime, QQueryOperations>
      lastPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayed');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetYtLinkCacheDBCollection on Isar {
  IsarCollection<YtLinkCacheDB> get ytLinkCacheDBs => this.collection();
}

const YtLinkCacheDBSchema = CollectionSchema(
  name: r'YtLinkCacheDB',
  id: 7299293342969868585,
  properties: {
    r'expireAt': PropertySchema(
      id: 0,
      name: r'expireAt',
      type: IsarType.long,
    ),
    r'highQURL': PropertySchema(
      id: 1,
      name: r'highQURL',
      type: IsarType.string,
    ),
    r'lowQURL': PropertySchema(
      id: 2,
      name: r'lowQURL',
      type: IsarType.string,
    ),
    r'videoId': PropertySchema(
      id: 3,
      name: r'videoId',
      type: IsarType.string,
    )
  },
  estimateSize: _ytLinkCacheDBEstimateSize,
  serialize: _ytLinkCacheDBSerialize,
  deserialize: _ytLinkCacheDBDeserialize,
  deserializeProp: _ytLinkCacheDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _ytLinkCacheDBGetId,
  getLinks: _ytLinkCacheDBGetLinks,
  attach: _ytLinkCacheDBAttach,
  version: '3.1.8',
);

int _ytLinkCacheDBEstimateSize(
  YtLinkCacheDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.highQURL.length * 3;
  {
    final value = object.lowQURL;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.videoId.length * 3;
  return bytesCount;
}

void _ytLinkCacheDBSerialize(
  YtLinkCacheDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.expireAt);
  writer.writeString(offsets[1], object.highQURL);
  writer.writeString(offsets[2], object.lowQURL);
  writer.writeString(offsets[3], object.videoId);
}

YtLinkCacheDB _ytLinkCacheDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = YtLinkCacheDB(
    expireAt: reader.readLong(offsets[0]),
    highQURL: reader.readString(offsets[1]),
    lowQURL: reader.readStringOrNull(offsets[2]),
    videoId: reader.readString(offsets[3]),
  );
  return object;
}

P _ytLinkCacheDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ytLinkCacheDBGetId(YtLinkCacheDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _ytLinkCacheDBGetLinks(YtLinkCacheDB object) {
  return [];
}

void _ytLinkCacheDBAttach(
    IsarCollection<dynamic> col, Id id, YtLinkCacheDB object) {}

extension YtLinkCacheDBQueryWhereSort
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QWhere> {
  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension YtLinkCacheDBQueryWhere
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QWhereClause> {
  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension YtLinkCacheDBQueryFilter
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QFilterCondition> {
  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      expireAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expireAt',
        value: value,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      expireAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expireAt',
        value: value,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      expireAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expireAt',
        value: value,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      expireAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expireAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'highQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'highQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'highQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'highQURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'highQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'highQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'highQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'highQURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'highQURL',
        value: '',
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      highQURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'highQURL',
        value: '',
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lowQURL',
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lowQURL',
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lowQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lowQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lowQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lowQURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lowQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lowQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lowQURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lowQURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lowQURL',
        value: '',
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      lowQURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lowQURL',
        value: '',
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoId',
        value: '',
      ));
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterFilterCondition>
      videoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoId',
        value: '',
      ));
    });
  }
}

extension YtLinkCacheDBQueryObject
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QFilterCondition> {}

extension YtLinkCacheDBQueryLinks
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QFilterCondition> {}

extension YtLinkCacheDBQuerySortBy
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QSortBy> {
  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> sortByExpireAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireAt', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy>
      sortByExpireAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireAt', Sort.desc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> sortByHighQURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highQURL', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy>
      sortByHighQURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highQURL', Sort.desc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> sortByLowQURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowQURL', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> sortByLowQURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowQURL', Sort.desc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> sortByVideoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoId', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> sortByVideoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoId', Sort.desc);
    });
  }
}

extension YtLinkCacheDBQuerySortThenBy
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QSortThenBy> {
  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> thenByExpireAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireAt', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy>
      thenByExpireAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireAt', Sort.desc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> thenByHighQURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highQURL', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy>
      thenByHighQURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highQURL', Sort.desc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> thenByLowQURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowQURL', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> thenByLowQURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowQURL', Sort.desc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> thenByVideoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoId', Sort.asc);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QAfterSortBy> thenByVideoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoId', Sort.desc);
    });
  }
}

extension YtLinkCacheDBQueryWhereDistinct
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QDistinct> {
  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QDistinct> distinctByExpireAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expireAt');
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QDistinct> distinctByHighQURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highQURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QDistinct> distinctByLowQURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lowQURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QDistinct> distinctByVideoId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoId', caseSensitive: caseSensitive);
    });
  }
}

extension YtLinkCacheDBQueryProperty
    on QueryBuilder<YtLinkCacheDB, YtLinkCacheDB, QQueryProperty> {
  QueryBuilder<YtLinkCacheDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<YtLinkCacheDB, int, QQueryOperations> expireAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expireAt');
    });
  }

  QueryBuilder<YtLinkCacheDB, String, QQueryOperations> highQURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highQURL');
    });
  }

  QueryBuilder<YtLinkCacheDB, String?, QQueryOperations> lowQURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lowQURL');
    });
  }

  QueryBuilder<YtLinkCacheDB, String, QQueryOperations> videoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDownloadDBCollection on Isar {
  IsarCollection<DownloadDB> get downloadDBs => this.collection();
}

const DownloadDBSchema = CollectionSchema(
  name: r'DownloadDB',
  id: -6833781486557602446,
  properties: {
    r'fileName': PropertySchema(
      id: 0,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'filePath': PropertySchema(
      id: 1,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'lastDownloaded': PropertySchema(
      id: 2,
      name: r'lastDownloaded',
      type: IsarType.dateTime,
    ),
    r'mediaId': PropertySchema(
      id: 3,
      name: r'mediaId',
      type: IsarType.string,
    )
  },
  estimateSize: _downloadDBEstimateSize,
  serialize: _downloadDBSerialize,
  deserialize: _downloadDBDeserialize,
  deserializeProp: _downloadDBDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _downloadDBGetId,
  getLinks: _downloadDBGetLinks,
  attach: _downloadDBAttach,
  version: '3.1.8',
);

int _downloadDBEstimateSize(
  DownloadDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.filePath.length * 3;
  bytesCount += 3 + object.mediaId.length * 3;
  return bytesCount;
}

void _downloadDBSerialize(
  DownloadDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fileName);
  writer.writeString(offsets[1], object.filePath);
  writer.writeDateTime(offsets[2], object.lastDownloaded);
  writer.writeString(offsets[3], object.mediaId);
}

DownloadDB _downloadDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DownloadDB(
    fileName: reader.readString(offsets[0]),
    filePath: reader.readString(offsets[1]),
    id: id,
    lastDownloaded: reader.readDateTimeOrNull(offsets[2]),
    mediaId: reader.readString(offsets[3]),
  );
  return object;
}

P _downloadDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _downloadDBGetId(DownloadDB object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _downloadDBGetLinks(DownloadDB object) {
  return [];
}

void _downloadDBAttach(IsarCollection<dynamic> col, Id id, DownloadDB object) {
  object.id = id;
}

extension DownloadDBQueryWhereSort
    on QueryBuilder<DownloadDB, DownloadDB, QWhere> {
  QueryBuilder<DownloadDB, DownloadDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DownloadDBQueryWhere
    on QueryBuilder<DownloadDB, DownloadDB, QWhereClause> {
  QueryBuilder<DownloadDB, DownloadDB, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DownloadDB, DownloadDB, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DownloadDBQueryFilter
    on QueryBuilder<DownloadDB, DownloadDB, QFilterCondition> {
  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> fileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> fileNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> fileNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> filePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      filePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> filePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> filePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> filePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> filePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      lastDownloadedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDownloaded',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      lastDownloadedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDownloaded',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      lastDownloadedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDownloaded',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      lastDownloadedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDownloaded',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      lastDownloadedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDownloaded',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      lastDownloadedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDownloaded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> mediaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      mediaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> mediaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> mediaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> mediaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> mediaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> mediaIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> mediaIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition> mediaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterFilterCondition>
      mediaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaId',
        value: '',
      ));
    });
  }
}

extension DownloadDBQueryObject
    on QueryBuilder<DownloadDB, DownloadDB, QFilterCondition> {}

extension DownloadDBQueryLinks
    on QueryBuilder<DownloadDB, DownloadDB, QFilterCondition> {}

extension DownloadDBQuerySortBy
    on QueryBuilder<DownloadDB, DownloadDB, QSortBy> {
  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> sortByLastDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloaded', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy>
      sortByLastDownloadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloaded', Sort.desc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> sortByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> sortByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }
}

extension DownloadDBQuerySortThenBy
    on QueryBuilder<DownloadDB, DownloadDB, QSortThenBy> {
  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenByLastDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloaded', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy>
      thenByLastDownloadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDownloaded', Sort.desc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QAfterSortBy> thenByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }
}

extension DownloadDBQueryWhereDistinct
    on QueryBuilder<DownloadDB, DownloadDB, QDistinct> {
  QueryBuilder<DownloadDB, DownloadDB, QDistinct> distinctByFileName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QDistinct> distinctByFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QDistinct> distinctByLastDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDownloaded');
    });
  }

  QueryBuilder<DownloadDB, DownloadDB, QDistinct> distinctByMediaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaId', caseSensitive: caseSensitive);
    });
  }
}

extension DownloadDBQueryProperty
    on QueryBuilder<DownloadDB, DownloadDB, QQueryProperty> {
  QueryBuilder<DownloadDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DownloadDB, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<DownloadDB, String, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<DownloadDB, DateTime?, QQueryOperations>
      lastDownloadedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDownloaded');
    });
  }

  QueryBuilder<DownloadDB, String, QQueryOperations> mediaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSavedCollectionsDBCollection on Isar {
  IsarCollection<SavedCollectionsDB> get savedCollectionsDBs =>
      this.collection();
}

const SavedCollectionsDBSchema = CollectionSchema(
  name: r'SavedCollectionsDB',
  id: -2802148582567515827,
  properties: {
    r'coverArt': PropertySchema(
      id: 0,
      name: r'coverArt',
      type: IsarType.string,
    ),
    r'extra': PropertySchema(
      id: 1,
      name: r'extra',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'source': PropertySchema(
      id: 3,
      name: r'source',
      type: IsarType.string,
    ),
    r'sourceId': PropertySchema(
      id: 4,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'sourceURL': PropertySchema(
      id: 5,
      name: r'sourceURL',
      type: IsarType.string,
    ),
    r'subtitle': PropertySchema(
      id: 6,
      name: r'subtitle',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 8,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _savedCollectionsDBEstimateSize,
  serialize: _savedCollectionsDBSerialize,
  deserialize: _savedCollectionsDBDeserialize,
  deserializeProp: _savedCollectionsDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _savedCollectionsDBGetId,
  getLinks: _savedCollectionsDBGetLinks,
  attach: _savedCollectionsDBAttach,
  version: '3.1.8',
);

int _savedCollectionsDBEstimateSize(
  SavedCollectionsDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.coverArt.length * 3;
  {
    final value = object.extra;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.sourceId.length * 3;
  bytesCount += 3 + object.sourceURL.length * 3;
  {
    final value = object.subtitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _savedCollectionsDBSerialize(
  SavedCollectionsDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.coverArt);
  writer.writeString(offsets[1], object.extra);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeString(offsets[3], object.source);
  writer.writeString(offsets[4], object.sourceId);
  writer.writeString(offsets[5], object.sourceURL);
  writer.writeString(offsets[6], object.subtitle);
  writer.writeString(offsets[7], object.title);
  writer.writeString(offsets[8], object.type);
}

SavedCollectionsDB _savedCollectionsDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavedCollectionsDB(
    coverArt: reader.readString(offsets[0]),
    extra: reader.readStringOrNull(offsets[1]),
    lastUpdated: reader.readDateTime(offsets[2]),
    source: reader.readString(offsets[3]),
    sourceId: reader.readString(offsets[4]),
    sourceURL: reader.readString(offsets[5]),
    subtitle: reader.readStringOrNull(offsets[6]),
    title: reader.readString(offsets[7]),
    type: reader.readString(offsets[8]),
  );
  return object;
}

P _savedCollectionsDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _savedCollectionsDBGetId(SavedCollectionsDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _savedCollectionsDBGetLinks(
    SavedCollectionsDB object) {
  return [];
}

void _savedCollectionsDBAttach(
    IsarCollection<dynamic> col, Id id, SavedCollectionsDB object) {}

extension SavedCollectionsDBQueryWhereSort
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QWhere> {
  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SavedCollectionsDBQueryWhere
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QWhereClause> {
  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SavedCollectionsDBQueryFilter
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QFilterCondition> {
  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverArt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverArt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverArt',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      coverArtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverArt',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extra',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extra',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extra',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'extra',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extra',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      extraIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'extra',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceURL',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      sourceURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceURL',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subtitle',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subtitle',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subtitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitle',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      subtitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subtitle',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension SavedCollectionsDBQueryObject
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QFilterCondition> {}

extension SavedCollectionsDBQueryLinks
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QFilterCondition> {}

extension SavedCollectionsDBQuerySortBy
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QSortBy> {
  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByCoverArt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverArt', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByCoverArtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverArt', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByExtra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extra', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByExtraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extra', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortBySourceURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceURL', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortBySourceURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceURL', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SavedCollectionsDBQuerySortThenBy
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QSortThenBy> {
  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByCoverArt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverArt', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByCoverArtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverArt', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByExtra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extra', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByExtraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extra', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenBySourceURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceURL', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenBySourceURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceURL', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SavedCollectionsDBQueryWhereDistinct
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct> {
  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctByCoverArt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverArt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctByExtra({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extra', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctBySource({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctBySourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctBySourceURL({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctBySubtitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension SavedCollectionsDBQueryProperty
    on QueryBuilder<SavedCollectionsDB, SavedCollectionsDB, QQueryProperty> {
  QueryBuilder<SavedCollectionsDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SavedCollectionsDB, String, QQueryOperations>
      coverArtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverArt');
    });
  }

  QueryBuilder<SavedCollectionsDB, String?, QQueryOperations> extraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extra');
    });
  }

  QueryBuilder<SavedCollectionsDB, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<SavedCollectionsDB, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<SavedCollectionsDB, String, QQueryOperations>
      sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<SavedCollectionsDB, String, QQueryOperations>
      sourceURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceURL');
    });
  }

  QueryBuilder<SavedCollectionsDB, String?, QQueryOperations>
      subtitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtitle');
    });
  }

  QueryBuilder<SavedCollectionsDB, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<SavedCollectionsDB, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationDBCollection on Isar {
  IsarCollection<NotificationDB> get notificationDBs => this.collection();
}

const NotificationDBSchema = CollectionSchema(
  name: r'NotificationDB',
  id: 375537289431161249,
  properties: {
    r'body': PropertySchema(
      id: 0,
      name: r'body',
      type: IsarType.string,
    ),
    r'payload': PropertySchema(
      id: 1,
      name: r'payload',
      type: IsarType.string,
    ),
    r'time': PropertySchema(
      id: 2,
      name: r'time',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 3,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 4,
      name: r'type',
      type: IsarType.string,
    ),
    r'url': PropertySchema(
      id: 5,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _notificationDBEstimateSize,
  serialize: _notificationDBSerialize,
  deserialize: _notificationDBDeserialize,
  deserializeProp: _notificationDBDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _notificationDBGetId,
  getLinks: _notificationDBGetLinks,
  attach: _notificationDBAttach,
  version: '3.1.8',
);

int _notificationDBEstimateSize(
  NotificationDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.body.length * 3;
  {
    final value = object.payload;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.length * 3;
  {
    final value = object.url;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _notificationDBSerialize(
  NotificationDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.body);
  writer.writeString(offsets[1], object.payload);
  writer.writeDateTime(offsets[2], object.time);
  writer.writeString(offsets[3], object.title);
  writer.writeString(offsets[4], object.type);
  writer.writeString(offsets[5], object.url);
}

NotificationDB _notificationDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationDB(
    body: reader.readString(offsets[0]),
    id: id,
    payload: reader.readStringOrNull(offsets[1]),
    time: reader.readDateTimeOrNull(offsets[2]),
    title: reader.readString(offsets[3]),
    type: reader.readString(offsets[4]),
    url: reader.readStringOrNull(offsets[5]),
  );
  return object;
}

P _notificationDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notificationDBGetId(NotificationDB object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _notificationDBGetLinks(NotificationDB object) {
  return [];
}

void _notificationDBAttach(
    IsarCollection<dynamic> col, Id id, NotificationDB object) {
  object.id = id;
}

extension NotificationDBQueryWhereSort
    on QueryBuilder<NotificationDB, NotificationDB, QWhere> {
  QueryBuilder<NotificationDB, NotificationDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationDBQueryWhere
    on QueryBuilder<NotificationDB, NotificationDB, QWhereClause> {
  QueryBuilder<NotificationDB, NotificationDB, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<NotificationDB, NotificationDB, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotificationDBQueryFilter
    on QueryBuilder<NotificationDB, NotificationDB, QFilterCondition> {
  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'body',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'body',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'payload',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'payload',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      timeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      timeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      timeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      timeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      timeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      timeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'url',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'url',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension NotificationDBQueryObject
    on QueryBuilder<NotificationDB, NotificationDB, QFilterCondition> {}

extension NotificationDBQueryLinks
    on QueryBuilder<NotificationDB, NotificationDB, QFilterCondition> {}

extension NotificationDBQuerySortBy
    on QueryBuilder<NotificationDB, NotificationDB, QSortBy> {
  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy>
      sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension NotificationDBQuerySortThenBy
    on QueryBuilder<NotificationDB, NotificationDB, QSortThenBy> {
  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy>
      thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension NotificationDBQueryWhereDistinct
    on QueryBuilder<NotificationDB, NotificationDB, QDistinct> {
  QueryBuilder<NotificationDB, NotificationDB, QDistinct> distinctByBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'body', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QDistinct> distinctByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationDB, NotificationDB, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension NotificationDBQueryProperty
    on QueryBuilder<NotificationDB, NotificationDB, QQueryProperty> {
  QueryBuilder<NotificationDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationDB, String, QQueryOperations> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'body');
    });
  }

  QueryBuilder<NotificationDB, String?, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<NotificationDB, DateTime?, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<NotificationDB, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<NotificationDB, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<NotificationDB, String?, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLyricsDBCollection on Isar {
  IsarCollection<LyricsDB> get lyricsDBs => this.collection();
}

const LyricsDBSchema = CollectionSchema(
  name: r'LyricsDB',
  id: 2869562449821425733,
  properties: {
    r'album': PropertySchema(
      id: 0,
      name: r'album',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 1,
      name: r'artist',
      type: IsarType.string,
    ),
    r'duration': PropertySchema(
      id: 2,
      name: r'duration',
      type: IsarType.long,
    ),
    r'mediaID': PropertySchema(
      id: 3,
      name: r'mediaID',
      type: IsarType.string,
    ),
    r'offset': PropertySchema(
      id: 4,
      name: r'offset',
      type: IsarType.long,
    ),
    r'plainLyrics': PropertySchema(
      id: 5,
      name: r'plainLyrics',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 6,
      name: r'source',
      type: IsarType.string,
    ),
    r'sourceId': PropertySchema(
      id: 7,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'syncedLyrics': PropertySchema(
      id: 8,
      name: r'syncedLyrics',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 9,
      name: r'title',
      type: IsarType.string,
    ),
    r'url': PropertySchema(
      id: 10,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _lyricsDBEstimateSize,
  serialize: _lyricsDBSerialize,
  deserialize: _lyricsDBDeserialize,
  deserializeProp: _lyricsDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _lyricsDBGetId,
  getLinks: _lyricsDBGetLinks,
  attach: _lyricsDBAttach,
  version: '3.1.8',
);

int _lyricsDBEstimateSize(
  LyricsDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.album;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.artist.length * 3;
  bytesCount += 3 + object.mediaID.length * 3;
  bytesCount += 3 + object.plainLyrics.length * 3;
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.sourceId.length * 3;
  {
    final value = object.syncedLyrics;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.url;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _lyricsDBSerialize(
  LyricsDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.album);
  writer.writeString(offsets[1], object.artist);
  writer.writeLong(offsets[2], object.duration);
  writer.writeString(offsets[3], object.mediaID);
  writer.writeLong(offsets[4], object.offset);
  writer.writeString(offsets[5], object.plainLyrics);
  writer.writeString(offsets[6], object.source);
  writer.writeString(offsets[7], object.sourceId);
  writer.writeString(offsets[8], object.syncedLyrics);
  writer.writeString(offsets[9], object.title);
  writer.writeString(offsets[10], object.url);
}

LyricsDB _lyricsDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LyricsDB(
    album: reader.readStringOrNull(offsets[0]),
    artist: reader.readString(offsets[1]),
    duration: reader.readLongOrNull(offsets[2]),
    mediaID: reader.readString(offsets[3]),
    offset: reader.readLongOrNull(offsets[4]),
    plainLyrics: reader.readString(offsets[5]),
    source: reader.readString(offsets[6]),
    sourceId: reader.readString(offsets[7]),
    syncedLyrics: reader.readStringOrNull(offsets[8]),
    title: reader.readString(offsets[9]),
    url: reader.readStringOrNull(offsets[10]),
  );
  return object;
}

P _lyricsDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lyricsDBGetId(LyricsDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _lyricsDBGetLinks(LyricsDB object) {
  return [];
}

void _lyricsDBAttach(IsarCollection<dynamic> col, Id id, LyricsDB object) {}

extension LyricsDBQueryWhereSort on QueryBuilder<LyricsDB, LyricsDB, QWhere> {
  QueryBuilder<LyricsDB, LyricsDB, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LyricsDBQueryWhere on QueryBuilder<LyricsDB, LyricsDB, QWhereClause> {
  QueryBuilder<LyricsDB, LyricsDB, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterWhereClause> isarIdLessThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LyricsDBQueryFilter
    on QueryBuilder<LyricsDB, LyricsDB, QFilterCondition> {
  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'album',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'album',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> durationEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaID',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaID',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaID',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> mediaIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaID',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> offsetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'offset',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> offsetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'offset',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> offsetEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offset',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> offsetGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offset',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> offsetLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offset',
        value: value,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> offsetBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> plainLyricsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plainLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition>
      plainLyricsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plainLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> plainLyricsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plainLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> plainLyricsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plainLyrics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> plainLyricsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'plainLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> plainLyricsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'plainLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> plainLyricsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'plainLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> plainLyricsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'plainLyrics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> plainLyricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plainLyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition>
      plainLyricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'plainLyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> syncedLyricsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedLyrics',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition>
      syncedLyricsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedLyrics',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> syncedLyricsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition>
      syncedLyricsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> syncedLyricsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> syncedLyricsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedLyrics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition>
      syncedLyricsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncedLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> syncedLyricsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncedLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> syncedLyricsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncedLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> syncedLyricsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncedLyrics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition>
      syncedLyricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedLyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition>
      syncedLyricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncedLyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'url',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'url',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension LyricsDBQueryObject
    on QueryBuilder<LyricsDB, LyricsDB, QFilterCondition> {}

extension LyricsDBQueryLinks
    on QueryBuilder<LyricsDB, LyricsDB, QFilterCondition> {}

extension LyricsDBQuerySortBy on QueryBuilder<LyricsDB, LyricsDB, QSortBy> {
  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByMediaID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaID', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByMediaIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaID', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offset', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offset', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByPlainLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plainLyrics', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByPlainLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plainLyrics', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortBySyncedLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedLyrics', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortBySyncedLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedLyrics', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension LyricsDBQuerySortThenBy
    on QueryBuilder<LyricsDB, LyricsDB, QSortThenBy> {
  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByMediaID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaID', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByMediaIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaID', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offset', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offset', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByPlainLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plainLyrics', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByPlainLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plainLyrics', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenBySyncedLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedLyrics', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenBySyncedLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedLyrics', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension LyricsDBQueryWhereDistinct
    on QueryBuilder<LyricsDB, LyricsDB, QDistinct> {
  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctByAlbum(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctByMediaID(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctByOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offset');
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctByPlainLyrics(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plainLyrics', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctBySourceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctBySyncedLyrics(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedLyrics', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LyricsDB, LyricsDB, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension LyricsDBQueryProperty
    on QueryBuilder<LyricsDB, LyricsDB, QQueryProperty> {
  QueryBuilder<LyricsDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<LyricsDB, String?, QQueryOperations> albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<LyricsDB, String, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<LyricsDB, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<LyricsDB, String, QQueryOperations> mediaIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaID');
    });
  }

  QueryBuilder<LyricsDB, int?, QQueryOperations> offsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offset');
    });
  }

  QueryBuilder<LyricsDB, String, QQueryOperations> plainLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plainLyrics');
    });
  }

  QueryBuilder<LyricsDB, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<LyricsDB, String, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<LyricsDB, String?, QQueryOperations> syncedLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedLyrics');
    });
  }

  QueryBuilder<LyricsDB, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<LyricsDB, String?, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSearchHistoryDBCollection on Isar {
  IsarCollection<SearchHistoryDB> get searchHistoryDBs => this.collection();
}

const SearchHistoryDBSchema = CollectionSchema(
  name: r'SearchHistoryDB',
  id: 197041396622818937,
  properties: {
    r'lastSearched': PropertySchema(
      id: 0,
      name: r'lastSearched',
      type: IsarType.dateTime,
    ),
    r'query': PropertySchema(
      id: 1,
      name: r'query',
      type: IsarType.string,
    )
  },
  estimateSize: _searchHistoryDBEstimateSize,
  serialize: _searchHistoryDBSerialize,
  deserialize: _searchHistoryDBDeserialize,
  deserializeProp: _searchHistoryDBDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _searchHistoryDBGetId,
  getLinks: _searchHistoryDBGetLinks,
  attach: _searchHistoryDBAttach,
  version: '3.1.8',
);

int _searchHistoryDBEstimateSize(
  SearchHistoryDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.query.length * 3;
  return bytesCount;
}

void _searchHistoryDBSerialize(
  SearchHistoryDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastSearched);
  writer.writeString(offsets[1], object.query);
}

SearchHistoryDB _searchHistoryDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SearchHistoryDB(
    lastSearched: reader.readDateTime(offsets[0]),
    query: reader.readString(offsets[1]),
  );
  return object;
}

P _searchHistoryDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _searchHistoryDBGetId(SearchHistoryDB object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _searchHistoryDBGetLinks(SearchHistoryDB object) {
  return [];
}

void _searchHistoryDBAttach(
    IsarCollection<dynamic> col, Id id, SearchHistoryDB object) {}

extension SearchHistoryDBQueryWhereSort
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QWhere> {
  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SearchHistoryDBQueryWhere
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QWhereClause> {
  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SearchHistoryDBQueryFilter
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QFilterCondition> {
  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      lastSearchedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSearched',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      lastSearchedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSearched',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      lastSearchedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSearched',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      lastSearchedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSearched',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'query',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'query',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'query',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterFilterCondition>
      queryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'query',
        value: '',
      ));
    });
  }
}

extension SearchHistoryDBQueryObject
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QFilterCondition> {}

extension SearchHistoryDBQueryLinks
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QFilterCondition> {}

extension SearchHistoryDBQuerySortBy
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QSortBy> {
  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy>
      sortByLastSearched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSearched', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy>
      sortByLastSearchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSearched', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy> sortByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy>
      sortByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }
}

extension SearchHistoryDBQuerySortThenBy
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QSortThenBy> {
  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy>
      thenByLastSearched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSearched', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy>
      thenByLastSearchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSearched', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy> thenByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QAfterSortBy>
      thenByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }
}

extension SearchHistoryDBQueryWhereDistinct
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QDistinct> {
  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QDistinct>
      distinctByLastSearched() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSearched');
    });
  }

  QueryBuilder<SearchHistoryDB, SearchHistoryDB, QDistinct> distinctByQuery(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'query', caseSensitive: caseSensitive);
    });
  }
}

extension SearchHistoryDBQueryProperty
    on QueryBuilder<SearchHistoryDB, SearchHistoryDB, QQueryProperty> {
  QueryBuilder<SearchHistoryDB, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SearchHistoryDB, DateTime, QQueryOperations>
      lastSearchedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSearched');
    });
  }

  QueryBuilder<SearchHistoryDB, String, QQueryOperations> queryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'query');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ChartItemDBSchema = Schema(
  name: r'ChartItemDB',
  id: 3430415545377878575,
  properties: {
    r'artURL': PropertySchema(
      id: 0,
      name: r'artURL',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 1,
      name: r'artist',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 2,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _chartItemDBEstimateSize,
  serialize: _chartItemDBSerialize,
  deserialize: _chartItemDBDeserialize,
  deserializeProp: _chartItemDBDeserializeProp,
);

int _chartItemDBEstimateSize(
  ChartItemDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.artURL;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artist;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _chartItemDBSerialize(
  ChartItemDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artURL);
  writer.writeString(offsets[1], object.artist);
  writer.writeString(offsets[2], object.title);
}

ChartItemDB _chartItemDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChartItemDB();
  object.artURL = reader.readStringOrNull(offsets[0]);
  object.artist = reader.readStringOrNull(offsets[1]);
  object.title = reader.readStringOrNull(offsets[2]);
  return object;
}

P _chartItemDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ChartItemDBQueryFilter
    on QueryBuilder<ChartItemDB, ChartItemDB, QFilterCondition> {
  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artURLIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artURL',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artURLIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artURL',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artURLEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artURLGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artURLLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artURLBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artURLContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artURLMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artURL',
        value: '',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artURL',
        value: '',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artistEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artistGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artistLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artistBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artistContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> artistMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ChartItemDB, ChartItemDB, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension ChartItemDBQueryObject
    on QueryBuilder<ChartItemDB, ChartItemDB, QFilterCondition> {}
