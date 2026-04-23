// ─────────────────────────────────────────────────────────────────────────────
// task_list_screen.dart
// Halaman utama: list task + search + filter + pull-to-refresh.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/task_provider.dart' show TaskProvider, ViewState;
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/app_snackbar.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Setup auto-logout callback setelah widget mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().setupSessionExpiredCallback(context);
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<TaskProvider>().loadTasks(silent: true);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title  : const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child    : const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child    : const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<TaskProvider>().reset();
      await context.read<AuthProvider>().logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final auth        = context.watch<AuthProvider>();
    final taskProv    = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom AppBar ─────────────────────────────────────────────
            _buildAppBar(context, auth, colorScheme),

            // ── Search Bar ────────────────────────────────────────────────
            _buildSearchBar(context, taskProv, colorScheme),

            // ── Filter Chips ──────────────────────────────────────────────
            _buildFilterChips(context, taskProv, colorScheme),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: _buildBody(context, taskProv, colorScheme),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag  : 'fab-add-task',
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/tasks/create');
          if (result == true && mounted) {
            AppSnackbar.showSuccess(context, 'Task berhasil ditambahkan!');
          }
        },
        icon     : const Icon(Icons.add_rounded),
        label    : const Text('Task Baru', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthProvider auth, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          // Avatar + greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${auth.user?.name.split(' ').first ?? 'User'}',
                  style: TextStyle(
                    fontSize  : 22,
                    fontWeight: FontWeight.w800,
                    color     : cs.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Apa yang akan dikerjakan hari ini?',
                  style: TextStyle(
                    fontSize: 13,
                    color   : cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Avatar button → logout
          GestureDetector(
            onTap: _confirmLogout,
            child: Container(
              width : 42,
              height: 42,
              decoration: BoxDecoration(
                gradient    : LinearGradient(
                  colors    : [cs.primary, cs.tertiary],
                  begin     : Alignment.topLeft,
                  end       : Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  auth.user?.initials ?? '?',
                  style: const TextStyle(
                    color     : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize  : 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, TaskProvider taskProv, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextFormField(
        controller: _searchCtrl,
        onChanged : taskProv.setSearch,
        decoration: InputDecoration(
          hintText   : 'Cari task...',
          prefixIcon : const Icon(Icons.search_rounded, size: 20),
          suffixIcon : taskProv.searchQuery.isNotEmpty
              ? IconButton(
                  icon     : const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    taskProv.clearSearch();
                  },
                )
              : null,
          filled     : true,
          fillColor  : cs.surface,
          border     : OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide  : BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, TaskProvider taskProv, ColorScheme cs) {
    final filters = AppConstants.statusLabels;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding        : const EdgeInsets.symmetric(horizontal: 20),
        children: filters.entries.map((entry) {
          final isSelected = taskProv.statusFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label         : Text(entry.value),
              selected      : isSelected,
              onSelected    : (_) => taskProv.setStatusFilter(entry.key),
              showCheckmark : false,
              selectedColor : cs.primaryContainer,
              labelStyle    : TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize  : 13,
                color     : isSelected ? cs.primary : cs.onSurface.withOpacity(0.7),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TaskProvider taskProv, ColorScheme cs) {
    // Loading state (initial load) — tampilkan shimmer
    if (taskProv.state == ViewState.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child  : LoadingShimmer(itemCount: 5),
      );
    }

    // Error state
    if (taskProv.state == ViewState.error && taskProv.filteredTasks.isEmpty) {
      return ErrorState(
        message: taskProv.errorMessage ?? 'Gagal memuat data',
        onRetry: () => taskProv.loadTasks(),
      );
    }

    final tasks = taskProv.filteredTasks;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color    : cs.primary,
      child: tasks.isEmpty
          ? ListView( 
              physics : const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                EmptyState(
                  title   : taskProv.searchQuery.isNotEmpty || taskProv.statusFilter != 'all'
                      ? 'Tidak ada hasil'
                      : 'Belum ada task',
                  subtitle: taskProv.searchQuery.isNotEmpty || taskProv.statusFilter != 'all'
                      ? 'Coba ubah kata kunci atau filter.'
                      : 'Tap tombol + untuk membuat task pertama Anda.',
                ),
              ],
            )
          : ListView.builder(
              physics    : const AlwaysScrollableScrollPhysics(),
              padding    : const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount  : tasks.length,
              itemBuilder: (_, i) {
                final task = tasks[i];
                return TaskCard(
                  key     : Key(task.id),
                  task    : task,
                  onTap   : () => Navigator.pushNamed(
                    context, '/tasks/detail',
                    arguments: task.id,
                  ),
                  onDelete: () async {
                    final ok = await taskProv.deleteTask(task.id);
                    if (mounted) {
                      if (ok) {
                        AppSnackbar.showSuccess(context, 'Task dihapus');
                      } else {
                        AppSnackbar.showError(
                            context, taskProv.errorMessage ?? 'Gagal menghapus');
                      }
                    }
                  },
                );
              },
            ),
    );
  }
}
