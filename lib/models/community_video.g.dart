// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_video.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCommunityVideoCollection on Isar {
  IsarCollection<CommunityVideo> get communityVideos => this.collection();
}

const CommunityVideoSchema = CollectionSchema(
  name: r'CommunityVideo',
  id: 6865192867601379411,
  properties: {
    r'approves': PropertySchema(id: 0, name: r'approves', type: IsarType.long),
    r'comments': PropertySchema(
      id: 1,
      name: r'comments',
      type: IsarType.objectList,

      target: r'Comment',
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'isApprovedByCurrentUser': PropertySchema(
      id: 3,
      name: r'isApprovedByCurrentUser',
      type: IsarType.bool,
    ),
    r'title': PropertySchema(id: 4, name: r'title', type: IsarType.string),
    r'uploaderId': PropertySchema(
      id: 5,
      name: r'uploaderId',
      type: IsarType.long,
    ),
    r'videoUrl': PropertySchema(
      id: 6,
      name: r'videoUrl',
      type: IsarType.string,
    ),
  },

  estimateSize: _communityVideoEstimateSize,
  serialize: _communityVideoSerialize,
  deserialize: _communityVideoDeserialize,
  deserializeProp: _communityVideoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'Comment': CommentSchema},

  getId: _communityVideoGetId,
  getLinks: _communityVideoGetLinks,
  attach: _communityVideoAttach,
  version: '3.3.0',
);

int _communityVideoEstimateSize(
  CommunityVideo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.comments.length * 3;
  {
    final offsets = allOffsets[Comment]!;
    for (var i = 0; i < object.comments.length; i++) {
      final value = object.comments[i];
      bytesCount += CommentSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.videoUrl.length * 3;
  return bytesCount;
}

void _communityVideoSerialize(
  CommunityVideo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.approves);
  writer.writeObjectList<Comment>(
    offsets[1],
    allOffsets,
    CommentSchema.serialize,
    object.comments,
  );
  writer.writeString(offsets[2], object.description);
  writer.writeBool(offsets[3], object.isApprovedByCurrentUser);
  writer.writeString(offsets[4], object.title);
  writer.writeLong(offsets[5], object.uploaderId);
  writer.writeString(offsets[6], object.videoUrl);
}

CommunityVideo _communityVideoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CommunityVideo();
  object.approves = reader.readLong(offsets[0]);
  object.comments =
      reader.readObjectList<Comment>(
        offsets[1],
        CommentSchema.deserialize,
        allOffsets,
        Comment(),
      ) ??
      [];
  object.description = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.isApprovedByCurrentUser = reader.readBool(offsets[3]);
  object.title = reader.readString(offsets[4]);
  object.uploaderId = reader.readLong(offsets[5]);
  object.videoUrl = reader.readString(offsets[6]);
  return object;
}

P _communityVideoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readObjectList<Comment>(
                offset,
                CommentSchema.deserialize,
                allOffsets,
                Comment(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _communityVideoGetId(CommunityVideo object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _communityVideoGetLinks(CommunityVideo object) {
  return [];
}

void _communityVideoAttach(
  IsarCollection<dynamic> col,
  Id id,
  CommunityVideo object,
) {
  object.id = id;
}

extension CommunityVideoQueryWhereSort
    on QueryBuilder<CommunityVideo, CommunityVideo, QWhere> {
  QueryBuilder<CommunityVideo, CommunityVideo, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CommunityVideoQueryWhere
    on QueryBuilder<CommunityVideo, CommunityVideo, QWhereClause> {
  QueryBuilder<CommunityVideo, CommunityVideo, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterWhereClause> idBetween(
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
}

extension CommunityVideoQueryFilter
    on QueryBuilder<CommunityVideo, CommunityVideo, QFilterCondition> {
  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  approvesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'approves', value: value),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  approvesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'approves',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  approvesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'approves',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  approvesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'approves',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  commentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'comments', length, true, length, true);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  commentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'comments', 0, true, 0, true);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  commentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'comments', 0, false, 999999, true);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  commentsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'comments', 0, true, length, include);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  commentsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'comments', length, include, 999999, true);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  commentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'comments',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'description'),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'description'),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
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

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
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

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  isApprovedByCurrentUserEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isApprovedByCurrentUser',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  uploaderIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uploaderId', value: value),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  uploaderIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uploaderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  uploaderIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uploaderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  uploaderIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uploaderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'videoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'videoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'videoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'videoUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'videoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'videoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'videoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'videoUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'videoUrl', value: ''),
      );
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  videoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'videoUrl', value: ''),
      );
    });
  }
}

