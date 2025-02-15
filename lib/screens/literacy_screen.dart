import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/letter_selection_screen.dart';
import 'package:learn_and_play/screens/tracing_screen.dart';

class LiteracyScreen extends StatelessWidget {
  const LiteracyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Literacy Module'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Literacy Module!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),

            // 1) Free Draw button
            ElevatedButton(
              onPressed: () {
                // Navigate to tracing_screen in free-draw mode (letter='')
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TracingScreen(letter: ''),
                  ),
                );
              },
              child: const Text('Free Draw'),
            ),
            const SizedBox(height: 20),

            // 2) Draw Letters button => goes to a new screen
            ElevatedButton(
              onPressed: () {
                // Navigate to the letter selection page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LetterSelectionScreen(),
                  ),
                );
              },
              child: const Text('Draw Letters'),
            ),
          ],
        ),
      ),
    );
  }
}
