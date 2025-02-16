// FILE: /lib/screens/one_dimensional_shapes_screen.dart

import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/dimension_shape_tracing_screen.dart';

// We'll define some 1D shapes and their colors
class OneDimensionalShapesScreen extends StatelessWidget {
  const OneDimensionalShapesScreen({Key? key}) : super(key: key);

  // Suppose we define a few shapes:
  // "Line", "Ray", "Line Segment"
  // Each has a distinct color
  static const List<Map<String, dynamic>> oneDShapes = [
    {
      'name': 'Line',
      'color': Colors.red,
    },
    {
      'name': 'Ray',
      'color': Colors.green,
    },
    {
      'name': 'Line Segment',
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1D Shapes'),
      ),
      body: Center(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: oneDShapes.map((shapeData) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: shapeData['color'],
              ),
              onPressed: () {
                // Navigate to the tracing screen with shape name & color
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DimensionShapeTracingScreen(
                      shapeName: shapeData['name'] as String,
                      shapeColor: shapeData['color'] as Color,
                      dimension: '1D',
                    ),
                  ),
                );
              },
              child: Text(
                shapeData['name'] as String,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
