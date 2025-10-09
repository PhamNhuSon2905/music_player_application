import 'package:flutter/material.dart';
import 'about_app_page.dart';
import 'privacy_policy_page.dart'; // ✅ import file vừa tạo

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontFamily: "SF Pro",
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.deepPurple),
            title: const Text('Giới thiệu ứng dụng'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppPage()),
              );
            },
          ),
          ListTile(
            leading:
            const Icon(Icons.privacy_tip_outlined, color: Colors.deepPurple),
            title: const Text('Chính sách bảo mật'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
