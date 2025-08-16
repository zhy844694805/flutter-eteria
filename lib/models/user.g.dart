// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  avatar: json['avatar'] as String?,
  status: $enumDecode(_$UserStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  verificationCode: json['verificationCode'] as String?,
  verificationCodeExpiry: json['verificationCodeExpiry'] == null
      ? null
      : DateTime.parse(json['verificationCodeExpiry'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'avatar': instance.avatar,
  'status': _$UserStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'verificationCode': instance.verificationCode,
  'verificationCodeExpiry': instance.verificationCodeExpiry?.toIso8601String(),
};

const _$UserStatusEnumMap = {
  UserStatus.pending: 'pending',
  UserStatus.verified: 'verified',
  UserStatus.suspended: 'suspended',
};
