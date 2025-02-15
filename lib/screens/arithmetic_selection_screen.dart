import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/arithmetic_practice_screen.dart';

class ArithmeticSelectionScreen extends StatelessWidget {
  const ArithmeticSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arithmetic'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Choose an Operation',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArithmeticPracticeScreen(
                        operation: 'Addition',
                      ),
                    ),
                  );
                },
                child: const Text('Addition'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArithmeticPracticeScreen(
                        operation: 'Subtraction',
                      ),
                    ),
                  );
                },
                child: const Text('Subtraction'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArithmeticPracticeScreen(
                        operation: 'Multiplication',
                      ),
                    ),
                  );
                },
                child: const Text('Multiplication'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArithmeticPracticeScreen(
                        operation: 'Division',
                      ),
                    ),
                  );
                },
                child: const Text('Division'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
