import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';
import 'screens/dashboard_screen.dart';

final Color primaryColor = Color(0xFF43CEA2); // Teal to blue gradient
final Color secondaryColor = Color(0xFF185A9D);
final Color accentColor = Color(0xFF6BCB77); // Green accent
final Color backgroundColor = Color(0xFFF6FCFF); // Soft white-blue
final Color cardColor = Colors.white;

void main() {
  runApp(ChangeNotifierProvider(create: (_) => MqttService(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Soil Monitor',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          background: backgroundColor,
          surface: cardColor,
        ),
        cardColor: cardColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}