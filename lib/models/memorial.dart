import 'package:json_annotation/json_annotation.dart';

part 'memorial.g.dart';

enum MemorialType {
  @JsonValue('person')
  person,
}

@JsonSerializable()
class Memorial {
  final int id;
  @JsonKey(name: 'memorial_type')
  final MemorialType type;
  final String name;
  final String? relationship; // 新增：与逝者的关系
  @JsonKey(name: 'birth_date')
  final DateTime birthDate;
  @JsonKey(name: 'death_date')
  final DateTime deathDate;
  final String description;
  @JsonKey(name: 'image_paths')
  final List<String> imagePaths;
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'view_count')
  final int? viewCount;
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final Map<String, dynamic>? user;

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
    this.viewCount,
    this.likeCount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Memorial.fromJson(Map<String, dynamic> json) {
    // 处理后端返回的 files 字段
    List<String> imageUrls = [];
    if (json['files'] != null && json['files'] is List) {
      imageUrls = (json['files'] as List)
          .where((file) => file['file_type'] == 'image')
          .map((file) => file['file_url'] as String)
          .toList();
    }
    
    // 如果有直接的 image_urls 字段，也要处理
    if (json['image_urls'] != null && json['image_urls'] is List) {
      imageUrls.addAll((json['image_urls'] as List).cast<String>());
    }
    
    // 创建一个新的 json 对象，包含处理后的 image_urls
    final processedJson = Map<String, dynamic>.from(json);
    processedJson['image_urls'] = imageUrls;
    
    return _$MemorialFromJson(processedJson);
  }
  Map<String, dynamic> toJson() => _$MemorialToJson(this);
  
  Map<String, dynamic> toCreateJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

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
    int? viewCount,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? user,
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
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
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

  // 获取创建者用户ID
  int? get userId {
    return user?['id'];
  }

  // 检查是否为当前用户创建的纪念
  bool isOwnedBy(int? currentUserId) {
    if (currentUserId == null || userId == null) return false;
    return userId == currentUserId;
  }
}