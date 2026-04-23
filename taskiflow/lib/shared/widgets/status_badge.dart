// ─────────────────────────────────────────────────────────────────────────────
// status_badge.dart
// Chip kecil berwarna yang menunjukkan status task.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../features/tasks/models/task_model.dart';

class StatusBadge extends StatelessWidget {
  final TaskModel task;
  final bool small;

  const StatusBadge({super.key, required this.task, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = task.statusColor;
    final label = task.statusLabel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical  : small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color       : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border      : Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(task.statusIcon, size: small ? 11 : 13, color: color),
          SizedBox(width: small ? 4 : 5),
          Text(
            label,
            style: TextStyle(
              color      : color,
              fontSize   : small ? 10 : 12,
              fontWeight : FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
