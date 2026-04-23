// ─────────────────────────────────────────────────────────────────────────────
// error_state.dart
// Tampilan ketika terjadi error dengan tombol retry.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width : 90,
              height: 90,
              decoration: BoxDecoration(
                color : colorScheme.errorContainer.withOpacity(0.4),
                shape : BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size : 44,
                color: colorScheme.error.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize  : 18,
                fontWeight: FontWeight.w700,
                color     : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color   : colorScheme.onSurface.withOpacity(0.6),
                height  : 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon     : const Icon(Icons.refresh_rounded, size: 18),
                label    : const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
