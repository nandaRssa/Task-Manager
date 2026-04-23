// ─────────────────────────────────────────────────────────────────────────────
// app.dart
// Root MaterialApp dengan ThemeData, named routes, dan custom page transitions.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/tasks/screens/task_list_screen.dart';
import 'features/tasks/screens/task_detail_screen.dart';
import 'features/tasks/screens/task_create_screen.dart';
import 'features/tasks/screens/task_edit_screen.dart';

class TaskiFlowApp extends StatelessWidget {
  const TaskiFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title          : 'TaskiFlow',
      debugShowCheckedModeBanner: false,
      theme          : _buildTheme(Brightness.light),
      darkTheme      : _buildTheme(Brightness.dark),
      themeMode      : ThemeMode.system,

      // ── Route guard ───────────────────────────────────────────────────────
      // Tentukan initial route berdasarkan AuthStatus
      home: _AuthGate(),

      // ── Named routes ──────────────────────────────────────────────────────
      onGenerateRoute: _onGenerateRoute,
    );
  }

  // ── Routes ─────────────────────────────────────────────────────────────────
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/login':
        page = const LoginScreen();
        break;
      case '/register':
        page = const RegisterScreen();
        break;
      case '/home':
        page = const TaskListScreen();
        break;
      case '/tasks/detail':
        page = const TaskDetailScreen();
        break;
      case '/tasks/create':
        page = const TaskCreateScreen();
        break;
      case '/tasks/edit':
        page = const TaskEditScreen();
        break;
      default:
        page = const LoginScreen();
    }

    // Slide transition untuk semua routes
    return PageRouteBuilder<dynamic>(
      settings        : settings,
      pageBuilder     : (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end  : Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child   : child,
        );
      },
    );
  }

  // ── Theme ───────────────────────────────────────────────────────────────────
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor      : const Color(0xFF6366F1), // indigo
      brightness     : brightness,
      primary        : const Color(0xFF6366F1),
      secondary      : const Color(0xFF8B5CF6),
      tertiary       : const Color(0xFFA78BFA),
      surface        : isDark ? const Color(0xFF1E1E2E) : Colors.white,
      surfaceContainerLowest: isDark ? const Color(0xFF161622) : const Color(0xFFF5F5FA),
      surfaceContainerHighest: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFEEEEF5),
    );

    final textTheme = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3    : true,
      colorScheme     : colorScheme,
      textTheme       : textTheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation       : 0,
        titleTextStyle  : GoogleFonts.inter(
          fontSize  : 18,
          fontWeight: FontWeight.w700,
          color     : colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Card
cardTheme: CardThemeData(
          color        : colorScheme.surface,
        elevation    : 0,
        shape        : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        shape          : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor : colorScheme.surfaceContainerHighest,
        shape           : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side : BorderSide.none,
      ),

      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AuthGate: Tampilkan splash/loading saat cek session, lalu redirect.
// ─────────────────────────────────────────────────────────────────────────────
class _AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return _SplashScreen();

      case AuthStatus.authenticated:
        return const TaskListScreen();

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width : 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin : Alignment.topLeft,
                  end   : Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.task_alt_rounded,
                  color: Colors.white, size: 42),
            ),
            const SizedBox(height: 24),
            Text('TaskiFlow',
                style: TextStyle(
                  fontSize  : 30,
                  fontWeight: FontWeight.w800,
                  color     : colorScheme.onSurface,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 40),
            SizedBox(
              width : 28,
              height: 28,
              child : CircularProgressIndicator(
                strokeWidth: 2.5,
                color      : colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
