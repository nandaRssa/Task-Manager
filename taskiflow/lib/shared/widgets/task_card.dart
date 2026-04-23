// ─────────────────────────────────────────────────────────────────────────────
// task_card.dart
// Card untuk satu task di list. Fitur:
//   - Left border berwarna sesuai status
//   - Hero animation tag untuk transisi ke detail
//   - Swipe-to-delete gesture
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/tasks/models/task_model.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = task.status == 'completed';

    return Dismissible(
      key       : Key(task.id),
      direction : DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      confirmDismiss: (_) async {
        return await _showDeleteConfirm(context);
      },
      background: Container(
        margin          : const EdgeInsets.symmetric(vertical: 5),
        decoration      : BoxDecoration(
          color         : const Color(0xFFEF4444),
          borderRadius  : BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding  : const EdgeInsets.only(right: 20),
        child    : const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: 'task-${task.id}',
          child: Material(
            color       : Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color       : colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border      : Border(
                  left: BorderSide(color: task.accentColor, width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color       : colorScheme.shadow.withOpacity(0.06),
                    blurRadius  : 8,
                    offset      : const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + badge row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize      : 15,
                              fontWeight    : FontWeight.w600,
                              color         : colorScheme.onSurface,
                              decoration    : isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            maxLines     : 2,
                            overflow     : TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        StatusBadge(task: task, small: true),
                      ],
                    ),

                    // Description
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.description!,
                        maxLines : 2,
                        overflow : TextOverflow.ellipsis,
                        style    : TextStyle(
                          fontSize : 13,
                          color    : colorScheme.onSurface.withOpacity(0.6),
                          height   : 1.4,
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Footer: date + arrow icon
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 12, color: colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('d MMM yyyy').format(task.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color   : colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: colorScheme.onSurface.withOpacity(0.3)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape     : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title     : const Text('Hapus Task'),
        content   : Text('Yakin ingin menghapus "${task.title}"?'),
        actions   : [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child    : const Text('Batal'),
          ),
          FilledButton(
            style    : FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child    : const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
