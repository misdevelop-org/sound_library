import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../style.dart';

/// Animated background: drifting color glows with outlines of circles, squares, triangles and crosses floating over
/// them, and a few equalizer bars. Everything loops seamlessly every [_loop], and it stays still when the user asks
/// the system to reduce motion.
class Backdrop extends StatefulWidget {
  const Backdrop({super.key});

  @override
  State<Backdrop> createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop> with SingleTickerProviderStateMixin {
  static const _loop = Duration(seconds: 90);

  late final AnimationController _controller = AnimationController(vsync: this, duration: _loop);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BackdropPainter(_controller, dark: dark, glow: context.mis.glow),
          size: Size.infinite,
        ),
      ),
    );
  }
}

enum _Kind { ring, square, triangle, cross, dot, bars }

class _Shape {
  const _Shape(this.kind, this.x, this.y, this.size, this.color, this.cycles, this.phase);

  final _Kind kind;

  /// Resting position, from 0 to 1 of the page.
  final double x, y;
  final double size;
  final Color color;

  /// Whole number of drift cycles per loop, so the animation can repeat without a jump.
  final int cycles;
  final double phase;
}

const _palette = [MisColors.green, MisColors.lightBlue, MisColors.magenta, MisColors.yellow];

final List<_Shape> _shapes = () {
  final random = math.Random(7);
  const kinds = [
    _Kind.ring,
    _Kind.square,
    _Kind.triangle,
    _Kind.cross,
    _Kind.dot,
    _Kind.bars,
    _Kind.ring,
    _Kind.triangle,
    _Kind.square,
    _Kind.dot,
    _Kind.cross,
    _Kind.bars,
    _Kind.ring,
    _Kind.square,
    _Kind.triangle,
    _Kind.cross,
    _Kind.dot,
    _Kind.ring,
  ];
  return [
    for (var i = 0; i < kinds.length; i++)
      _Shape(
        kinds[i],
        // A loose grid, so shapes spread across the page instead of clumping.
        ((i % 6) + .2 + random.nextDouble() * .6) / 6,
        ((i ~/ 6) + .1 + random.nextDouble() * .8) / 3,
        26 + random.nextDouble() * 52,
        _palette[i % _palette.length],
        1 + random.nextInt(3),
        random.nextDouble() * math.pi * 2,
      ),
  ];
}();

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.animation, {required this.dark, required this.glow}) : super(repaint: animation);

  final Animation<double> animation;
  final bool dark;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * math.pi * 2;
    _glows(canvas, size, t);
    for (final shape in _shapes) {
      _shape(canvas, size, shape, t);
    }
  }

  void _glows(Canvas canvas, Size size, double t) {
    void blob(Offset center, double radius, Color color, double alpha) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: alpha * glow), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    final w = size.width, h = size.height;
    blob(Offset(w * (.0 + .06 * math.sin(t)), h * (.0 + .05 * math.cos(t))), 420, MisColors.blue, .55);
    blob(Offset(w * (1 + .05 * math.cos(t * 2)), h * (.3 + .06 * math.sin(t * 2))), 340, MisColors.magenta, .18);
    blob(Offset(w * (.2 + .06 * math.sin(t * 3)), h * (1 + .04 * math.cos(t))), 380, MisColors.green, .14);
    blob(Offset(w * (.75 + .05 * math.sin(t)), h * (.65 + .05 * math.sin(t * 2))), 260, MisColors.lightBlue, .12);
  }

  void _shape(Canvas canvas, Size size, _Shape s, double t) {
    final wave = t * s.cycles + s.phase;
    final center = Offset(
      (s.x + .025 * math.sin(wave)) * size.width,
      (s.y + .04 * math.cos(wave)) * size.height,
    );
    final alpha = dark ? .5 : .32;
    final color = dark ? s.color : Color.lerp(s.color, MisColors.blue, .45)!;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: alpha);
    final fill = Paint()..color = color.withValues(alpha: alpha * .8);
    final r = s.size / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(wave * (s.cycles.isEven ? 1 : -1) * .5);
    switch (s.kind) {
      case _Kind.ring:
        // Breathes, like a ripple of sound.
        final pulse = 1 + .12 * math.sin(t * s.cycles * 2 + s.phase);
        canvas.drawCircle(Offset.zero, r * pulse, stroke);
        canvas.drawCircle(Offset.zero, r * pulse * .55, stroke..color = color.withValues(alpha: alpha * .6));
      case _Kind.square:
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCircle(center: Offset.zero, radius: r), Radius.circular(r * .3)), stroke);
      case _Kind.triangle:
        final path = Path();
        for (var i = 0; i < 3; i++) {
          final a = -math.pi / 2 + i * math.pi * 2 / 3;
          final p = Offset(math.cos(a) * r * 1.1, math.sin(a) * r * 1.1);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path..close(), stroke);
      case _Kind.cross:
        canvas.drawLine(Offset(-r * .6, 0), Offset(r * .6, 0), stroke);
        canvas.drawLine(Offset(0, -r * .6), Offset(0, r * .6), stroke);
      case _Kind.dot:
        canvas.drawCircle(Offset.zero, r * .22, fill);
      case _Kind.bars:
        // Four equalizer bars that never rotate.
        canvas.rotate(-wave * (s.cycles.isEven ? 1 : -1) * .5);
        const count = 4;
        final barWidth = r * .22;
        for (var i = 0; i < count; i++) {
          final height = r * (.5 + .5 * (.5 + .5 * math.sin(t * (s.cycles * 8) + i * 1.3 + s.phase)));
          final x = (i - (count - 1) / 2) * barWidth * 1.7;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x, 0), width: barWidth, height: height * 1.4),
              Radius.circular(barWidth / 2),
            ),
            fill,
          );
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.dark != dark || old.glow != glow;
}
