import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klasifikasi Jenis Tanah',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4E3D),
          primary: const Color(0xFF6B4E3D),
          secondary: const Color(0xFFD2B48C),
          background: const Color(0xFFF8F6F0),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F6F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6B4E3D),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B4E3D),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            elevation: 4,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}