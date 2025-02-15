import 'package:flutter/material.dart';

class ArithmeticPracticeScreen extends StatelessWidget {
  final String operation;

  const ArithmeticPracticeScreen({
    Key? key,
    required this.operation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(operation),
      ),
      body: Center(
        child: Text(
          'TODO: Implement $operation practice here!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
