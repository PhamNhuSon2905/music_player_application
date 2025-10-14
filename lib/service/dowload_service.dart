import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/toast_helper.dart';

class DownloadService {
  static final Dio _dio = Dio();

  // tải bài hát offline
  static Future<void> downloadSong({
    required String url,
    required String fileName,

  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/App_Music');

      if (!folder.existsSync()) {
        folder.createSync(recursive: true);
      }

      final safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final savePath = '${folder.path}/$safeName';

      if (File(savePath).existsSync()) {
        ToastHelper.showGlobal(
          message: "Bài hát đã tồn tại trong hệ thống!",
          isSuccess: true,
        );
        return;
      }

      ToastHelper.showGlobal(message: "Đang tải xuống bài hát...", isSuccess: true);

      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data);
      await File(savePath).writeAsBytes(bytes);

      ToastHelper.showGlobal(
        message: "Đã tải xuống bài hát: $fileName",
        isSuccess: true,
      );
    } catch (e, st) {
      print("Lỗi khi tải bài hát: $e");
      print(st);
      ToastHelper.showGlobal(
        message: "Tải xuống thất bại: $e",
        isSuccess: false,
      );
    }
  }

  // lấy các bài hát đã tải xuống
  static Future<List<FileSystemEntity>> getDownloadedSongs() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/App_Music');
    if (!folder.existsSync()) return [];
    return folder
        .listSync()
        .where((f) => f.path.toLowerCase().endsWith('.mp3'))
        .toList();
  }

  // lấy đường dẫn thư mục đã tải xuống
  static Future<String> getDownloadFolderPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/App_Music';
  }
}
