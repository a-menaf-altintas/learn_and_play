import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/number_selection_screen.dart';
import 'package:learn_and_play/screens/number_tracing_screen.dart';
import 'package:learn_and_play/screens/arithmetic_selection_screen.dart';
import 'package:learn_and_play/screens/shape_selection_screen.dart';

class MathScreen extends StatelessWidget {
  const MathScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Module'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Math Module!',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),

              // 1) Free Draw
              ElevatedButton(
                onPressed: () {
                  // Go to number_tracing_screen in "free draw" mode => number=''
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NumberTracingScreen(number: ''),
                    ),
                  );
                },
                child: const Text('Free Draw'),
              ),
              const SizedBox(height: 20),

              // 2) Draw Numbers
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NumberSelectionScreen(),
                    ),
                  );
                },
                child: const Text('Draw Numbers'),
              ),
              const SizedBox(height: 20),

              // 3) Arithmetic (Add/Sub/Mul/Div)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArithmeticSelectionScreen(),
                    ),
                  );
                },
                child: const Text('Arithmetic'),
              ),
              const SizedBox(height: 20),

              // 4) Shapes
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShapeSelectionScreen(),
                    ),
                  );
                },
                child: const Text('Shapes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
