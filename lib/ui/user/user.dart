import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_player_application/data/model/user.dart';
import 'package:music_player_application/service/user_service.dart';
import 'package:music_player_application/utils/toast_helper.dart';
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
    if (user != null && mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imageFile = File(picked.path);
      final userService = UserService(context);
      final success = await userService.uploadAvatar(imageFile);
      if (success) {
        setState(() => _avatar = imageFile);
        _loadUser();
        ToastHelper.show(context,
            message: "Ảnh đại diện đã cập nhật thành công!", isSuccess: true);
      } else {
        ToastHelper.show(context,
            message: "Lỗi khi tải ảnh đại diện!", isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              const Padding(
                padding: EdgeInsets.only(left: 6, top: 6, bottom: 12),
                child: Text(
                  "Cá nhân",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro',
                    color: Colors.black,
                  ),
                ),
              ),

              // 🔹 Avatar + Tên
              _buildProfileHeader(),
              const SizedBox(height: 16),

              // 🔹 Khung thông tin
              _buildUserInfo(),
              const SizedBox(height: 16),

              // 🔹 Nút cập nhật + đăng xuất
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade200, Colors.purple.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: _avatar != null
                      ? FileImage(_avatar!)
                      : NetworkImage(_currentUser!.fullAvatarUrl)
                  as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currentUser!.fullname,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile("Tên đăng nhập", _currentUser!.username,
              Icons.person_outline_rounded),
          Divider(color: Colors.grey.shade300, thickness: 1, height: 14),
          _buildInfoTile("Họ tên", _currentUser!.fullname, Icons.badge_outlined),
          Divider(color: Colors.grey.shade300, thickness: 1, height: 14),
          _buildInfoTile("Email", _currentUser!.email, Icons.email_outlined),
          Divider(color: Colors.grey.shade300, thickness: 1, height: 14),
          _buildInfoTile(
              "Số điện thoại", _currentUser!.phone, Icons.phone_outlined),
          Divider(color: Colors.grey.shade300, thickness: 1, height: 14),
          _buildInfoTile(
              "Địa chỉ", _currentUser!.address, Icons.location_on_outlined),
          Divider(color: Colors.grey.shade300, thickness: 1, height: 14),
          _buildInfoTile("Giới tính",
              _currentUser!.gender == true ? "Nam" : "Nữ", Icons.transgender_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepPurpleAccent, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: 'SF Pro',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : "(Chưa có)",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF Pro',
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => UpdateProfilePage(user: _currentUser!)),
              );
              if (updated == true) _loadUser();
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              "Cập nhật thông tin cá nhân",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Xác nhận đăng xuất"),
                content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Hủy"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Đăng xuất",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              final userService = UserService(context);
              final success = await userService.logout();
              if (success) {
                ToastHelper.show(context,
                    message: "Đăng xuất tài khoản thành công!",
                    isSuccess: true);
                await Future.delayed(const Duration(milliseconds: 100));
                if (mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } else {
                ToastHelper.show(context,
                    message: "Không thể đăng xuất, vui lòng thử lại!",
                    isSuccess: false);
              }
            }
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Đăng xuất tài khoản',
            style: TextStyle(
              color: Colors.red,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
