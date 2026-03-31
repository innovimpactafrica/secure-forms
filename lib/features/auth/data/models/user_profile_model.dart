class UserProfileModel {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final int profileCompletion;
  final String dateOfBirth;
  final String maritalStatus;
  final String gender;

  const UserProfileModel({
    this.id = '',
    this.name = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.role = '',
    this.profileCompletion = 0,
    this.dateOfBirth = '',
    this.maritalStatus = '',
    this.gender = '',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      profileCompletion: json['profileCompletion'] ?? 0,
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      maritalStatus: json['maritalStatus']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
    );
  }

  String get displayName {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return name;
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    if (first.isNotEmpty || last.isNotEmpty) return '$first$last';
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      final f = parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
      final l = parts.length > 1 ? parts.last[0].toUpperCase() : '';
      return '$f$l';
    }
    return '';
  }
}
