// ─────────────────────────────────────────────────────────────────────────────
// task_create_screen.dart
// Form untuk membuat task baru.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen>
    with SingleTickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _status   = AppConstants.statusPending;

  late final AnimationController _animCtrl;
  late final Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end  : Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final prov = context.read<TaskProvider>();
    final ok   = await prov.createTask(
      title      : _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status     : _status,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true); // true = sukses → list tampilkan snackbar
    } else {
      AppSnackbar.showError(context, prov.errorMessage ?? 'Gagal membuat task');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme  = Theme.of(context).colorScheme;
    final isSubmitting = context.watch<TaskProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title           : const Text('Task Baru',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation       : 0,
      ),
      body: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child  : Form(
            key : _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: 'Judul Task *'),
                const SizedBox(height: 8),
                AppTextField(
                  controller     : _titleCtrl,
                  label          : 'Judul',
                  hint           : 'Contoh: Buat laporan UTS',
                  validator      : Validators.taskTitle,
                  prefixIcon     : const Icon(Icons.title_rounded, size: 20),
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 20),

                _FieldLabel(label: 'Deskripsi (opsional)'),
                const SizedBox(height: 8),
                AppTextField(
                  controller     : _descCtrl,
                  label          : 'Deskripsi',
                  hint           : 'Detail tambahan tentang task ini...',
                  maxLines       : 4,
                  prefixIcon     : const Icon(Icons.notes_rounded, size: 20),
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 20),

                _FieldLabel(label: 'Status Awal'),
                const SizedBox(height: 8),
                _StatusSelector(
                  selected : _status,
                  onChanged: (val) => setState(() => _status = val),
                ),

                const SizedBox(height: 32),

                AppButton(
                  label    : 'Buat Task',
                  onPressed: _submit,
                  isLoading: isSubmitting,
                  icon     : isSubmitting ? null : Icons.add_task_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// task_edit_screen.dart logic digabung di bawah agar mudah diperlihatkan.
// File terpisah ada di task_edit_screen.dart.
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
          fontSize  : 13,
          fontWeight: FontWeight.w600,
          color     : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ));
  }
}

class _StatusSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _StatusSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (AppConstants.statusPending,    'Pending',     const Color(0xFFF59E0B), Icons.radio_button_unchecked),
      (AppConstants.statusInProgress, 'In Progress', const Color(0xFF3B82F6), Icons.timelapse),
      (AppConstants.statusCompleted,  'Completed',   const Color(0xFF10B981), Icons.check_circle),
    ];

    return Row(
      children: options.map((opt) {
        final (value, label, color, icon) = opt;
        final isSelected = selected == value;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin  : const EdgeInsets.only(right: 8),
              padding : const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color       : isSelected ? color.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border      : Border.all(
                  color: isSelected ? color : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: isSelected ? color : Colors.grey, size: 22),
                  const SizedBox(height: 5),
                  Text(label,
                      textAlign: TextAlign.center,
                      style    : TextStyle(
                        fontSize  : 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color     : isSelected ? color : Colors.grey,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
