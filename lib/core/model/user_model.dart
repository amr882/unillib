class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final String faculty;
  final String academicYear;
  final String createdAt;
  final String role;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.faculty,
    required this.academicYear,
    required this.createdAt,
    this.role = 'student',
  });

  bool get isAdmin => role == 'admin';

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      firstName: map['firstName'] as String? ?? '??',
      lastName: map['lastName'] as String? ?? '??',
      email: map['email'] as String? ?? '??',
      studentId: map['studentId'] as String? ?? '??',
      faculty: map['faculty'] as String? ?? '??',
      academicYear: map['academicYear'] as String? ?? '??',
      createdAt: map['createdAt']?.toString() ?? '??',
      role: map['role'] as String? ?? 'student',
    );
  }

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'studentId': studentId,
    'faculty': faculty,
    'academicYear': academicYear,
    'createdAt': createdAt,
    'role': role,
  };

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? studentId,
    String? faculty,
    String? academicYear,
    String? createdAt,
    String? role,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      faculty: faculty ?? this.faculty,
      academicYear: academicYear ?? this.academicYear,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $fullName, email: $email, faculty: $faculty)';
}
