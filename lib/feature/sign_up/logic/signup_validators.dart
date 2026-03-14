class SignupValidators {
  static String? validateFirstName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Enter your first name' : null;

  static String? validateLastName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Enter your last name' : null;

  static String? validateStudentId(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your student ID';
    if (!RegExp(r'^[0-9]+$').hasMatch(v.trim())) return 'Must be 16 numbers';
    return null;
  }

  static String? validateFaculty(String? v) => (v == null || v.trim().isEmpty)
      ? 'Enter your faculty / department'
      : null;

  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your university email';
    if (!v.contains('@') || !v.contains('bu.edu.eg')) {
      return 'Use your @bu.edu.eg email';
    }
    return null;
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < 8) return 'At least 8 characters required';
    return null;
  }

  static String? validateConfirmPassword(String? v, String password) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != password) return 'Passwords do not match';
    return null;
  }
}
