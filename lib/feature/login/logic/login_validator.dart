class LoginValidator {
  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your university email';
    if (!v.contains('@') || !v.contains('bu.edu.eg')) {
      return 'Use your @bu.edu.eg email';
    }
    return null;
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter your password';
    if (v.length < 8) return 'At least 8 characters required';
    return null;
  }
}
