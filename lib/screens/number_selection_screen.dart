import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/number_tracing_screen.dart';

class NumberSelectionScreen extends StatelessWidget {
  const NumberSelectionScreen({Key? key}) : super(key: key);

  static const List<String> digits = [
    '0','1','2','3','4','5','6','7','8','9',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Number'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: digits.map((digit) {
              return HoverableNumberButton(number: digit);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// A button that shows one digit, grows on hover, navigates to NumberTracingScreen
class HoverableNumberButton extends StatefulWidget {
  final String number;
  const HoverableNumberButton({
    Key? key,
    required this.number,
  }) : super(key: key);

  @override
  State<HoverableNumberButton> createState() => _HoverableNumberButtonState();
}

class _HoverableNumberButtonState extends State<HoverableNumberButton> {
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
                builder: (context) => NumberTracingScreen(number: widget.number),
              ),
            );
          },
          child: Text(widget.number, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
