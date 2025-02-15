import 'package:flutter/material.dart';

class MathScreen extends StatelessWidget {
  const MathScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Module'),
      ),
      body: const Center(
        child: Text('Welcome to the Math Module!'),
      ),
    );
  }
}
