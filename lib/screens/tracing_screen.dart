import 'package:flutter/material.dart';

enum DrawingColorMode {
  pink,
  rainbow,
  purple,
  eraser,
}

class Stroke {
  final List<Offset> points;
  final DrawingColorMode colorMode;

  Stroke({
    required this.points,
    required this.colorMode,
  });
}

class TracingScreen extends StatefulWidget {
  const TracingScreen({Key? key}) : super(key: key);

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  /// The main list of completed strokes
  final List<Stroke> _strokes = [];

  /// A stack of “undone” strokes for Redo
  final List<Stroke> _redoStrokes = [];

  /// The stroke currently being drawn
  Stroke? _activeStroke;

  /// Currently selected drawing mode (pen/eraser)
  DrawingColorMode _selectedColorMode = DrawingColorMode.pink;

  /// Hover flags for each icon
  bool _isHoveringPink = false;
  bool _isHoveringRainbow = false;
  bool _isHoveringPurple = false;
  bool _isHoveringEraser = false;

  /// Track cursor position to show a custom icon under the pointer
  Offset? _cursorPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a background color at the Scaffold level
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tracing Screen'),
        actions: [
          // UNDO button
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undo,
          ),

          // REDO button
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _redo,
          ),

          // CLEAR button
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearAll,
          ),
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
                    // CustomPaint for strokes
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TracingPainter(_strokes, _activeStroke),
                        child: Container(),
                      ),
                    ),

                    // Custom pen/eraser icon under the pointer
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

          // The toolbar for color/eraser selection
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
                          _selectedColorMode = DrawingColorMode.pink;
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
                          _selectedColorMode = DrawingColorMode.rainbow;
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
                          _selectedColorMode = DrawingColorMode.purple;
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
                          _selectedColorMode = DrawingColorMode.eraser;
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

  // ---------- Undo, Redo, and Clear ----------

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

  // ---------- Stroke Lifecycle ----------

  void _startStroke(Offset position) {
    setState(() {
      // If the user starts drawing after an Undo, we can't redo older strokes
      _redoStrokes.clear();

      _activeStroke = Stroke(
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
        // Once the user finishes drawing, add the stroke to the list
        _strokes.add(_activeStroke!);
        _activeStroke = null;
      });
    }
  }

  // ---------- Custom Pen / Eraser Cursor Icon ----------

  Widget _buildCustomPenIcon() {
    const double iconSize = 24;

    switch (_selectedColorMode) {
      case DrawingColorMode.pink:
        return Icon(Icons.create, color: Colors.pink, size: iconSize);

      case DrawingColorMode.rainbow:
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

      case DrawingColorMode.purple:
        return Icon(Icons.create, color: Colors.purple, size: iconSize);

      case DrawingColorMode.eraser:
        return const Icon(Icons.cleaning_services, color: Colors.grey, size: iconSize);
    }
  }
}

// ---------- CustomPainter Implementation for True Eraser ----------

class _TracingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? activeStroke;

  _TracingPainter(this.strokes, this.activeStroke);

  @override
  void paint(Canvas canvas, Size size) {
    // We paint onto an offscreen layer so BlendMode.clear can erase.
    canvas.saveLayer(Offset.zero & size, Paint());

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }

    canvas.restore();
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    final points = stroke.points;
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // If there's a big jump, skip
      if ((p2 - p1).distance > 50) continue;

      final linePaint = Paint()
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Eraser uses BlendMode.clear to remove existing paint
      if (stroke.colorMode == DrawingColorMode.eraser) {
        linePaint.blendMode = BlendMode.clear;
      } else {
        // Normal stroke
        linePaint.blendMode = BlendMode.srcOver;
      }

      // Set color if needed
      switch (stroke.colorMode) {
        case DrawingColorMode.pink:
          linePaint.color = Colors.pink;
          break;
        case DrawingColorMode.rainbow:
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
          linePaint.color = rainbowColors[colorIndex];
          break;
        case DrawingColorMode.purple:
          linePaint.color = Colors.purple;
          break;
        case DrawingColorMode.eraser:
          // No color needed, since blendMode.clear is used
          break;
      }

      canvas.drawLine(p1, p2, linePaint);
    }
  }

  @override
  bool shouldRepaint(_TracingPainter oldDelegate) => true;
}

// ---------- Optional: Rainbow Circle for the Rainbow Button ----------

class RainbowIconButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const RainbowIconButton({
    Key? key,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size.square(size),
        painter: _RainbowCirclePainter(),
      ),
    );
  }
}

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
