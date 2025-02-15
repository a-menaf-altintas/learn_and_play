// FILE: /lib/screens/arithmetic_practice_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';

/// This screen is launched when the user picks "Addition", "Subtraction", etc.
/// from the ArithmeticSelectionScreen. 
/// We'll create random problems, let the user type an answer, 
/// and award stars for correct solutions.
class ArithmeticPracticeScreen extends StatefulWidget {
  final String operation;

  const ArithmeticPracticeScreen({
    Key? key,
    required this.operation,
  }) : super(key: key);

  @override
  State<ArithmeticPracticeScreen> createState() =>
      _ArithmeticPracticeScreenState();
}

class _ArithmeticPracticeScreenState extends State<ArithmeticPracticeScreen> {
  // We'll store the current problem's operands plus the correct answer
  late int _operand1;
  late int _operand2;
  late int _correctAnswer;

  // We'll keep a random generator to produce new problems
  final _random = Random();

  // We'll keep track of user input in a TextField
  final TextEditingController _answerController = TextEditingController();

  // We'll show feedback like "Correct!" or "Incorrect!"
  String _feedback = '';

  // We'll store how many stars the user has earned
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _generateNewProblem(); // As soon as the screen loads, make a random problem
  }

  @override
  void dispose() {
    // Always dispose of controllers
    _answerController.dispose();
    super.dispose();
  }

  /// Generates a new problem based on widget.operation ("Addition", etc.)
  void _generateNewProblem() {
    setState(() {
      // We'll pick random operands from 1..10 for simplicity
      _operand1 = _random.nextInt(10) + 1; 
      _operand2 = _random.nextInt(10) + 1; 

      // Compute the correct answer
      _correctAnswer = _computeAnswer(
        operation: widget.operation,
        a: _operand1,
        b: _operand2,
      );

      // Clear any old input and feedback
      _answerController.clear();
      _feedback = '';
    });
  }

  /// Given an operation name and two numbers, returns the correct result
  int _computeAnswer({
    required String operation,
    required int a,
    required int b,
  }) {
    switch (operation) {
      case 'Addition':
        return a + b;
      case 'Subtraction':
        return a - b;
      case 'Multiplication':
        return a * b;
      case 'Division':
        // We'll do integer division: 7 / 2 = 3
        if (b == 0) return 0; 
        return a ~/ b;
      default:
        // fallback
        return 0;
    }
  }

  /// Check if user typed the correct answer
  void _checkAnswer() {
    if (_answerController.text.isEmpty) return;

    // Try to parse user input as an integer
    final userAnswer = int.tryParse(_answerController.text);
    if (userAnswer == null) {
      // If parse fails, just return or show error
      setState(() {
        _feedback = 'Please type a valid number.';
      });
      return;
    }

    if (userAnswer == _correctAnswer) {
      // Correct
      setState(() {
        _feedback = 'Correct!';
        _stars++; // Award a star
      });
    } else {
      // Incorrect
      setState(() {
        _feedback = 'Incorrect. Try again!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We'll display some star icons in the app bar
    final starIcons = List<Widget>.generate(
      _stars,
      (index) => const Icon(Icons.star, color: Colors.yellow),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.operation),
        actions: [
          // Show star icons for each star earned
          Row(children: starIcons),
          const SizedBox(width: 16), // spacing on the right
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the current problem, e.g. 4 + 7 = ?
              Text(
                '${_operand1} ${_symbolForOperation(widget.operation)} $_operand2 = ?',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 20),

              // TextField for user input
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _answerController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter answer',
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Check button
              ElevatedButton(
                onPressed: _checkAnswer,
                child: const Text('Check'),
              ),
              const SizedBox(height: 10),

              // Feedback
              Text(
                _feedback,
                style: TextStyle(
                  fontSize: 18,
                  color: (_feedback == 'Correct!') ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 20),

              // Next Problem button
              ElevatedButton(
                onPressed: _generateNewProblem,
                child: const Text('Next Problem'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Convert "Addition" => "+" etc.
  String _symbolForOperation(String operation) {
    switch (operation) {
      case 'Addition':
        return '+';
      case 'Subtraction':
        return '-';
      case 'Multiplication':
        return '×';
      case 'Division':
        return '÷';
      default:
        return '?';
    }
  }
}
