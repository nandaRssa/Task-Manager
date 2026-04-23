// ─────────────────────────────────────────────────────────────────────────────
// app_snackbar.dart
// Helper statis untuk menampilkan snackbar sukses/error secara konsisten.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message,
        backgroundColor: const Color(0xFF10B981),
        icon: Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message,
        backgroundColor: const Color(0xFFEF4444),
        icon: Icons.error_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message,
        backgroundColor: const Color(0xFF3B82F6),
        icon: Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
