import 'package:flutter/material.dart';

/// Now we have four modes, including 'eraser'.
enum DrawingColorMode {
  pink,
  rainbow,
  purple,
  eraser,
}

/// A Stroke holds the points and the chosen color/eraser mode.
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
  /// List of completed strokes
  final List<Stroke> _strokes = [];

  /// The stroke currently being drawn
  Stroke? _activeStroke;

  /// Current color mode for new strokes (default to pink)
  DrawingColorMode _selectedColorMode = DrawingColorMode.pink;

  /// Hover flags for each icon
  bool _isHoveringPink = false;
  bool _isHoveringRainbow = false;
  bool _isHoveringPurple = false;
  bool _isHoveringEraser = false;

  /// Track cursor position to show custom "pen" icon
  Offset? _cursorPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IMPORTANT: Use a background color here, so the eraser will reveal this color
      // rather than painting white.
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tracing Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _strokes.clear();
                _activeStroke = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // The drawing area
          Expanded(
            child: MouseRegion(
              // Hide the system cursor so we can show our own icon
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
                    // 1) CustomPaint for strokes
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TracingPainter(_strokes, _activeStroke),
                        child: Container(), // Just fills the area
                      ),
                    ),
                    // 2) Our custom pen / eraser icon under the pointer
                    if (_cursorPosition != null)
                      Positioned(
                        left: _cursorPosition!.dx,
                        top: _cursorPosition!.dy,
                        // Shift left/up so the icon tip appears under pointer
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

          // The color and eraser selection row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ---------------------
                // PINK ICON
                // ---------------------
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

                // ---------------------
                // RAINBOW ICON
                // ---------------------
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

                // ---------------------
                // PURPLE ICON
                // ---------------------
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

                // ---------------------
                // ERASER ICON
                // ---------------------
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
          )
        ],
      ),
    );
  }

  // Called when user first touches the screen
  void _startStroke(Offset position) {
    setState(() {
      _activeStroke = Stroke(
        points: [position],
        colorMode: _selectedColorMode,
      );
    });
  }

  // Called while the user moves mouse/finger
  void _updateStroke(Offset position) {
    if (_activeStroke == null) return;
    setState(() {
      _activeStroke!.points.add(position);
    });
  }

  // Called when user lifts up
  void _endStroke() {
    if (_activeStroke != null) {
      setState(() {
        _strokes.add(_activeStroke!);
        _activeStroke = null;
      });
    }
  }

  /// Builds the pen/eraser icon under the pointer
  Widget _buildCustomPenIcon() {
    const double iconSize = 24;

    switch (_selectedColorMode) {
      case DrawingColorMode.pink:
        return Icon(Icons.create, color: Colors.pink, size: iconSize);

      case DrawingColorMode.purple:
        return Icon(Icons.create, color: Colors.purple, size: iconSize);

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

      case DrawingColorMode.eraser:
        return const Icon(
          Icons.cleaning_services,
          color: Colors.grey,
          size: iconSize,
        );
    }
  }
}

/// CustomPainter that can paint normal strokes (pink/rainbow/purple)
/// or 'eraser' strokes using BlendMode.clear to remove previously drawn paint.
class _TracingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? activeStroke;

  _TracingPainter(this.strokes, this.activeStroke);

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Create a new layer so "clear" blend mode will actually erase
    canvas.saveLayer(Offset.zero & size, Paint());

    // 2) Draw all the completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // 3) Draw the active stroke (user is in the middle of drawing)
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }

    // 4) Finalize the layer
    canvas.restore();
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    final points = stroke.points;

    // We'll iterate through pairs of consecutive points
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // If there's a big jump, skip it
      if ((p2 - p1).distance > 50) continue;

      final linePaint = Paint()
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (stroke.colorMode == DrawingColorMode.eraser) {
        // Use blendMode.clear to remove existing paint from the layer
        linePaint.blendMode = BlendMode.clear;
        // You can also adjust strokeWidth for the eraser if you want it bigger
      } else {
        // Normal painting
        linePaint.blendMode = BlendMode.srcOver;

        switch (stroke.colorMode) {
          case DrawingColorMode.pink:
            linePaint.color = Colors.pink;
            break;
          case DrawingColorMode.rainbow:
            // Cycle through rainbow colors for each segment
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
            // Handled above
            break;
        }
      }

      // Draw the line segment
      canvas.drawLine(p1, p2, linePaint);
    }
  }

  @override
  bool shouldRepaint(_TracingPainter oldDelegate) => true;
}

/// Example of a rainbow circle widget. We use it as an icon for rainbow mode.
class RainbowIconButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const RainbowIconButton({Key? key, required this.size, required this.onTap})
      : super(key: key);

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
      tileMode: TileMode.clamp,
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RainbowCirclePainter oldDelegate) => false;
}
