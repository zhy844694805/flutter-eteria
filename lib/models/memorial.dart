import 'package:json_annotation/json_annotation.dart';

part 'memorial.g.dart';

enum MemorialType {
  @JsonValue('person')
  person,
}

@JsonSerializable()
class Memorial {
  final int id;
  final MemorialType type;
  final String name;
  final String? relationship; // 新增：与逝者的关系
  final DateTime birthDate;
  final DateTime deathDate;
  final String description;
  final List<String> imagePaths;
  final List<String> imageUrls;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memorial({
    required this.id,
    required this.type,
    required this.name,
    this.relationship,
    required this.birthDate,
    required this.deathDate,
    required this.description,
    this.imagePaths = const [],
    this.imageUrls = const [],
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Memorial.fromJson(Map<String, dynamic> json) => _$MemorialFromJson(json);
  Map<String, dynamic> toJson() => _$MemorialToJson(this);

  Memorial copyWith({
    int? id,
    MemorialType? type,
    String? name,
    String? relationship,
    DateTime? birthDate,
    DateTime? deathDate,
    String? description,
    List<String>? imagePaths,
    List<String>? imageUrls,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memorial(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      imageUrls: imageUrls ?? this.imageUrls,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeText {
    switch (type) {
      case MemorialType.person:
        return '逝者';
    }
  }

  String get formattedDates {
    final birth = '${birthDate.year}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.day.toString().padLeft(2, '0')}';
    final death = '${deathDate.year}.${deathDate.month.toString().padLeft(2, '0')}.${deathDate.day.toString().padLeft(2, '0')}';
    return '$birth - $death';
  }

  int get ageAtDeath {
    return deathDate.year - birthDate.year;
  }

  // 向后兼容的便利方法
  String? get imagePath => imagePaths.isNotEmpty ? imagePaths.first : null;
  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
  
  // 获取主要图片（优先使用imageUrl，其次imagePath）
  String? get primaryImage {
    if (imageUrls.isNotEmpty) return imageUrls.first;
    if (imagePaths.isNotEmpty) return imagePaths.first;
    return null;
  }
}