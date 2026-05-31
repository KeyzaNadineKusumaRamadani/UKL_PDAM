import 'package:flutter/material.dart';
import 'views/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alirin - PDAM Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1565FF),
          secondary: Color(0xFF00B8D4),
          surface: Color(0xFFFFFFFF),
        ),
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FF),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SplashView(),
    );
  }
}
