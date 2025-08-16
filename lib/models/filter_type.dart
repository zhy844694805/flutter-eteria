enum FilterType {
  all,
  person,
}

extension FilterTypeExtension on FilterType {
  String get displayName {
    switch (this) {
      case FilterType.all:
        return '全部';
      case FilterType.person:
        return '逝者';
    }
  }
}