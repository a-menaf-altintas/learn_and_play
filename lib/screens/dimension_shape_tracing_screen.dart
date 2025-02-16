// FILE: /lib/screens/dimension_shape_tracing_screen.dart

import 'package:flutter/material.dart';

/// For the pen/eraser logic, let's define an enum:
enum DSColorMode {
  pink,
  rainbow,
  purple,
  eraser,
}

/// A stroke for drawing
class DSStroke {
  final List<Offset> points;
  final DSColorMode colorMode;

  DSStroke({
    required this.points,
    required this.colorMode,
  });
}

class DimensionShapeTracingScreen extends StatefulWidget {
  final String shapeName;  // e.g. "Line", "Square", "Sphere"
  final Color shapeColor;  // The color we want for that shape
  final String dimension;  // "1D", "2D", or "3D"

  const DimensionShapeTracingScreen({
    Key? key,
    required this.shapeName,
    required this.shapeColor,
    required this.dimension,
  }) : super(key: key);

  @override
  State<DimensionShapeTracingScreen> createState() =>
      _DimensionShapeTracingScreenState();
}

class _DimensionShapeTracingScreenState
    extends State<DimensionShapeTracingScreen> {
  final List<DSStroke> _strokes = [];
  final List<DSStroke> _redoStrokes = [];

  DSStroke? _activeStroke;
  DSColorMode _selectedColorMode = DSColorMode.pink;

  bool _isHoveringPink = false;
  bool _isHoveringRainbow = false;
  bool _isHoveringPurple = false;
  bool _isHoveringEraser = false;

  Offset? _cursorPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.dimension} - ${widget.shapeName}'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo),
          IconButton(icon: const Icon(Icons.clear), onPressed: _clearAll),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.none,
              onHover: (event) {
                setState(() {
                  _cursorPosition = event.localPosition;
                });
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  setState(() {
                    _cursorPosition = event.localPosition;
                  });
                  _startStroke(event.localPosition);
                },
                onPointerMove: (event) {
                  setState(() {
                    _cursorPosition = event.localPosition;
                  });
                  _updateStroke(event.localPosition);
                },
                onPointerUp: (event) {
                  _endStroke();
                },
                child: Stack(
                  children: [
                    // 1) The faint shape we draw in code
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BackgroundShapePainter(
                          shapeName: widget.shapeName,
                          shapeColor: widget.shapeColor,
                          dimension: widget.dimension,
                        ),
                      ),
                    ),

                    // 2) The user's strokes
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DSTracingPainter(_strokes, _activeStroke),
                      ),
                    ),

                    // 3) Our custom pen/eraser icon
                    if (_cursorPosition != null)
                      Positioned(
                        left: _cursorPosition!.dx,
                        top: _cursorPosition!.dy,
                        child: Transform.translate(
                          offset: const Offset(-8, -24),
                          child: _buildCustomPenIcon(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // The bottom row of color icons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pink
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringPink = true),
                  onExit: (_) => setState(() => _isHoveringPink = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: _isHoveringPink
                        ? (Matrix4.identity()..scale(1.3))
                        : Matrix4.identity(),
                    child: IconButton(
                      icon: const Icon(Icons.circle, color: Colors.pink),
                      iconSize: 32,
                      onPressed: () {
                        setState(() {
                          _selectedColorMode = DSColorMode.pink;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Rainbow
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringRainbow = true),
                  onExit: (_) => setState(() => _isHoveringRainbow = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: _isHoveringRainbow
                        ? (Matrix4.identity()..scale(1.3))
                        : Matrix4.identity(),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorMode = DSColorMode.rainbow;
                        });
                      },
                      child: CustomPaint(
                        size: const Size.square(36),
                        painter: _RainbowCirclePainter(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Purple
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringPurple = true),
                  onExit: (_) => setState(() => _isHoveringPurple = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: _isHoveringPurple
                        ? (Matrix4.identity()..scale(1.3))
                        : Matrix4.identity(),
                    child: IconButton(
                      icon: Icon(Icons.circle, color: Colors.purple[700]),
                      iconSize: 32,
                      onPressed: () {
                        setState(() {
                          _selectedColorMode = DSColorMode.purple;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Eraser
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringEraser = true),
                  onExit: (_) => setState(() => _isHoveringEraser = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: _isHoveringEraser
                        ? (Matrix4.identity()..scale(1.3))
                        : Matrix4.identity(),
                    child: IconButton(
                      icon: const Icon(Icons.cleaning_services),
                      iconSize: 32,
                      onPressed: () {
                        setState(() {
                          _selectedColorMode = DSColorMode.eraser;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Undo / Redo / Clear
  // ----------------------------
  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _redoStrokes.add(_strokes.removeLast());
      });
    }
  }

  void _redo() {
    if (_redoStrokes.isNotEmpty) {
      setState(() {
        _strokes.add(_redoStrokes.removeLast());
      });
    }
  }

  void _clearAll() {
    setState(() {
      _strokes.clear();
      _redoStrokes.clear();
      _activeStroke = null;
    });
  }

  // ----------------------------
  // Stroke Lifecycle
  // ----------------------------
  void _startStroke(Offset position) {
    _redoStrokes.clear();
    setState(() {
      _activeStroke = DSStroke(
        points: [position],
        colorMode: _selectedColorMode,
      );
    });
  }

  void _updateStroke(Offset position) {
    if (_activeStroke == null) return;
    setState(() {
      _activeStroke!.points.add(position);
    });
  }

  void _endStroke() {
    if (_activeStroke != null) {
      setState(() {
        _strokes.add(_activeStroke!);
        _activeStroke = null;
      });
    }
  }

  // ----------------------------
  // Pen Icon
  // ----------------------------
  Widget _buildCustomPenIcon() {
    const double iconSize = 24;
    switch (_selectedColorMode) {
      case DSColorMode.pink:
        return Icon(Icons.create, color: Colors.pink, size: iconSize);

      case DSColorMode.rainbow:
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) {
            return const SweepGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
                Colors.red,
              ],
            ).createShader(bounds);
          },
          child: const Icon(Icons.create, size: iconSize),
        );

      case DSColorMode.purple:
        return Icon(Icons.create, color: Colors.purple, size: iconSize);

      case DSColorMode.eraser:
        return const Icon(Icons.cleaning_services, color: Colors.grey, size: iconSize);
    }
  }
}

// --------------------------------------------------------------------------
// 1) Painter for the faint shape in the background
// --------------------------------------------------------------------------
class _BackgroundShapePainter extends CustomPainter {
  final String shapeName;
  final Color shapeColor;
  final String dimension;

  const _BackgroundShapePainter({
    required this.shapeName,
    required this.shapeColor,
    required this.dimension,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // We'll draw the shape with some alpha to make it faint
    final faintPaint = Paint()
      ..color = shapeColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    switch (dimension) {
      case '1D':
        _draw1DShape(canvas, size, shapeName, faintPaint);
        break;
      case '2D':
        _draw2DShape(canvas, size, shapeName, faintPaint);
        break;
      case '3D':
        _draw3DShape(canvas, size, shapeName, faintPaint);
        break;
      default:
        break;
    }
  }

  void _draw1DShape(Canvas canvas, Size size, String shapeName, Paint paint) {
    final centerY = size.height * 0.5;
    // We'll just draw these as lines or simple shapes

    if (shapeName == 'Line') {
      // A line across the entire width
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 8;
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        paint,
      );
    } else if (shapeName == 'Ray') {
      // A line from left -> center
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 8;
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width * 0.5, centerY),
        paint,
      );
      // we can add an arrow, but let's keep it simple
    } else if (shapeName == 'Line Segment') {
      // A line in the center portion
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 8;
      canvas.drawLine(
        Offset(size.width * 0.3, centerY),
        Offset(size.width * 0.7, centerY),
        paint,
      );
    }
  }

  void _draw2DShape(Canvas canvas, Size size, String shapeName, Paint paint) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    if (shapeName == 'Circle') {
      // draw a circle in the center
      final radius = size.shortestSide * 0.3;
      canvas.drawCircle(center, radius, paint);

    } else if (shapeName == 'Square') {
      // draw a square centered
      final side = size.shortestSide * 0.5;
      final rect = Rect.fromCenter(
        center: center,
        width: side,
        height: side,
      );
      canvas.drawRect(rect, paint);

    } else if (shapeName == 'Triangle') {
      // draw an equilateral triangle
      final side = size.shortestSide * 0.5;
      final path = Path();
      final half = side / 2;
      // The center is near the middle
      path.moveTo(center.dx, center.dy - half); // top
      path.lineTo(center.dx - half, center.dy + half);
      path.lineTo(center.dx + half, center.dy + half);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _draw3DShape(Canvas canvas, Size size, String shapeName, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);

    if (shapeName == 'Sphere') {
      // draw a circle to represent a sphere
      final radius = size.shortestSide * 0.3;
      canvas.drawCircle(center, radius, paint);

    } else if (shapeName == 'Cube') {
      // a simple 2D "cube" wireframe
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 6;

      final cubeSize = size.shortestSide * 0.25;
      final offset = cubeSize * 0.5;

      // front square
      final frontRect = Rect.fromCenter(
        center: center,
        width: cubeSize,
        height: cubeSize,
      );
      canvas.drawRect(frontRect, paint);

      // "behind" offset
      final behindCenter = center.translate(offset, -offset);
      final behindRect = Rect.fromCenter(
        center: behindCenter,
        width: cubeSize,
        height: cubeSize,
      );
      canvas.drawRect(behindRect, paint);

      // Connect edges
      canvas.drawLine(
        frontRect.topLeft, behindRect.topLeft, paint,
      );
      canvas.drawLine(
        frontRect.topRight, behindRect.topRight, paint,
      );
      canvas.drawLine(
        frontRect.bottomLeft, behindRect.bottomLeft, paint,
      );
      canvas.drawLine(
        frontRect.bottomRight, behindRect.bottomRight, paint,
      );

    } else if (shapeName == 'Cylinder') {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 6;

      // top ellipse
      final topRect = Rect.fromCenter(
        center: center.translate(0, -50),
        width: size.shortestSide * 0.4,
        height: 40,
      );
      canvas.drawOval(topRect, paint);

      // bottom ellipse
      final bottomRect = Rect.fromCenter(
        center: center.translate(0, 50),
        width: size.shortestSide * 0.4,
        height: 40,
      );
      canvas.drawOval(bottomRect, paint);

      // vertical lines
      canvas.drawLine(
        topRect.bottomLeft.translate(0, 0),
        bottomRect.topLeft.translate(0, 0),
        paint,
      );
      canvas.drawLine(
        topRect.bottomRight.translate(0, 0),
        bottomRect.topRight.translate(0, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BackgroundShapePainter oldDelegate) => false;
}

// --------------------------------------------------------------------------
// 2) The user's strokes painter
// --------------------------------------------------------------------------
class _DSTracingPainter extends CustomPainter {
  final List<DSStroke> strokes;
  final DSStroke? activeStroke;

  _DSTracingPainter(this.strokes, this.activeStroke);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    // paint existing strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // paint the active stroke
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }

    canvas.restore();
  }

  void _drawStroke(Canvas canvas, DSStroke stroke) {
    for (int i = 0; i < stroke.points.length - 1; i++) {
      final p1 = stroke.points[i];
      final p2 = stroke.points[i + 1];
      if ((p2 - p1).distance > 50) continue;

      final paintLine = Paint()
        ..strokeWidth = (stroke.colorMode == DSColorMode.eraser) ? 30 : 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (stroke.colorMode == DSColorMode.eraser) {
        paintLine.blendMode = BlendMode.clear;
      } else {
        paintLine.blendMode = BlendMode.srcOver;
      }

      // color?
      switch (stroke.colorMode) {
        case DSColorMode.pink:
          paintLine.color = Colors.pink;
          break;
        case DSColorMode.rainbow:
          final rainbowColors = [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple,
          ];
          final colorIndex = i % rainbowColors.length;
          paintLine.color = rainbowColors[colorIndex];
          break;
        case DSColorMode.purple:
          paintLine.color = Colors.purple;
          break;
        case DSColorMode.eraser:
          // no color needed
          break;
      }

      canvas.drawLine(p1, p2, paintLine);
    }
  }

  @override
  bool shouldRepaint(_DSTracingPainter oldDelegate) => true;
}

// --------------------------------------------------------------------------
// 3) A painter for the "rainbow" color button
// --------------------------------------------------------------------------
class _RainbowCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = SweepGradient(
      colors: [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
        Colors.red, // loop
      ],
      startAngle: 0.0,
      endAngle: 2 * 3.141592653589793,
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RainbowCirclePainter oldDelegate) => false;
}
