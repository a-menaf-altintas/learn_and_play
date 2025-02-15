import 'package:flutter/material.dart';

/// Three possible color modes
enum DrawingColorMode {
  pink,
  rainbow,
  purple,
}

/// Each stroke has its own list of points and a color mode.
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

  /// Current color mode for *new* strokes
  DrawingColorMode _selectedColorMode = DrawingColorMode.pink;

  /// Hover flags for each icon
  bool _isHoveringPink = false;
  bool _isHoveringRainbow = false;
  bool _isHoveringPurple = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) => _startStroke(event.localPosition),
              onPointerMove: (event) => _updateStroke(event.localPosition),
              onPointerUp: (event) => _endStroke(),
              child: CustomPaint(
                painter: _TracingPainter(_strokes, _activeStroke),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // The color selection row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PINK ICON
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isHoveringPink = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isHoveringPink = false;
                    });
                  },
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

                // RAINBOW ICON
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isHoveringRainbow = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isHoveringRainbow = false;
                    });
                  },
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

                // PURPLE ICON
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isHoveringPurple = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isHoveringPurple = false;
                    });
                  },
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
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Called when the user first touches the screen
  void _startStroke(Offset position) {
    setState(() {
      // Create a new Stroke with the current color mode
      _activeStroke = Stroke(
        points: [position],
        colorMode: _selectedColorMode,
      );
    });
  }

  /// Called when the user moves their finger/stylus/mouse
  void _updateStroke(Offset position) {
    if (_activeStroke == null) return; // Safety check
    setState(() {
      _activeStroke!.points.add(position);
    });
  }

  /// Called when the user lifts their finger
  void _endStroke() {
    if (_activeStroke != null) {
      setState(() {
        // Add the active stroke to the list of completed strokes
        _strokes.add(_activeStroke!);
        // Clear the active stroke
        _activeStroke = null;
      });
    }
  }
}

/// Painter that draws every stroke (with its color mode) plus the current stroke-in-progress.
class _TracingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? activeStroke;

  _TracingPainter(this.strokes, this.activeStroke);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    // Draw the active stroke if it exists
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }
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

      // Determine line color based on stroke's color mode
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
      }
      canvas.drawLine(p1, p2, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracingPainter oldDelegate) => true;
}

/// A simple widget that draws a circular rainbow icon with a custom painter.
/// Tapping on it triggers the `onTap` callback.
class RainbowIconButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const RainbowIconButton({Key? key, required this.size, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use InkWell or GestureDetector here
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

    // Create a rainbow gradient using SweepGradient
    final gradient = SweepGradient(
      colors: [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
        Colors.red, // loop back to red at the end
      ],
      startAngle: 0.0,
      endAngle: 2 * 3.141592653589793, // 2*pi
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
