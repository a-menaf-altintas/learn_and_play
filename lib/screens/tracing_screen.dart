import 'package:flutter/material.dart';

/// Drawing modes for our pen/eraser
enum DrawingColorMode {
  pink,
  rainbow,
  purple,
  eraser,
}

/// A single stroke of drawing
class Stroke {
  final List<Offset> points;
  final DrawingColorMode colorMode;

  Stroke({
    required this.points,
    required this.colorMode,
  });
}

/// The TracingScreen can do two things:
/// - letter == '' => free draw (no background letter)
/// - letter != '' => show a faint letter for tracing
class TracingScreen extends StatefulWidget {
  final String letter;

  const TracingScreen({
    Key? key,
    required this.letter,
  }) : super(key: key);

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  /// List of completed strokes
  final List<Stroke> _strokes = [];

  /// Undone strokes (for Redo)
  final List<Stroke> _redoStrokes = [];

  /// The stroke currently being drawn
  Stroke? _activeStroke;

  /// Currently selected drawing mode
  DrawingColorMode _selectedColorMode = DrawingColorMode.pink;

  /// Hover flags for color icons (for web/desktop)
  bool _isHoveringPink = false;
  bool _isHoveringRainbow = false;
  bool _isHoveringPurple = false;
  bool _isHoveringEraser = false;

  /// Track cursor position for our custom pen/eraser icon
  Offset? _cursorPosition;

  @override
  Widget build(BuildContext context) {
    // If letter is empty => "Free Draw"; else => "Trace the Letter X"
    final titleText = widget.letter.isEmpty
        ? 'Free Draw'
        : 'Trace the Letter ${widget.letter}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _redo,
          ),
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
                    // 1) Faint letter if we have a letter
                    if (widget.letter.isNotEmpty)
                      Center(
                        child: Opacity(
                          opacity: 0.15,
                          child: Text(
                            widget.letter,
                            style: const TextStyle(
                              fontSize: 300,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                    // 2) CustomPaint for strokes (draw or erase)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TracingPainter(_strokes, _activeStroke),
                        child: Container(),
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

          // Bottom toolbar for color / eraser
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

  // --- Undo / Redo / Clear ---
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

  // --- Stroke Lifecycle ---
  void _startStroke(Offset position) {
    // If user starts drawing after an Undo, remove redo stack
    _redoStrokes.clear();

    setState(() {
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
        _strokes.add(_activeStroke!);
        _activeStroke = null;
      });
    }
  }

  // --- Build Pen / Eraser Icon ---
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
                Colors.red, // loop
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

/// CustomPainter that supports real erasing (BlendMode.clear)
class _TracingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? activeStroke;

  _TracingPainter(this.strokes, this.activeStroke);

  @override
  void paint(Canvas canvas, Size size) {
    // Offscreen layer so eraser can remove paint
    canvas.saveLayer(Offset.zero & size, Paint());

    // Paint completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Paint stroke in progress
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
        // We make the eraser bigger for a stronger erase
        ..strokeWidth = (stroke.colorMode == DrawingColorMode.eraser) ? 30 : 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (stroke.colorMode == DrawingColorMode.eraser) {
        // Eraser "punches holes" in the paint
        linePaint.blendMode = BlendMode.clear;
      } else {
        linePaint.blendMode = BlendMode.srcOver;
      }

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
          // Clear blend mode, no color needed
          break;
      }

      canvas.drawLine(p1, p2, linePaint);
    }
  }

  @override
  bool shouldRepaint(_TracingPainter oldDelegate) => true;
}

/// Optional: Painted rainbow icon for the "rainbow" button
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
