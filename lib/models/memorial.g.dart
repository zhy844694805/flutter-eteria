// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memorial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Memorial _$MemorialFromJson(Map<String, dynamic> json) => Memorial(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$MemorialTypeEnumMap, json['memorial_type']),
  name: json['name'] as String,
  relationship: json['relationship'] as String?,
  birthDate: DateTime.parse(json['birth_date'] as String),
  deathDate: DateTime.parse(json['death_date'] as String),
  description: json['description'] as String,
  imagePaths:
      (json['image_paths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  imageUrls:
      (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isPublic: json['is_public'] as bool,
  viewCount: (json['view_count'] as num?)?.toInt(),
  likeCount: (json['like_count'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  user: json['user'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MemorialToJson(Memorial instance) => <String, dynamic>{
  'id': instance.id,
  'memorial_type': _$MemorialTypeEnumMap[instance.type]!,
  'name': instance.name,
  'relationship': instance.relationship,
  'birth_date': instance.birthDate.toIso8601String(),
  'death_date': instance.deathDate.toIso8601String(),
  'description': instance.description,
  'image_paths': instance.imagePaths,
  'image_urls': instance.imageUrls,
  'is_public': instance.isPublic,
  'view_count': instance.viewCount,
  'like_count': instance.likeCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'user': instance.user,
};

const _$MemorialTypeEnumMap = {MemorialType.person: 'person'};
