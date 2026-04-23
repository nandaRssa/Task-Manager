// ─────────────────────────────────────────────────────────────────────────────
// main.dart
// Entry point aplikasi.
// Setup MultiProvider dan panggil tryAutoLogin agar app cek session saat start.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/tasks/providers/task_provider.dart';

void main() async {
  // Pastikan Flutter binding terinisialisasi sebelum async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Orientasi hanya portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI overlay style — bar transparan
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor         : Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Buat AuthProvider dan panggil tryAutoLogin sebelum runApp
  // agar tidak ada flash ke login screen jika sudah ada session
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider dengan instance yang sudah diinisialisasi
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        // TaskProvider di-create lazy (baru diinit saat pertama kali diakses)
        ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider()),
      ],
      child: const TaskiFlowApp(),
    ),
  );
}
