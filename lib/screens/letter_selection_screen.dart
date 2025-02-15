import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/tracing_screen.dart';

/// A separate screen that shows the A-Z letters.
/// On hover, each letter grows. On tap, navigate to TracingScreen(letter).
class LetterSelectionScreen extends StatelessWidget {
  const LetterSelectionScreen({Key? key}) : super(key: key);

  static const List<String> letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N',
    'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'V', 'W', 'X', 'Y', 'Z',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Letter'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: letters.map((letter) {
              return HoverableLetterButton(letter: letter);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// A small widget that displays a letter as a button.
/// On hover => scale up. On tap => go to TracingScreen(letter).
class HoverableLetterButton extends StatefulWidget {
  final String letter;

  const HoverableLetterButton({Key? key, required this.letter})
      : super(key: key);

  @override
  State<HoverableLetterButton> createState() => _HoverableLetterButtonState();
}

class _HoverableLetterButtonState extends State<HoverableLetterButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovering
            ? (Matrix4.identity()..scale(1.3))
            : Matrix4.identity(),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TracingScreen(letter: widget.letter),
              ),
            );
          },
          child: Text(widget.letter, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
