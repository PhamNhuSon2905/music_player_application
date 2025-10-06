import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_player_application/data/repository/playlist_repository.dart';
import 'package:music_player_application/service/token_storage.dart';
import 'package:music_player_application/utils/toast_helper.dart';

class CreatePlaylistPage extends StatefulWidget {
  const CreatePlaylistPage({super.key});

  @override
  State<CreatePlaylistPage> createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPlaylist() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ToastHelper.show(
        context,
        message: "Vui lòng nhập tên playlist!",
        isSuccess: false,
      );
      return;
    }

    final userId = await TokenStorage.getUserId();
    final repo = PlaylistRepository(context);

    try {
      final playlist = await repo.createPlaylist(
        name,
        _imageFile?.path,
        userId,
      );

      if (mounted) {
        Navigator.pop(context, playlist);
        ToastHelper.show(
          context,
          message: "Tạo playlist \"${playlist.name}\" thành công!",
          isSuccess: true,
        );

      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(
          context,
          message: "Không thể tạo playlist. Vui lòng thử lại!",
          isSuccess: false,
        );
      }
    }
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
          "Tạo playlist",
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
          // Upload ảnh
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "Chọn ảnh bìa playlist",
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

          // Nút tạo
          ElevatedButton(
            onPressed: canSubmit ? _createPlaylist : null,
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
              "TẠO PLAYLIST",
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
