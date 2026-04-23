// ─────────────────────────────────────────────────────────────────────────────
// app_constants.dart
// Konstanta UI dan logika aplikasi.
// ─────────────────────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  static const String appName     = 'TaskiFlow';
  static const String appVersion  = '1.0.0';

  // Storage keys (digunakan oleh SecureStorage)
  static const String keyAccessToken  = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser         = 'user_data';

  // Task status values (harus sesuai dengan backend enum)
  static const String statusPending    = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted  = 'completed';

  // Filter labels untuk UI
  static const Map<String, String> statusLabels = {
    'all'         : 'All',
    'pending'     : 'Pending',
    'in_progress' : 'In Progress',
    'completed'   : 'Completed',
  };
}
