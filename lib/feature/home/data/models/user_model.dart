class UserModel {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String faculty;
  final String academicYear;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.faculty,
    required this.academicYear,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: '${map['firstName']} ${map['lastName']}',
      email: map['email'] ?? '',
      studentId: map['studentId'] ?? '',
      faculty: map['faculty'] ?? '',
      academicYear: map['academicYear'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    List<String> nameParts = name.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';

    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'studentId': studentId,
      'faculty': faculty,
      'academicYear': academicYear,
    };
  }
}
