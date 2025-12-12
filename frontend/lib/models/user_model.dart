class User {
  final String id;
  final String username;
  final String role;
  final String branch;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.branch,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'],
      username: json['username'],
      role: json['role'],
      branch: json['branch'],
    );
  }
}
