// ─────────────────────────────────────────────────────────────────────────────
// auth_service.dart
// Service layer untuk semua operasi autentikasi ke backend.
// Layer ini hanya bertanggung jawab call API + parse response.
// Tidak ada state management di sini.
// ─────────────────────────────────────────────────────────────────────────────

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _client  = ApiClient.instance;
  final _storage = SecureStorage.instance;

  // ── Register ──────────────────────────────────────────────────────────────
  /// Daftar akun baru. Jika berhasil, langsung login dan simpan session.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.postPublic(
      ApiConstants.register,
      body: {'name': name, 'email': email, 'password': password},
    );

    // Setelah register, langsung login
    return login(email: email, password: password);
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  /// Login dan simpan semua token ke secure storage.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.postPublic(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    final data         = response['data'] as Map<String, dynamic>;
    final user         = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final accessToken  = data['accessToken']  as String;
    final refreshToken = data['refreshToken'] as String;

    await _storage.saveSession(
      accessToken  : accessToken,
      refreshToken : refreshToken,
      userJson     : user.toJsonString(),
    );

    return user;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  /// Beritahu backend bahwa refresh token tidak valid lagi, lalu clear storage.
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        // Best effort — tidak throw jika gagal (misal: offline)
        await _client.postPublic(
          ApiConstants.logout,
          body: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Tetap clear local storage meskipun API call gagal
    } finally {
      await _storage.clearSession();
    }
  }

  // ── Get Current User ──────────────────────────────────────────────────────
  /// Ambil data user dari secure storage (offline-first).
  /// Jika tidak ada, fetch dari API.
  Future<UserModel?> getCurrentUser() async {
    final userJson = await _storage.getUser();
    if (userJson != null) {
      return UserModel.fromJsonString(userJson);
    }

    // Fallback: fetch dari API
    try {
      final response = await _client.get(ApiConstants.me);
      final user = UserModel.fromJson(
        response['data']['user'] as Map<String, dynamic>,
      );
      await _storage.saveUser(user.toJsonString());
      return user;
    } catch (_) {
      return null;
    }
  }

  // ── Check Session ─────────────────────────────────────────────────────────
  /// Cek apakah ada token yang tersimpan (untuk auto-login saat app start)
  Future<bool> hasValidSession() => _storage.hasSession();
}
