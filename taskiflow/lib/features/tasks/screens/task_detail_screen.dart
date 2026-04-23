// ─────────────────────────────────────────────────────────────────────────────
// task_detail_screen.dart
// Halaman detail task dengan Hero animation.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/app_snackbar.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskModel? _task;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_task == null) {
      final taskId = ModalRoute.of(context)!.settings.arguments as String;
      final prov   = context.read<TaskProvider>();
      // Cari di list yang sudah ada (no extra API call)
      _task = prov.filteredTasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => throw Exception('Task not found'),
      );
    }
  }

  Future<void> _deleteTask() async {
    if (_task == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title  : const Text('Hapus Task'),
        content: Text('Yakin ingin menghapus "${_task!.title}"?'),
        actions: [
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

    if (confirmed != true || !mounted) return;

    final ok = await context.read<TaskProvider>().deleteTask(_task!.id);
    if (mounted) {
      if (ok) {
        AppSnackbar.showSuccess(context, 'Task berhasil dihapus');
        Navigator.pop(context, true); // return true → list refresh indicator
      } else {
        AppSnackbar.showError(
          context,
          context.read<TaskProvider>().errorMessage ?? 'Gagal menghapus',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) {
      return const Scaffold(body: Center(child: Text('Task tidak ditemukan')));
    }

    final task        = _task!;
    final colorScheme = Theme.of(context).colorScheme;
    final isSubmitting = context.watch<TaskProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar dengan accent color ─────────────────────────────
          SliverAppBar(
            expandedHeight  : 160,
            pinned          : true,
            backgroundColor : task.accentColor,
            foregroundColor : Colors.white,
            flexibleSpace   : FlexibleSpaceBar(
              title          : Text(
                task.title,
                style: const TextStyle(
                  color     : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize  : 16,
                ),
              ),
              titlePadding   : const EdgeInsets.fromLTRB(16, 0, 16, 16),
              background     : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin  : Alignment.topLeft,
                    end    : Alignment.bottomRight,
                    colors : [
                      task.accentColor,
                      task.accentColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon     : const Icon(Icons.edit_outlined),
                tooltip  : 'Edit',
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context, '/tasks/edit',
                    arguments: task.id,
                  );
                  if (result == true && mounted) {
                    // Update local reference
                    final prov  = context.read<TaskProvider>();
                    final updated = prov.filteredTasks.cast<TaskModel?>()
                        .firstWhere((t) => t?.id == task.id, orElse: () => null);
                    if (updated != null) setState(() => _task = updated);
                    AppSnackbar.showSuccess(context, 'Task diperbarui!');
                  }
                },
              ),
              IconButton(
                icon     : isSubmitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.delete_outline),
                tooltip  : 'Hapus',
                onPressed: isSubmitting ? null : _deleteTask,
              ),
            ],
          ),

          // ── Detail content ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Row(
                    children: [
                      StatusBadge(task: task),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description section
                  _SectionLabel(label: 'Deskripsi'),
                  const SizedBox(height: 8),
                  Container(
                    width      : double.infinity,
                    padding    : const EdgeInsets.all(16),
                    decoration : BoxDecoration(
                      color       : colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.description?.isNotEmpty == true
                          ? task.description!
                          : 'Tidak ada deskripsi.',
                      style: TextStyle(
                        fontSize: 15,
                        height  : 1.6,
                        color   : task.description?.isNotEmpty == true
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withOpacity(0.4),
                        fontStyle: task.description?.isNotEmpty == true
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timeline section
                  _SectionLabel(label: 'Timeline'),
                  const SizedBox(height: 8),
                  _InfoTile(
                    icon : Icons.calendar_today_outlined,
                    label: 'Dibuat',
                    value: DateFormat('EEEE, d MMMM yyyy • HH:mm').format(task.createdAt),
                    color: colorScheme,
                  ),
                  const SizedBox(height: 8),
                  _InfoTile(
                    icon : Icons.update_rounded,
                    label: 'Terakhir diubah',
                    value: DateFormat('EEEE, d MMMM yyyy • HH:mm').format(task.updatedAt),
                    color: colorScheme,
                  ),

                  const SizedBox(height: 40),

                  // Edit button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context, '/tasks/edit',
                          arguments: task.id,
                        );
                        if (result == true && mounted) {
                          final prov    = context.read<TaskProvider>();
                          final updated = prov.filteredTasks.cast<TaskModel?>()
                              .firstWhere((t) => t?.id == task.id, orElse: () => null);
                          if (updated != null) setState(() => _task = updated);
                          AppSnackbar.showSuccess(context, 'Task diperbarui!');
                        }
                      },
                      icon : const Icon(Icons.edit_rounded),
                      label: const Text('Edit Task',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape      : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
          fontSize  : 12,
          fontWeight: FontWeight.w700,
          color     : Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
          letterSpacing: 1.2,
        ));
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding   : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color       : color.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color   : color.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                    fontSize  : 13,
                    fontWeight: FontWeight.w500,
                    color     : color.onSurface,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
