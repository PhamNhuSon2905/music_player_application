import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/toast_helper.dart';

class DownloadService {
  static final Dio _dio = Dio();

  static Future<void> downloadSong({
    required String url,
    required String fileName,
  }) async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (status.isDenied) {
          ToastHelper.showGlobal(
            message: "Vui lòng cấp quyền truy cập bộ nhớ để tải bài hát!",
            isSuccess: false,
          );
          return;
        }
        if (status.isPermanentlyDenied) {
          ToastHelper.showGlobal(
            message: "Hãy bật quyền truy cập bộ nhớ trong Cài đặt để tải bài hát!",
            isSuccess: false,
          );
          openAppSettings();
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      String? folderPath = prefs.getString("download_music_app");

      if (folderPath == null) {
        final result = await FilePicker.platform.getDirectoryPath();
        if (result == null) return;
        folderPath = result;
        await prefs.setString("download_music_app", folderPath);
      }

      final savePath = "$folderPath/$fileName";

      if (File(savePath).existsSync()) {
        ToastHelper.showGlobal(
          message: "Bài hát đã có trong thiết bị!",
          isSuccess: true,
        );
        return;
      }

      ToastHelper.showGlobal(
        message: "Đang tải xuống bài hát...",
        isSuccess: true,
      );

      await _dio.download(url, savePath, onReceiveProgress: (r, t) {
        if (t != -1) {
        }
      });

      ToastHelper.showGlobal(
        message: "Đã tải xuống bài hát: $fileName!",
        isSuccess: true,
      );
    } catch (e) {
      ToastHelper.showGlobal(
        message: "Tải xuống bài hát thất bại: $e",
        isSuccess: false,
      );
    }
  }
}
