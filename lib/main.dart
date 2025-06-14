import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'home_page.dart'; // Asumsikan HomePage kamu dipindah ke file ini

void main() => runApp(SHYPROMApp());

class SHYPROMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHYPROM Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF6B4226),
        scaffoldBackgroundColor: Color(0xFFF7F3EF),
        textTheme: GoogleFonts.poppinsTextTheme(), // <-- Ganti font di sini
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF6B4226),
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown).copyWith(
          secondary: Colors.green.shade700,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
