class ValidationHelper {
  ValidationHelper._(); // private constructor

  /// Check if field is blank
  static String? blank(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  /// Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  
}