extension CommunityVideoQueryObject
    on QueryBuilder<CommunityVideo, CommunityVideo, QFilterCondition> {
  QueryBuilder<CommunityVideo, CommunityVideo, QAfterFilterCondition>
  commentsElement(FilterQuery<Comment> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'comments');
    });
  }
}

extension CommunityVideoQueryLinks
    on QueryBuilder<CommunityVideo, CommunityVideo, QFilterCondition> {}

extension CommunityVideoQuerySortBy
    on QueryBuilder<CommunityVideo, CommunityVideo, QSortBy> {
  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> sortByApproves() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approves', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  sortByApprovesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approves', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  sortByIsApprovedByCurrentUser() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isApprovedByCurrentUser', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  sortByIsApprovedByCurrentUserDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isApprovedByCurrentUser', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  sortByUploaderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderId', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  sortByUploaderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderId', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> sortByVideoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoUrl', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  sortByVideoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoUrl', Sort.desc);
    });
  }
}

extension CommunityVideoQuerySortThenBy
    on QueryBuilder<CommunityVideo, CommunityVideo, QSortThenBy> {
  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> thenByApproves() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approves', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  thenByApprovesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approves', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  thenByIsApprovedByCurrentUser() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isApprovedByCurrentUser', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  thenByIsApprovedByCurrentUserDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isApprovedByCurrentUser', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  thenByUploaderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderId', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  thenByUploaderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaderId', Sort.desc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy> thenByVideoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoUrl', Sort.asc);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QAfterSortBy>
  thenByVideoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoUrl', Sort.desc);
    });
  }
}

extension CommunityVideoQueryWhereDistinct
    on QueryBuilder<CommunityVideo, CommunityVideo, QDistinct> {
  QueryBuilder<CommunityVideo, CommunityVideo, QDistinct> distinctByApproves() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approves');
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QDistinct>
  distinctByIsApprovedByCurrentUser() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isApprovedByCurrentUser');
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QDistinct>
  distinctByUploaderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploaderId');
    });
  }

  QueryBuilder<CommunityVideo, CommunityVideo, QDistinct> distinctByVideoUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoUrl', caseSensitive: caseSensitive);
    });
  }
}

extension CommunityVideoQueryProperty
    on QueryBuilder<CommunityVideo, CommunityVideo, QQueryProperty> {
  QueryBuilder<CommunityVideo, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CommunityVideo, int, QQueryOperations> approvesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approves');
    });
  }

  QueryBuilder<CommunityVideo, List<Comment>, QQueryOperations>
  commentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'comments');
    });
  }

  QueryBuilder<CommunityVideo, String?, QQueryOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<CommunityVideo, bool, QQueryOperations>
  isApprovedByCurrentUserProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isApprovedByCurrentUser');
    });
  }

  QueryBuilder<CommunityVideo, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<CommunityVideo, int, QQueryOperations> uploaderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploaderId');
    });
  }

  QueryBuilder<CommunityVideo, String, QQueryOperations> videoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoUrl');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CommentSchema = Schema(
  name: r'Comment',
  id: -5579229333153709021,
  properties: {
    r'text': PropertySchema(id: 0, name: r'text', type: IsarType.string),
    r'userId': PropertySchema(id: 1, name: r'userId', type: IsarType.long),
  },

  estimateSize: _commentEstimateSize,
  serialize: _commentSerialize,
  deserialize: _commentDeserialize,
  deserializeProp: _commentDeserializeProp,
);

int _commentEstimateSize(
  Comment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _commentSerialize(
  Comment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.text);
  writer.writeLong(offsets[1], object.userId);
}

Comment _commentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Comment();
  object.text = reader.readString(offsets[0]);
  object.userId = reader.readLong(offsets[1]);
  return object;
}

P _commentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CommentQueryFilter
    on QueryBuilder<Comment, Comment, QFilterCondition> {
  QueryBuilder<Comment, Comment, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'text',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'text',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> userIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: value),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> userIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> userIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Comment, Comment, QAfterFilterCondition> userIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CommentQueryObject
    on QueryBuilder<Comment, Comment, QFilterCondition> {}
