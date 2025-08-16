enum FilterType {
  all,
  father,
  mother,
  spouse,
  child,
  sibling,
  friend,
  other,
}

extension FilterTypeExtension on FilterType {
  String get displayName {
    switch (this) {
      case FilterType.all:
        return '全部';
      case FilterType.father:
        return '父亲';
      case FilterType.mother:
        return '母亲';
      case FilterType.spouse:
        return '配偶';
      case FilterType.child:
        return '子女';
      case FilterType.sibling:
        return '兄弟姐妹';
      case FilterType.friend:
        return '朋友';
      case FilterType.other:
        return '其他';
    }
  }
  
  // 根据关系字符串获取对应的筛选类型
  static FilterType fromRelationship(String? relationship) {
    if (relationship == null) return FilterType.other;
    
    switch (relationship) {
      case '父亲':
      case '祖父':
      case '外祖父':
        return FilterType.father;
      case '母亲':
      case '祖母':
      case '外祖母':
        return FilterType.mother;
      case '丈夫':
      case '妻子':
        return FilterType.spouse;
      case '儿子':
      case '女儿':
        return FilterType.child;
      case '兄弟':
      case '姐妹':
        return FilterType.sibling;
      case '朋友':
      case '同事':
      case '老师':
      case '同学':
        return FilterType.friend;
      case '其他亲属':
      case '其他':
        return FilterType.other;
      default:
        return FilterType.other;
    }
  }
}