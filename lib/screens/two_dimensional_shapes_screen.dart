// FILE: /lib/screens/two_dimensional_shapes_screen.dart

import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/dimension_shape_tracing_screen.dart';

class TwoDimensionalShapesScreen extends StatelessWidget {
  const TwoDimensionalShapesScreen({Key? key}) : super(key: key);

  // Some 2D shapes: Circle, Square, Triangle
  static const List<Map<String, dynamic>> twoDShapes = [
    {
      'name': 'Circle',
      'color': Colors.orange,
    },
    {
      'name': 'Square',
      'color': Colors.purple,
    },
    {
      'name': 'Triangle',
      'color': Colors.pink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2D Shapes'),
      ),
      body: Center(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: twoDShapes.map((shapeData) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: shapeData['color'],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DimensionShapeTracingScreen(
                      shapeName: shapeData['name'] as String,
                      shapeColor: shapeData['color'] as Color,
                      dimension: '2D',
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
