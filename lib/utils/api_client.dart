import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../service/token_storage.dart';
import '../service/auth_service.dart';
import 'package:music_player_application/utils/constants.dart';

class ApiClient {
  final String baseUrl = AppConstants.baseUrl;
  final BuildContext context;

  ApiClient(this.context);

  Future<Map<String, String>> _getHeaders({
    Map<String, String>? extraHeaders,
  }) async {
    final token = await TokenStorage.getToken();
    print('[ApiClient] Token: $token');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?extraHeaders,
    };
  }

  Future<http.Response> get(String path, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params);
    final headers = await _getHeaders();

    print('[GET] $uri');
    print('[GET] Headers: $headers');

    final response = await http.get(uri, headers: headers);

    print('[GET] Status: ${response.statusCode}');
    print('[GET] Body: ${response.body}');

    await _handleUnauthorized(response);
    return response;
  }

  Future<http.Response> post(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = await _getHeaders(extraHeaders: headers);

    print('[POST] $uri');
    print('[POST] Headers: $allHeaders');
    print('[POST] Body: ${jsonEncode(body)}');

    final response = await http.post(
      uri,
      headers: allHeaders,
      body: jsonEncode(body),
    );

    print('[POST] Status: ${response.statusCode}');
    print('[POST] Body: ${response.body}');

    await _handleUnauthorized(response);
    return response;
  }

  Future<http.Response> put(
      String path, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = await _getHeaders(extraHeaders: headers);

    print('[PUT] $uri');
    print('[PUT] Headers: $allHeaders');
    print('[PUT] Body: ${jsonEncode(body)}');

    final response = await http.put(
      uri,
      headers: allHeaders,
      body: jsonEncode(body),
    );

    print('[PUT] Status: ${response.statusCode}');
    print('[PUT] Body: ${response.body}');

    await _handleUnauthorized(response);
    return response;
  }

  /// DELETE request
  Future<http.Response> delete(
      String path, {
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = await _getHeaders(extraHeaders: headers);

    print('[DELETE] $uri');
    print('[DELETE] Headers: $allHeaders');

    final response = await http.delete(uri, headers: allHeaders);

    print('[DELETE] Status: ${response.statusCode}');
    print('[DELETE] Body: ${response.body}');

    await _handleUnauthorized(response);
    return response;
  }

  // Upload file (POST hoặc PUT)
  Future<http.Response> uploadFile(
      String path, {
        File? file,
        Map<String, String>? fields,
        String fileField = "file",
        String method = "POST",
      }) async {
    final uri = Uri.parse('$baseUrl$path');
    final token = await TokenStorage.getToken();

    print('[UPLOAD $method] $uri');
    if (file != null) print('[UPLOAD $method] File: ${file.path}');
    print('[UPLOAD $method] Token: $token');
    print('[UPLOAD $method] Fields: $fields');

    final request = http.MultipartRequest(method, uri)
      ..headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('[UPLOAD $method] Status: ${response.statusCode}');
    print('[UPLOAD $method] Body: ${response.body}');

    await _handleUnauthorized(response);
    return response;
  }


  Future<void> _handleUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      final body = response.body;
      if (body.contains('JWT expired') ||
          body.contains('Invalid JWT') ||
          body.contains('Full authentication is required')) {
        print('[ApiClient] Token expired or invalid – Logging out...');
        await AuthService.logout(context);
      } else {
        print('[ApiClient] 401 but not JWT-related, no logout');
      }
    }
  }
}
