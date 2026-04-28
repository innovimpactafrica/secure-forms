class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? gender;
  final String? maritalStatus;
  final String? dateOfBirth;
  final String? address;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.gender,
    this.maritalStatus,
    this.dateOfBirth,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      maritalStatus: json['maritalStatus'] ?? json['marital_status'],
      dateOfBirth: json['dateOfBirth'] ?? json['date_of_birth'],
      address: json['address'],
    );
  }

  String get fullName => '$firstName $lastName';
}
