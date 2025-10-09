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
        ToastHelper.show(context,
            message: "Vui lòng chọn giới tính!", isSuccess: false);
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
        ToastHelper.show(context,
            message: "Cập nhật thông tin thành công!", isSuccess: true);
        Navigator.pop(context, true);
      } else {
        ToastHelper.show(context,
            message: "Cập nhật thất bại, vui lòng thử lại sau.",
            isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Cập nhật thông tin cá nhân",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Pro',
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: double.infinity,
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
                    padding: const EdgeInsets.all(8),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildTextField(
                          controller: _fullnameController,
                          label: "Họ và tên",
                          icon: Icons.badge_outlined,
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? "Vui lòng nhập họ tên" : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return "Vui lòng nhập email";
                            if (!v.contains("@")) return "Email không hợp lệ";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _phoneController,
                          label: "Số điện thoại",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return "Vui lòng nhập số điện thoại";
                            if (v.length != 10) return "Số điện thoại phải có 10 số";
                            if (!RegExp(r'^(03|05|07|08|09)[0-9]{8}$').hasMatch(v.trim())) {
                              return "Số điện thoại không hợp lệ";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _addressController,
                          label: "Địa chỉ",
                          icon: Icons.location_on_outlined,
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? "Vui lòng nhập địa chỉ" : null,
                        ),
                        const SizedBox(height: 12),
                        _buildGenderField(theme),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: const Text(
                    "Lưu lại thông tin",
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
                    shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        fontFamily: 'SF Pro',
        color: Colors.black,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontFamily: 'SF Pro',
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  Widget _buildGenderField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.transgender_outlined,
              color: Colors.deepPurpleAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Giới tính",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                      activeColor: Colors.deepPurpleAccent,
                    ),
                    const Text("Nam", style: TextStyle(fontFamily: 'SF Pro')),
                    const SizedBox(width: 16),
                    Radio<bool>(
                      value: false,
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                      activeColor: Colors.deepPurpleAccent,
                    ),
                    const Text("Nữ", style: TextStyle(fontFamily: 'SF Pro')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
