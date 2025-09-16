import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_player_application/data/model/playlist.dart';
import 'package:music_player_application/data/repository/playlist_repository.dart';
import 'package:music_player_application/service/token_storage.dart';

class UpdatePlaylistPage extends StatefulWidget {
  final Playlist playlist;

  const UpdatePlaylistPage({super.key, required this.playlist});

  @override
  State<UpdatePlaylistPage> createState() => _UpdatePlaylistPageState();
}

class _UpdatePlaylistPageState extends State<UpdatePlaylistPage> {
  late TextEditingController _nameController;
  File? _newImageFile; // Ảnh mới chọn
  String? _oldImageUrl; // Ảnh cũ từ server (có thể null)

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist.name);
    _oldImageUrl = widget.playlist.fullImageUrl; // có thể null
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updatePlaylist() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar(message: "Vui lòng nhập tên playlist!", isSuccess: false);
      return;
    }

    final userId = await TokenStorage.getUserId();
    final repo = PlaylistRepository(context);

    try {
      final updatedPlaylist = await repo.updatePlaylist(
        widget.playlist.id,
        name,
        _newImageFile?.path,
        userId,
      );

      if (mounted) {
        Navigator.pop(context, updatedPlaylist);
        _showSnackBar(
          message: "Cập nhật playlist \"${updatedPlaylist.name}\" thành công!",
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          message: "Không thể cập nhật playlist. Vui lòng thử lại!",
          isSuccess: false,
        );
      }
    }
  }

  void _showSnackBar({required String message, bool isSuccess = true}) {
    final color = isSuccess ? Colors.green : Colors.red;
    final icon = isSuccess ? Icons.check_circle : Icons.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: "SF Pro",
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chỉnh sửa playlist",
          style: TextStyle(
            fontFamily: 'SF Pro',
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ảnh hiện tại hoặc default
          if (_newImageFile == null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (_oldImageUrl != null && _oldImageUrl!.startsWith("http"))
                  ? Image.network(
                _oldImageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/default_playlist.jpg',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Ảnh bìa hiện tại",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "SF Pro",
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Upload ảnh mới
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _newImageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _newImageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_photo_alternate,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "Chọn ảnh bìa mới (không bắt buộc)",
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tên playlist
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Tên playlist",
              labelStyle: TextStyle(fontFamily: 'SF Pro', color: Colors.grey),
              border: UnderlineInputBorder(),
            ),
            style: const TextStyle(fontFamily: 'SF Pro', fontSize: 15),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 30),

          // Button lưu
          ElevatedButton(
            onPressed: canSubmit ? _updatePlaylist : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? Colors.purple : Colors.grey[300],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "LƯU THAY ĐỔI",
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
