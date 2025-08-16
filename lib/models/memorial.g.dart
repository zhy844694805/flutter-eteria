// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memorial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Memorial _$MemorialFromJson(Map<String, dynamic> json) => Memorial(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$MemorialTypeEnumMap, json['type']),
  name: json['name'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  deathDate: DateTime.parse(json['deathDate'] as String),
  description: json['description'] as String,
  imagePaths:
      (json['imagePaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isPublic: json['isPublic'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MemorialToJson(Memorial instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$MemorialTypeEnumMap[instance.type]!,
  'name': instance.name,
  'birthDate': instance.birthDate.toIso8601String(),
  'deathDate': instance.deathDate.toIso8601String(),
  'description': instance.description,
  'imagePaths': instance.imagePaths,
  'imageUrls': instance.imageUrls,
  'isPublic': instance.isPublic,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$MemorialTypeEnumMap = {MemorialType.person: 'person'};
