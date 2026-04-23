// ─────────────────────────────────────────────────────────────────────────────
// api_client.dart
// HTTP client utama aplikasi. Bertanggung jawab untuk:
//   1. Auto-attach Authorization header di setiap request
//   2. Auto-refresh access token jika mendapat 401
//   3. Auto-logout jika refresh token juga gagal
//
// Pattern: Singleton dengan callback onSessionExpired agar tidak tightly
// coupled ke Navigator (tidak import BuildContext di sini).
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  /// Dipanggil oleh AuthProvider saat inisialisasi.
  /// Digunakan untuk trigger logout dan navigasi ke login screen
  /// ketika refresh token expired.
  void Function()? onSessionExpired;

  final _storage = SecureStorage.instance;

  // ── Public methods ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(String path) async {
    return _sendWithRetry(() => _buildRequest('GET', path));
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    return _sendWithRetry(() => _buildRequest('POST', path, body: body));
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    return _sendWithRetry(() => _buildRequest('PUT', path, body: body));
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _sendWithRetry(() => _buildRequest('DELETE', path));
  }

  /// Request tanpa auth (untuk login & register)
  Future<Map<String, dynamic>> postPublic(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final response = await http
          .post(uri, headers: _jsonHeaders(), body: jsonEncode(body))
          .timeout(ApiConstants.connectTimeout);
      return _parseResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Koneksi timeout. Pastikan backend berjalan.');
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Build http.Request dengan token dari storage
  Future<http.Request> _buildRequest(String method, String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final token = await _storage.getAccessToken();
    final request = http.Request(method, uri);
    request.headers.addAll(_jsonHeaders(token: token));
    if (body != null) request.body = jsonEncode(body);
    return request;
  }

  /// Send request + retry once jika 401 (token expired → refresh dulu)
  Future<Map<String, dynamic>> _sendWithRetry(
    Future<http.Request> Function() buildReq,
  ) async {
    try {
      final req  = await buildReq();
      final resp = await http.Client().send(req).then(http.Response.fromStream);

      if (resp.statusCode == 401) {
        // Coba refresh token
        final refreshed = await _tryRefresh();
        if (!refreshed) {
          // Refresh gagal → session expired → logout
          onSessionExpired?.call();
          throw const AuthException('Sesi habis. Silakan login kembali.', statusCode: 401);
        }
        // Retry request dengan token baru
        final retryReq  = await buildReq();
        final retryResp = await http.Client().send(retryReq).then(http.Response.fromStream);
        return _parseResponse(retryResp);
      }

      return _parseResponse(resp);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Koneksi timeout.');
    }
  }

  /// Coba refresh access token menggunakan refresh token yang tersimpan.
  /// Return true jika berhasil, false jika gagal.
  Future<bool> _tryRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final uri  = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refresh}');
      final resp = await http.post(
        uri,
        headers: _jsonHeaders(),
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(ApiConstants.connectTimeout);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final newToken = body['data']['accessToken'] as String;
        await _storage.saveAccessToken(newToken);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> _jsonHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept'      : 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Parse response HTTP → Map. Throw exception jika error.
  Map<String, dynamic> _parseResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] as String? ?? 'Terjadi kesalahan';

    if (response.statusCode == 401) {
      throw AuthException(message, statusCode: 401);
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}
