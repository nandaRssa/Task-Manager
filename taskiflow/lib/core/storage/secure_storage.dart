// ─────────────────────────────────────────────────────────────────────────────
// secure_storage.dart
// Wrapper untuk flutter_secure_storage.
// Token disimpan secara encrypted di Android Keystore — lebih aman daripada
// SharedPreferences yang plain-text.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  SecureStorage._();

  static final SecureStorage instance = SecureStorage._();

  // Android options: encrypted dengan AES-256
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Access Token ──────────────────────────────────────────────────────────
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.keyAccessToken, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.keyAccessToken);

  // ── Refresh Token ─────────────────────────────────────────────────────────
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.keyRefreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  // ── User Data (JSON string) ───────────────────────────────────────────────
  Future<void> saveUser(String userJson) =>
      _storage.write(key: AppConstants.keyUser, value: userJson);

  Future<String?> getUser() =>
      _storage.read(key: AppConstants.keyUser);

  // ── Save All at Once (saat login) ─────────────────────────────────────────
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userJson,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveUser(userJson),
    ]);
  }

  // ── Clear All (saat logout) ───────────────────────────────────────────────
  Future<void> clearSession() => _storage.deleteAll();

  // ── Check apakah ada session ──────────────────────────────────────────────
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
