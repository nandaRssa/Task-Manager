// ─────────────────────────────────────────────────────────────────────────────
// exceptions.dart
// Custom exception hierarchy untuk error handling yang terstruktur.
// Error dari service layer dilempar sebagai exception ini, lalu ditangkap
// di provider layer dan diexpose ke UI sebagai string message.
// ─────────────────────────────────────────────────────────────────────────────

/// Exception umum dari API response (success: false)
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Exception spesifik untuk auth errors (401, token invalid, dll)
class AuthException extends ApiException {
  const AuthException(super.message, {super.statusCode});
}

/// Exception untuk network problems (timeout, no internet)
class NetworkException implements Exception {
  final String message;
  const NetworkException(
      [this.message = 'Tidak ada koneksi internet. Periksa jaringan Anda.']);

  @override
  String toString() => 'NetworkException: $message';
}
