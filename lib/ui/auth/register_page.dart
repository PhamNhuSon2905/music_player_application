import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_player_application/utils/api_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _gender = true;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _submitButtonKey = GlobalKey();

  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(context);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullnameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSubmitButton() {
    final context = _submitButtonKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToSubmitButton();
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage("Mật khẩu không trùng khớp. Vui lòng nhập lại.", success: false);
      _scrollToSubmitButton();
      return;
    }

    setState(() => _isLoading = true);

    final body = {
      "username": _usernameController.text.trim(),
      "email": _emailController.text.trim().toLowerCase(),
      "password": _passwordController.text.trim(),
      "fullname": _fullnameController.text.trim(),
      "address": _addressController.text.trim(),
      "phone": _phoneController.text.trim(),
      "gender": _gender,
    };

    try {
      final response = await _apiClient.post('/api/auth/register', body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage("Đăng ký tài khoản thành công!", success: true);
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else if (response.statusCode == 400 && response.body.isNotEmpty) {
        final errors = jsonDecode(response.body);
        if (errors is Map) {
          final combinedError = errors.entries.map((e) => "${e.value}").join("\n");
          _showMessage("$combinedError", success: false);
        } else {
          _showMessage("Đăng ký thất bại: $errors", success: false);
        }
      } else {
        final error = response.body.isNotEmpty ? response.body : "Lỗi không xác định.";
        _showMessage("Đăng ký thất bại: $error", success: false);
      }
    } catch (e) {
      _showMessage("Lỗi mạng: $e", success: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: success ? Colors.green : Colors.red, width: 1),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'SF Pro'),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.purple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                    : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset('assets/logoZ.png', height: 80),
                      const SizedBox(height: 16),
                      const Text(
                        "Tạo tài khoản mới",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'SF Pro'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Khám phá âm nhạc với Zing MP3",
                        style: TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'SF Pro'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.black87, fontFamily: 'SF Pro'),
                        decoration: _inputDecoration("Tên đăng nhập", Icons.person_outline),
                        validator: (v) => v == null || v.trim().isEmpty ? "Tên đăng nhập không được để trống!" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.black87, fontFamily: 'SF Pro'),
                        decoration: _inputDecoration("Email", Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Email không được để trống!";
                          final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,6}$');
                          return emailRegex.hasMatch(value.trim()) ? null : " Không hợp lệ. Vui lòng nhập đúng định dạng email!";
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fullnameController,
                        style: const TextStyle(color: Colors.black87, fontFamily: 'SF Pro'),
                        decoration: _inputDecoration("Họ và tên", Icons.person),
                        validator: (v) => v == null || v.trim().isEmpty ? "Họ và tên không được để trống!" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.black87, fontFamily: 'SF Pro'),
                        decoration: _inputDecoration("Địa chỉ", Icons.location_on),
                        validator: (v) => v == null || v.trim().isEmpty ? "Địa chỉ không được để trống!" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.black87, fontFamily: 'SF Pro'),
                        decoration: _inputDecoration("Số điện thoại", Icons.phone),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Số điện thoại không được để trống!";
                          if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) return "Số điện thoại phải đủ 10 chữ số!";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text("Giới tính:", style: TextStyle(color: Colors.black54, fontFamily: 'SF Pro')),
                          Expanded(
                            child: RadioListTile<bool>(
                              activeColor: Colors.purple[700],
                              title: const Text("Nam", style: TextStyle(fontFamily: 'SF Pro')),
                              value: true,
                              groupValue: _gender,
                              onChanged: (value) => setState(() => _gender = value!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              activeColor: Colors.purple[700],
                              title: const Text("Nữ", style: TextStyle(fontFamily: 'SF Pro')),
                              value: false,
                              groupValue: _gender,
                              onChanged: (value) => setState(() => _gender = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87, fontFamily: 'SF Pro'),
                        decoration: _inputDecoration("Mật khẩu", Icons.lock_outline),
                        validator: (value) =>
                        value != null && value.length >= 6 ? null : "Vui lòng nhập tối thiểu 6 kí tự!",
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87, fontFamily: 'SF Pro'),
                        decoration: _inputDecoration("Xác nhận lại mật khẩu", Icons.lock_outline),
                        validator: (value) =>
                        value == _passwordController.text ? null : "Không khớp mật khẩu. Vui lòng nhập lại!",
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        key: _submitButtonKey,
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Đăng ký",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'SF Pro'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Đã có tài khoản? Đăng nhập tại đây!",
                          style: TextStyle(color: Colors.purple, fontFamily: 'SF Pro'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}