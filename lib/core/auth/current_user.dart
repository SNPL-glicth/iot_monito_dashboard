class CurrentUser {
  CurrentUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  final String id;
  final String username;
  final String? email;
  final String role;

  static CurrentUser? value;

  static void clear() {
    value = null;
  }

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: (json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: json['email']?.toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}
