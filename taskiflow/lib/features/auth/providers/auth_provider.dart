// ─────────────────────────────────────────────────────────────────────────────
// auth_provider.dart
// State management untuk autentikasi.
// Pattern: ChangeNotifier dengan enum state — mudah diexplain saat demo.
//
// State flow:
//   app start → initial → (check session) → authenticated / unauthenticated
//   login      → loading → authenticated / error
//   logout     → unauthenticated
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final _service = AuthService.instance;

  AuthStatus _status  = AuthStatus.initial;
  UserModel? _user;
  String?    _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool get isAuthenticated    => _status == AuthStatus.authenticated;
  bool get isLoading          => _status == AuthStatus.loading;

  // ── Inisialisasi (dipanggil dari main.dart) ───────────────────────────────
  /// Setup callback untuk auto-logout ketika refresh token expired
  void setupSessionExpiredCallback(BuildContext context) {
    ApiClient.instance.onSessionExpired = () {
      // Pastikan dipanggil di main isolate
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _forceLogout(context);
      });
    };
  }

  /// Auto-login: cek apakah ada session yang tersimpan.
  /// Dipanggil saat app pertama kali start (di main.dart).
  Future<void> tryAutoLogin() async {
    _setStatus(AuthStatus.loading);
    try {
      final hasSession = await _service.hasValidSession();
      if (hasSession) {
        _user = await _service.getCurrentUser();
        _setStatus(_user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated);
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (_) {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setLoading();
    try {
      _user = await _service.login(email: email, password: password);
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } on NetworkException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Terjadi kesalahan. Coba lagi.');
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      _user = await _service.register(name: name, email: email, password: password);
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } on NetworkException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Registrasi gagal. Coba lagi.');
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  // ── Force Logout (session expired) ───────────────────────────────────────
  void _forceLogout(BuildContext context) {
    _user = null;
    _setStatus(AuthStatus.unauthenticated);
    // Navigate ke login dan hapus semua route sebelumnya
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  // ── State helpers ─────────────────────────────────────────────────────────
  void _setStatus(AuthStatus status) {
    _status = status;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
