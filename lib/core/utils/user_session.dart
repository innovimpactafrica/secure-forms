class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  String name = '';
  String email = '';
  String role = '';

  String get firstName => name.trim().split(' ').first;
  String get lastName {
    final parts = name.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  void clear() {
    name = '';
    email = '';
    role = '';
  }
}
