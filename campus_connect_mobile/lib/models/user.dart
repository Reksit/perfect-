class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? department;
  final String? className;
  final String? phoneNumber;
  final bool verified;
  final String? profileImage;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.className,
    this.phoneNumber,
    this.verified = false,
    this.profileImage,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      department: json['department'],
      className: json['className'],
      phoneNumber: json['phoneNumber'],
      verified: json['verified'] ?? false,
      profileImage: json['profileImage'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'department': department,
      'className': className,
      'phoneNumber': phoneNumber,
      'verified': verified,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isStudent => role == 'STUDENT';
  bool get isProfessor => role == 'PROFESSOR';
  bool get isAlumni => role == 'ALUMNI';
  bool get isManagement => role == 'MANAGEMENT';
}
