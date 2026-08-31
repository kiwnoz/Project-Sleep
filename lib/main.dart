import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // โหลดค่า Appearance ที่บันทึกไว้ (จากหน้า Settings) ก่อนเปิดแอป
  // กัน UI กระพริบธีมผิดแวบแรกที่เปิด
  final prefs = await SharedPreferences.getInstance();
  final savedAppearance = prefs.getString('settings_appearance') ?? 'light';
  AppTheme.themeNotifier.value = switch (savedAppearance) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };

  runApp(const SleepWiseApp());
}

class SleepWiseApp extends StatelessWidget {
  const SleepWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'SleepWise AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          navigatorObservers: [routeObserver],
          home: const SplashScreen(),
        ); // MaterialApp
      },
    );
  }
}