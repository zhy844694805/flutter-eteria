import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserStatus {
  @JsonValue('pending')
  pending, // 等待邮箱验证
  
  @JsonValue('verified')
  verified, // 已验证
  
  @JsonValue('suspended')
  suspended, // 已暂停
}

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? verificationCode;
  final DateTime? verificationCodeExpiry;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.verificationCode,
    this.verificationCodeExpiry,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? verificationCode,
    DateTime? verificationCodeExpiry,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verificationCode: verificationCode ?? this.verificationCode,
      verificationCodeExpiry: verificationCodeExpiry ?? this.verificationCodeExpiry,
    );
  }

  String get statusText {
    switch (status) {
      case UserStatus.pending:
        return '待验证';
      case UserStatus.verified:
        return '已验证';
      case UserStatus.suspended:
        return '已暂停';
    }
  }

  bool get isVerified => status == UserStatus.verified;
  bool get isPending => status == UserStatus.pending;
  bool get isSuspended => status == UserStatus.suspended;
  
  bool get isVerificationCodeValid {
    if (verificationCode == null || verificationCodeExpiry == null) {
      return false;
    }
    return DateTime.now().isBefore(verificationCodeExpiry!);
  }
}