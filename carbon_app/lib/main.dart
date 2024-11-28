import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CarbonApp());
}

class CarbonApp extends StatelessWidget {
  const CarbonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
