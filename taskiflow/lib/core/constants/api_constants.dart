// ─────────────────────────────────────────────────────────────────────────────
// api_constants.dart
// Semua URL endpoint terpusat di sini. Ubah baseUrl untuk switch environment.
// ─────────────────────────────────────────────────────────────────────────────

class ApiConstants {
  ApiConstants._(); // prevent instantiation

  /// Base URL backend — pastikan HP dan PC berada di WiFi yang sama!
  /// PC IP: 192.168.0.130, Backend port: 5000
  /// Untuk Android Emulator: gunakan http://10.0.2.2:5000
  /// Untuk HP fisik (WiFi sama): gunakan http://192.168.0.130:5000
  static const String baseUrl = 'http://192.168.0.130:5000';

  // ── Auth Endpoints ────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login    = '/auth/login';
  static const String logout   = '/auth/logout';
  static const String refresh  = '/auth/refresh';
  static const String me       = '/auth/me';

  // ── Task Endpoints ────────────────────────────────────────────────────────
  static const String tasks = '/tasks';
  static String taskById(String id) => '/tasks/$id';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
}
