// ─────────────────────────────────────────────────────────────────────────────
// register_screen.dart
// Halaman registrasi akun baru.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool  _obscure    = true;

  late final AnimationController _animCtrl;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync   : this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end  : Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final ok   = await auth.register(
      name    : _nameCtrl.text.trim(),
      email   : _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Akun berhasil dibuat! Selamat datang 🎉');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      AppSnackbar.showError(context, auth.errorMessage ?? 'Registrasi gagal');
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading   = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity : _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width : 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [colorScheme.primary, colorScheme.tertiary],
                                begin : Alignment.topLeft,
                                end   : Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.task_alt_rounded,
                                color: Colors.white, size: 38),
                          ),
                          const SizedBox(height: 16),
                          Text('TaskiFlow',
                              style: TextStyle(
                                fontSize  : 28,
                                fontWeight: FontWeight.w800,
                                color     : colorScheme.onSurface,
                                letterSpacing: -0.5,
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    Text('Buat Akun Baru',
                        style: TextStyle(
                          fontSize  : 22,
                          fontWeight: FontWeight.w700,
                          color     : colorScheme.onSurface,
                        )),
                    const SizedBox(height: 4),
                    Text('Daftar untuk mulai menggunakan TaskiFlow',
                        style: TextStyle(
                          fontSize: 14,
                          color   : colorScheme.onSurface.withOpacity(0.5),
                        )),

                    const SizedBox(height: 28),

                    AppTextField(
                      controller     : _nameCtrl,
                      label          : 'Nama Lengkap',
                      hint           : 'John Doe',
                      prefixIcon     : const Icon(Icons.person_outline, size: 20),
                      validator      : Validators.name,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller     : _emailCtrl,
                      label          : 'Email',
                      hint           : 'user@email.com',
                      keyboardType   : TextInputType.emailAddress,
                      prefixIcon     : const Icon(Icons.email_outlined, size: 20),
                      validator      : Validators.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller     : _passCtrl,
                      label          : 'Password',
                      hint           : 'Minimal 6 karakter',
                      obscureText    : _obscure,
                      prefixIcon     : const Icon(Icons.lock_outline, size: 20),
                      suffixIcon     : IconButton(
                        icon     : Icon(_obscure ? Icons.visibility_off_outlined
                                                 : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator      : Validators.password,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    const SizedBox(height: 28),

                    AppButton(
                      label    : 'Daftar',
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah punya akun? ',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              )),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: Text('Masuk',
                                style: TextStyle(
                                  color     : colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ],
                      ),
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
}
