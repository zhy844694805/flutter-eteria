class FormValidators {
  // 邮箱验证
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入邮箱地址';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '请输入有效的邮箱地址';
    }
    
    return null;
  }

  // 密码验证
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return '请输入密码';
    }
    
    if (value.length < minLength) {
      return '密码长度不能少于$minLength位';
    }
    
    return null;
  }

  // 确认密码验证
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.trim().isEmpty) {
      return '请再次输入密码';
    }
    
    if (value != originalPassword) {
      return '两次输入的密码不一致';
    }
    
    return null;
  }

  // 姓名验证
  static String? validateName(String? value, {String fieldName = '姓名'}) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$fieldName';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName长度不能少于2个字符';
    }
    
    if (value.trim().length > 20) {
      return '$fieldName长度不能超过20个字符';
    }
    
    return null;
  }

  // 手机号验证
  static String? validatePhone(String value) {
    if (value.trim().isEmpty) {
      return null; // 手机号是可选的
    }
    
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return '请输入有效的手机号';
    }
    
    return null;
  }

  // 描述文字验证
  static String? validateDescription(String? value, {String fieldName = '描述', int maxLength = 500}) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$fieldName';
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName长度不能超过$maxLength个字符';
    }
    
    return null;
  }

  // 验证码验证
  static String? validateVerificationCode(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return '请输入验证码';
    }
    
    if (value.trim().length != length) {
      return '验证码必须为$length位数字';
    }
    
    final codeRegex = RegExp(r'^\d+$');
    if (!codeRegex.hasMatch(value.trim())) {
      return '验证码只能包含数字';
    }
    
    return null;
  }

  // 日期验证
  static String? validateDateRange(DateTime? startDate, DateTime? endDate, {
    String startFieldName = '开始日期',
    String endFieldName = '结束日期',
  }) {
    if (startDate == null) {
      return '请选择$startFieldName';
    }
    
    if (endDate == null) {
      return '请选择$endFieldName';
    }
    
    if (startDate.isAfter(endDate)) {
      return '$startFieldName不能晚于$endFieldName';
    }
    
    return null;
  }

  // 出生日期验证
  static String? validateBirthDate(DateTime? value) {
    if (value == null) {
      return '请选择出生日期';
    }
    
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return '出生日期不能晚于今天';
    }
    
    // 检查是否超过150岁
    final age = now.year - value.year;
    if (age > 150) {
      return '请输入有效的出生日期';
    }
    
    return null;
  }

  // 离世日期验证
  static String? validateDeathDate(DateTime? value, DateTime? birthDate) {
    if (value == null) {
      return '请选择离世日期';
    }
    
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return '离世日期不能晚于今天';
    }
    
    if (birthDate != null && value.isBefore(birthDate)) {
      return '离世日期不能早于出生日期';
    }
    
    return null;
  }
}