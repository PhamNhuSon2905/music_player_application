import '../../utils/constants.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String avatar;
  final String fullname;
  final String address;
  final String phone;
  final bool gender;
  final String role;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.fullname,
    required this.address,
    required this.phone,
    required this.gender,
    required this.role,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      fullname: json['fullname'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? true,
      role: json['role'] ?? '',
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'fullname': fullname,
      'address': address,
      'phone': phone,
      'gender': gender,
      'role': role,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  String get fullAvatarUrl {
    if (avatar.isEmpty) return 'assets/default_avatar.png';
    final normalized = avatar.startsWith('/') ? avatar.substring(1) : avatar;
    return '${AppConstants.baseUrl}/${Uri.encodeFull(normalized)}';
  }

  String get genderString => gender ? 'Nam' : 'Nữ';

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? avatar,
    String? fullname,
    String? address,
    String? phone,
    bool? gender,
    String? role,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      fullname: fullname ?? this.fullname,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
