import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/user.dart';
import 'package:music_player_application/service/user_service.dart';
import 'package:music_player_application/utils/toast_helper.dart';

class UpdateProfilePage extends StatefulWidget {
  final User user;

  const UpdateProfilePage({super.key, required this.user});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool? _gender;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.user.fullname ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _gender = widget.user.gender;
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_gender == null) {
        ToastHelper.show(
          context,
          message: "Vui lòng chọn giới tính!",
          isSuccess: false,
        );
        return;
      }

      final updatedUser = User(
        id: widget.user.id,
        username: widget.user.username,
        fullname: _fullnameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gender: _gender!,
        avatar: widget.user.avatar,
        role: widget.user.role,
      );

      final userService = UserService(context);
      final success = await userService.updateProfile(updatedUser);

      if (!mounted) return;

      if (success) {
        ToastHelper.show(
          context,
          message: "Cập nhật thông tin thành công!",
          isSuccess: true,
        );
        Navigator.pop(context, true);
      } else {
        ToastHelper.show(
          context,
          message: "Cập nhật thất bại, vui lòng thử lại sau.",
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cập nhật thông tin của bạn"),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 48),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: theme.cardColor,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _fullnameController,
                        decoration: InputDecoration(
                          labelText: "Họ tên",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            fontFamily: 'SF Pro',
                          ),
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro',
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? "Vui lòng nhập họ tên"
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            fontFamily: 'SF Pro',
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro',
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Vui lòng nhập email";
                          }
                          if (!value.contains("@")) {
                            return "Email không hợp lệ";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: "Số điện thoại",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            fontFamily: 'SF Pro',
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro',
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Vui lòng nhập số điện thoại";
                          }
                          if (value.trim().length != 10) {
                            return "Số điện thoại phải có đúng 10 số";
                          }
                          if (!RegExp(r'^(03|05|07|08|09)[0-9]{8}$').hasMatch(value.trim())) {
                            return "Số điện thoại không hợp lệ";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: "Địa chỉ",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            fontFamily: 'SF Pro',
                          ),
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro',
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? "Vui lòng nhập địa chỉ"
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.transgender_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Giới tính",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey,
                                      fontFamily: 'SF Pro',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Radio<bool>(
                                        value: true,
                                        groupValue: _gender,
                                        onChanged: (value) => setState(() => _gender = value),
                                        activeColor: theme.colorScheme.primary,
                                      ),
                                      const Text("Nam",
                                          style: TextStyle(fontFamily: 'SF Pro')),
                                      const SizedBox(width: 16),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: _gender,
                                        onChanged: (value) => setState(() => _gender = value),
                                        activeColor: theme.colorScheme.primary,
                                      ),
                                      const Text("Nữ",
                                          style: TextStyle(fontFamily: 'SF Pro')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: Icon(Icons.save,
                              color: theme.colorScheme.onPrimary, size: 20),
                          label: Text(
                            "Lưu thay đổi",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.2),
                            minimumSize: const Size(180, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
