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
  final String? employeeId;
  final String? phoneNumber;
  final String? branch;
  final List<String>? permissions;
  final Map<String, int>? activityStats;
  final bool isVerified;

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
    this.employeeId,
    this.phoneNumber,
    this.branch,
    this.permissions,
    this.activityStats,
    this.isVerified = false,
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
      employeeId: map['employeeId'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      branch: map['branch'] as String?,
      permissions: (map['permissions'] as List?)?.map((e) => e as String).toList(),
      activityStats: (map['activityStats'] as Map?)?.map((k, v) => MapEntry(k as String, v as int)),
      isVerified: map['isVerified'] as bool? ?? false,
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
    'employeeId': employeeId,
    'phoneNumber': phoneNumber,
    'branch': branch,
    'permissions': permissions,
    'activityStats': activityStats,
    'isVerified': isVerified,
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
    String? employeeId,
    String? phoneNumber,
    String? branch,
    List<String>? permissions,
    Map<String, int>? activityStats,
    bool? isVerified,
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
      employeeId: employeeId ?? this.employeeId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      branch: branch ?? this.branch,
      permissions: permissions ?? this.permissions,
      activityStats: activityStats ?? this.activityStats,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $fullName, email: $email, role: $role, isVerified: $isVerified)';
}
