// ─────────────────────────────────────────────────────────────────────────────
// empty_state.dart
// Tampilan ketika tidak ada data.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    this.title       = 'Belum ada task',
    this.subtitle    = 'Tap tombol + untuk membuat task baru.',
    this.onAction,
    this.actionLabel,
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
            // Illustrated icon
            Container(
              width      : 100,
              height     : 100,
              decoration : BoxDecoration(
                color        : colorScheme.primaryContainer.withOpacity(0.4),
                shape        : BoxShape.circle,
              ),
              child: Icon(
                Icons.checklist_rounded,
                size : 52,
                color: colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style     : TextStyle(
                fontSize  : 18,
                fontWeight: FontWeight.w700,
                color     : colorScheme.onSurface,
              ),
              textAlign : TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style    : TextStyle(
                fontSize : 14,
                color    : colorScheme.onSurface.withOpacity(0.5),
                height   : 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon     : const Icon(Icons.add, size: 18),
                label    : Text(actionLabel ?? 'Buat Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
