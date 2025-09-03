import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_player_application/data/model/user.dart';
import 'package:music_player_application/service/user_service.dart';
import 'update_profile_page.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  User? _currentUser;
  File? _avatar;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userService = UserService(context);
    final user = await userService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imageFile = File(picked.path);
      final userService = UserService(context);
      final success = await userService.uploadAvatar(imageFile);
      if (success) {
        setState(() {
          _avatar = imageFile;
        });
        _loadUser();
        _showSnackBar("Ảnh đại diện đã cập nhật thành công!", Colors.green.shade600);
      } else {
        _showSnackBar("Lỗi khi tải ảnh đại diện!", Colors.redAccent.shade200);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin tài khoản của bạn"),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: _currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 12),
              _buildUserInfo(),
              const SizedBox(height: 12),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: _avatar != null
                    ? FileImage(_avatar!)
                    : NetworkImage(_currentUser!.fullAvatarUrl) as ImageProvider,
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  onPressed: _pickImage,
                  tooltip: "Chọn ảnh đại diện",
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentUser!.fullname,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro',
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoTile("Tên đăng nhập", _currentUser!.username, Icons.person_outline),
            const Divider(height: 1),
            _buildInfoTile("Họ tên", _currentUser!.fullname, Icons.badge_outlined),
            const Divider(height: 1),
            _buildInfoTile("Email", _currentUser!.email, Icons.email_outlined),
            const Divider(height: 1),
            _buildInfoTile("Số điện thoại", _currentUser!.phone, Icons.phone_outlined),
            const Divider(height: 1),
            _buildInfoTile("Địa chỉ", _currentUser!.address, Icons.location_on_outlined),
            const Divider(height: 1),
            _buildInfoTile(
              "Giới tính",
              _currentUser!.gender == true ? "Nam" : "Nữ",
              Icons.transgender_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.purple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro',
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UpdateProfilePage(user: _currentUser!),
              ),
            );
            if (updated == true) _loadUser();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            minimumSize: const Size(200, 56),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.edit, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                "Cập nhật thông tin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        TextButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Xác nhận đăng xuất"),
                content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Đăng xuất")),
                ],
              ),
            );

            if (confirm == true) {
              final userService = UserService(context);
              final success = await userService.logout();
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 6),
                        Expanded(child: Text('Đăng xuất tài khoản thành công!', style: TextStyle(color: Colors.white))),
                      ],
                    ),
                  ),
                );
                await Future.delayed(const Duration(seconds: 1));
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            }
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
