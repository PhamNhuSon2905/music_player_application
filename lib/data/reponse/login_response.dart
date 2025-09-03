class LoginResponse {
  final int userId;
  final String token;
  final String username;
  final String role;
  final String avatar;
  final String fullname;
  final DateTime lastLogin;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.username,
    required this.role,
    required this.avatar,
    required this.fullname,
    required this.lastLogin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      username: json['username'],
      userId: json['userId'],
      role: json['role'],
      avatar: json['avatar'],
      fullname: json['fullname'],
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }
}
