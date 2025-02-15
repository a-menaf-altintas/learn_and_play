import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/literacy_screen.dart';
import 'screens/math_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn & Play',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      routes: {
        '/literacy': (context) => const LiteracyScreen(),
        '/math': (context) => const MathScreen(),
      },
    );
  }
}
