import 'package:flutter/material.dart';
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
            const Text('Welcome to the Literacy Module!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TracingScreen()),
                );
              },
              child: const Text('Go to Tracing Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
