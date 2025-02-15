import 'package:flutter/material.dart';

enum ShapeDrawingMode {
  pink,
  rainbow,
  purple,
  eraser,
}

class ShapeStroke {
  final List<Offset> points;
  final ShapeDrawingMode colorMode;

  ShapeStroke({
    required this.points,
    required this.colorMode,
  });
}

/// A tracing screen for shapes (1D,2D,3D).
/// Currently shows the shape name faintly in the background.
class ShapeTracingScreen extends StatefulWidget {
  final String shape;

  const ShapeTracingScreen({Key? key, required this.shape}) : super(key: key);

  @override
  State<ShapeTracingScreen> createState() => _ShapeTracingScreenState();
}

class _ShapeTracingScreenState extends State<ShapeTracingScreen> {
  final List<ShapeStroke> _strokes = [];
  final List<ShapeStroke> _redoStrokes = [];

  ShapeStroke? _activeStroke;
  ShapeDrawingMode _selectedColorMode = ShapeDrawingMode.pink;

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
        title: Text('Trace the Shape ${widget.shape}'),
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
                    // 1) Faint shape name
                    Center(
                      child: Opacity(
                        opacity: 0.15,
                        child: Text(
                          widget.shape,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // 2) Painted strokes
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ShapeTracingPainter(_strokes, _activeStroke),
                        child: Container(),
                      ),
                    ),

                    // 3) Custom pen icon
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

          // Bottom color row
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
                          _selectedColorMode = ShapeDrawingMode.pink;
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
                          _selectedColorMode = ShapeDrawingMode.rainbow;
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
                          _selectedColorMode = ShapeDrawingMode.purple;
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
                          _selectedColorMode = ShapeDrawingMode.eraser;
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

  // Undo/Redo/Clear
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

  // Stroke lifecycle
  void _startStroke(Offset position) {
    _redoStrokes.clear();
    setState(() {
      _activeStroke = ShapeStroke(
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

  Widget _buildCustomPenIcon() {
    const double iconSize = 24;
    switch (_selectedColorMode) {
      case ShapeDrawingMode.pink:
        return Icon(Icons.create, color: Colors.pink, size: iconSize);

      case ShapeDrawingMode.rainbow:
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

      case ShapeDrawingMode.purple:
        return Icon(Icons.create, color: Colors.purple, size: iconSize);

      case ShapeDrawingMode.eraser:
        return const Icon(Icons.cleaning_services, color: Colors.grey, size: iconSize);
    }
  }
}

/// Painter for shape strokes (with real erasing)
class _ShapeTracingPainter extends CustomPainter {
  final List<ShapeStroke> strokes;
  final ShapeStroke? activeStroke;

  _ShapeTracingPainter(this.strokes, this.activeStroke);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }

    canvas.restore();
  }

  void _drawStroke(Canvas canvas, ShapeStroke stroke) {
    final points = stroke.points;
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if ((p2 - p1).distance > 50) continue;

      final paintLine = Paint()
        ..strokeWidth = (stroke.colorMode == ShapeDrawingMode.eraser) ? 30 : 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (stroke.colorMode == ShapeDrawingMode.eraser) {
        paintLine.blendMode = BlendMode.clear;
      } else {
        paintLine.blendMode = BlendMode.srcOver;
      }

      switch (stroke.colorMode) {
        case ShapeDrawingMode.pink:
          paintLine.color = Colors.pink;
          break;
        case ShapeDrawingMode.rainbow:
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
        case ShapeDrawingMode.purple:
          paintLine.color = Colors.purple;
          break;
        case ShapeDrawingMode.eraser:
          // no color needed
          break;
      }
      canvas.drawLine(p1, p2, paintLine);
    }
  }

  @override
  bool shouldRepaint(_ShapeTracingPainter oldDelegate) => true;
}

/// The same rainbow painter for our "rainbow" icon
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
