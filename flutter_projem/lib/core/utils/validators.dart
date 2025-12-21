class Validators {
  static String? required(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName zorunlu';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email zorunlu';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir email girin';
    }
    return null;
  }

  static String? minLength(String? value, int length,
      {String fieldName = 'Bu alan'}) {
    if (value == null || value.length < length) {
      return '$fieldName en az $length karakter olmalı';
    }
    return null;
  }
}