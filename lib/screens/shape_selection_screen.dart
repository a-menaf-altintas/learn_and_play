import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/shape_tracing_screen.dart';

class ShapeSelectionScreen extends StatelessWidget {
  const ShapeSelectionScreen({Key? key}) : super(key: key);

  // We'll define some example shapes: 1D line, 2D circle/square/triangle, 3D cube/sphere
  static const List<String> shapes = [
    'Line (1D)',
    'Circle (2D)',
    'Square (2D)',
    'Triangle (2D)',
    'Cube (3D)',
    'Sphere (3D)',
    'Cylinder (3D)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shapes'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: shapes.map((shape) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShapeTracingScreen(shape: shape),
                    ),
                  );
                },
                child: Text(shape),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
