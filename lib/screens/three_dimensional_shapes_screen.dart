// FILE: /lib/screens/three_dimensional_shapes_screen.dart

import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/dimension_shape_tracing_screen.dart';

class ThreeDimensionalShapesScreen extends StatelessWidget {
  const ThreeDimensionalShapesScreen({Key? key}) : super(key: key);

  // Some 3D shapes: Sphere, Cube, Cylinder
  static const List<Map<String, dynamic>> threeDShapes = [
    {
      'name': 'Sphere',
      'color': Colors.teal,
    },
    {
      'name': 'Cube',
      'color': Colors.indigo,
    },
    {
      'name': 'Cylinder',
      'color': Colors.brown,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Shapes'),
      ),
      body: Center(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: threeDShapes.map((shapeData) {
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
                      dimension: '3D',
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
