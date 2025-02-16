// FILE: /lib/screens/shape_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:learn_and_play/screens/one_dimensional_shapes_screen.dart';
import 'package:learn_and_play/screens/two_dimensional_shapes_screen.dart';
import 'package:learn_and_play/screens/three_dimensional_shapes_screen.dart';

class ShapeSelectionScreen extends StatelessWidget {
  const ShapeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shapes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1) 1D Shapes
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OneDimensionalShapesScreen(),
                  ),
                );
              },
              child: const Text('1D Shapes'),
            ),
            const SizedBox(height: 20),

            // 2) 2D Shapes
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TwoDimensionalShapesScreen(),
                  ),
                );
              },
              child: const Text('2D Shapes'),
            ),
            const SizedBox(height: 20),

            // 3) 3D Shapes
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ThreeDimensionalShapesScreen(),
                  ),
                );
              },
              child: const Text('3D Shapes'),
            ),
          ],
        ),
      ),
    );
  }
}
