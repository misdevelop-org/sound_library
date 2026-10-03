import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../style.dart';

/// Lets the rest of the page talk to the [Backdrop]: where the mouse is, and when a sound plays.
class BackdropController {
  /// Where the mouse is, in global coordinates, or null when it is away or the device has no cursor.
  Offset? pointer;

  final List<_Pulse> _pulses = [];

  /// Sends a ripple out from [origin] (global coordinates). The shapes around it get pushed as it passes.
  void pulse(Offset origin, List<Color> colors) =>
      _pulses.add(_Pulse(origin, colors.isEmpty ? [MisColors.lightBlue] : colors));
}

/// Gives descendants access to the [BackdropController].
class BackdropScope extends InheritedWidget {
  const BackdropScope({super.key, required this.controller, required super.child});

  final BackdropController controller;

  static BackdropController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BackdropScope>()?.controller;

  @override
  bool updateShouldNotify(BackdropScope oldWidget) => controller != oldWidget.controller;
}

/// Animated background made of layers at different distances.
///
/// Far layers are small, dim and blurred, near layers are larger and sharper. They drift on their own, slide at
/// different speeds when the page scrolls and when the mouse moves (parallax), get pulled toward the cursor like a
/// magnet, and are pushed by the ripple of every sound that plays. Everything stays still when the system asks to
/// reduce motion.
class Backdrop extends StatefulWidget {
  const Backdrop({super.key, required this.controller, this.scroll});

  final BackdropController controller;

  /// The page scroll, to slide the layers while scrolling.
  final ScrollController? scroll;

  @override
  State<Backdrop> createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop> with SingleTickerProviderStateMixin {
  final _frame = _Frame();
  late final Ticker _ticker = createTicker(_tick);
  final List<_Body> _bodies = [for (final _ in _shapes) _Body()];

  Duration _last = Duration.zero;
  double _time = 0;
  Size _size = Size.zero;
  Offset _parallax = Offset.zero;
  double _scroll = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ticker.stop();
      _last = Duration.zero;
      _frame.tick();
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero ? 0.016 : math.min((elapsed - _last).inMicroseconds / 1e6, .05);
    _last = elapsed;
    _time += dt;
    if (_size.isEmpty) return;

    final box = context.findRenderObject() as RenderBox?;
    final global = widget.controller.pointer;
    final pointer = box != null && box.attached && global != null ? box.globalToLocal(global) : null;
    final scroll = widget.scroll != null && widget.scroll!.hasClients ? widget.scroll!.offset : 0.0;
    _scroll += (scroll - _scroll) * math.min(1, dt * 8);

    // Where the mouse is relative to the middle of the page, from -1 to 1, smoothed, for the parallax.
    final aim = pointer == null
        ? Offset.zero
        : Offset(
            ((pointer.dx / _size.width) * 2 - 1).clamp(-1.0, 1.0),
            ((pointer.dy / _size.height) * 2 - 1).clamp(-1.0, 1.0),
          );
    _parallax += (aim - _parallax) * math.min(1, dt * 3);

    final pulses = widget.controller._pulses..removeWhere((pulse) => pulse.age(_time) > _Pulse.life);
    for (final pulse in pulses) {
      pulse.start ??= _time;
      pulse.local ??= box != null && box.attached ? box.globalToLocal(pulse.origin) : _size.center(Offset.zero);
    }

    for (var i = 0; i < _shapes.length; i++) {
      final shape = _shapes[i];
      final body = _bodies[i];
      final home = _home(shape, _size, _time, _scroll, _parallax);

      var target = Offset.zero;
      // Magnet: the closer the cursor, the stronger the pull. Near layers are pulled harder.
      if (pointer != null) {
        final reach = 120 + 150 * shape.depth;
        final delta = pointer - home;
        final distance = delta.distance;
        if (distance < reach && distance > 1) {
          final strength = math.pow(1 - distance / reach, 1.4).toDouble();
          target += delta / distance * (strength * (18 + 46 * shape.depth));
        }
      }
      // Ripples: the shapes the wave is passing through get pushed away from where the sound played.
      for (final pulse in pulses) {
        final delta = home - pulse.local!;
        final distance = math.max(delta.distance, 1.0);
        final off = (distance - pulse.radius(_time)) / 70;
        final push = math.exp(-off * off) * (1 - pulse.age(_time) / _Pulse.life);
        target += delta / distance * (push * (28 + 36 * shape.depth));
      }

      // A spring that follows the target with a little overshoot, so movement feels physical.
      const stiffness = 90.0, damping = 11.0;
      body.velocity += ((target - body.offset) * stiffness - body.velocity * damping) * dt;
      body.offset += body.velocity * dt;
    }
    _frame.tick();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _size = constraints.biggest;
            return CustomPaint(
              painter: _BackdropPainter(
                _frame,
                dark: dark,
                glow: context.mis.glow,
                still: reduceMotion,
                state: this,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

/// Repaints the painter on every tick.
class _Frame extends ChangeNotifier {
  void tick() => notifyListeners();
}

/// A ripple that expands from where a sound was played.
class _Pulse {
  _Pulse(this.origin, this.colors);

  static const life = 1.4;
  static const speed = 560.0;

  final Offset origin;
  final List<Color> colors;
  Offset? local;
  double? start;

  double age(double now) => start == null ? 0 : now - start!;
  double radius(double now) => age(now) * speed;
}

/// The springy displacement of one shape.
class _Body {
  Offset offset = Offset.zero;
  Offset velocity = Offset.zero;
}

enum _Kind { ring, square, triangle, cross, dot, bars }

class _Shape {
  const _Shape(this.kind, this.x, this.y, this.size, this.color, this.cycles, this.phase, this.depth);

  final _Kind kind;

  /// Resting position, from 0 to 1 of the page.
  final double x, y;
  final double size;
  final Color color;

  /// Speed of the idle drift, in whole turns every 90 seconds.
  final int cycles;
  final double phase;

  /// How far away the layer is: 0.2 is the farthest, 1 the nearest.
  final double depth;
}

const _palette = [MisColors.green, MisColors.lightBlue, MisColors.magenta, MisColors.yellow];

/// Sorted from the farthest to the nearest, so near shapes are painted over far ones.
final List<_Shape> _shapes = () {
  final random = math.Random(11);
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
    _Kind.triangle,
    _Kind.square,
    _Kind.bars,
    _Kind.dot,
    _Kind.ring,
    _Kind.cross,
  ];
  final shapes = [
    for (var i = 0; i < kinds.length; i++)
      () {
        final depth = .2 + .8 * random.nextDouble();
        return _Shape(
          kinds[i],
          // A loose grid, so shapes spread across the page instead of clumping.
          ((i % 6) + .2 + random.nextDouble() * .6) / 6,
          ((i ~/ 6) + .1 + random.nextDouble() * .8) / 4,
          (22 + random.nextDouble() * 34) * (.55 + .7 * depth),
          _palette[i % _palette.length],
          1 + random.nextInt(3),
          random.nextDouble() * math.pi * 2,
          depth,
        );
      }(),
  ];
  return shapes..sort((a, b) => a.depth.compareTo(b.depth));
}();

/// Where a shape rests right now, before the magnet and the ripples move it.
Offset _home(_Shape s, Size size, double time, double scroll, Offset parallax) {
  const margin = 80.0;
  final wave = time / 90 * math.pi * 2 * s.cycles + s.phase;
  final x = (s.x + .025 * math.sin(wave)) * size.width - parallax.dx * 34 * s.depth;
  var y = (s.y + .04 * math.cos(wave)) * size.height - parallax.dy * 22 * s.depth - scroll * .28 * s.depth;
  // Shapes that scroll out of the top come back in from the bottom.
  final span = size.height + margin * 2;
  y = ((y + margin) % span + span) % span - margin;
  return Offset(x, y);
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.frame, {required this.dark, required this.glow, required this.still, required this.state})
      : super(repaint: frame);

  final _Frame frame;
  final bool dark;
  final double glow;
  final bool still;
  final _BackdropState state;

  @override
  void paint(Canvas canvas, Size size) {
    final time = state._time;
    _glows(canvas, size, time / 90 * math.pi * 2);
    for (var i = 0; i < _shapes.length; i++) {
      final shape = _shapes[i];
      final center = _home(shape, size, time, still ? 0 : state._scroll, still ? Offset.zero : state._parallax) +
          (still ? Offset.zero : state._bodies[i].offset);
      _shape(canvas, shape, center, time);
    }
    for (final pulse in state.widget.controller._pulses) {
      _pulse(canvas, pulse, time);
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
    final p = still ? Offset.zero : state._parallax;
    blob(Offset(w * (.0 + .06 * math.sin(t)) - p.dx * 12, h * (.0 + .05 * math.cos(t)) - p.dy * 8), 420, MisColors.blue,
        .55);
    blob(Offset(w * (1 + .05 * math.cos(t * 2)) - p.dx * 18, h * (.3 + .06 * math.sin(t * 2)) - p.dy * 12), 340,
        MisColors.magenta, .18);
    blob(Offset(w * (.2 + .06 * math.sin(t * 3)) - p.dx * 24, h * (1 + .04 * math.cos(t)) - p.dy * 16), 380,
        MisColors.green, .14);
    blob(Offset(w * (.75 + .05 * math.sin(t)) - p.dx * 30, h * (.65 + .05 * math.sin(t * 2)) - p.dy * 20), 260,
        MisColors.lightBlue, .12);
  }

  void _pulse(Canvas canvas, _Pulse pulse, double time) {
    if (pulse.start == null || pulse.local == null) return;
    final age = pulse.age(time);
    final fade = (1 - age / _Pulse.life).clamp(0.0, 1.0);
    for (var ring = 0; ring < 2; ring++) {
      final radius = pulse.radius(time) - ring * 70;
      if (radius <= 0) continue;
      final color = pulse.colors[ring % pulse.colors.length];
      canvas.drawCircle(
        pulse.local!,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 - ring
          ..color = (dark ? color : Color.lerp(color, MisColors.blue, .4)!)
              .withValues(alpha: fade * fade * (dark ? .5 : .35)),
      );
    }
  }

  void _shape(Canvas canvas, _Shape s, Offset center, double time) {
    final wave = time / 90 * math.pi * 2 * s.cycles + s.phase;
    // Far layers are dimmer and slightly blurred, like depth of field.
    final alpha = (dark ? .55 : .36) * (.4 + .6 * s.depth);
    final color = dark ? s.color : Color.lerp(s.color, MisColors.blue, .45)!;
    final blur = (1 - s.depth) * 2.2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 + 1.2 * s.depth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: alpha);
    final fill = Paint()..color = color.withValues(alpha: alpha * .8);
    if (blur > .4) {
      final filter = MaskFilter.blur(BlurStyle.normal, blur);
      stroke.maskFilter = filter;
      fill.maskFilter = filter;
    }
    final r = s.size / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(wave * (s.cycles.isEven ? 1 : -1) * .5);
    switch (s.kind) {
      case _Kind.ring:
        // Breathes, like a ripple of sound.
        final pulse = 1 + .12 * math.sin(time / 90 * math.pi * 2 * s.cycles * 2 + s.phase);
        canvas.drawCircle(Offset.zero, r * pulse, stroke);
        canvas.drawCircle(
            Offset.zero,
            r * pulse * .55,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = stroke.strokeWidth
              ..maskFilter = stroke.maskFilter
              ..color = color.withValues(alpha: alpha * .6));
      case _Kind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCircle(center: Offset.zero, radius: r), Radius.circular(r * .3)),
          stroke,
        );
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
          final height =
              r * (.5 + .5 * (.5 + .5 * math.sin(time / 90 * math.pi * 2 * (s.cycles * 30) + i * 1.3 + s.phase)));
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
  bool shouldRepaint(_BackdropPainter old) => old.dark != dark || old.glow != glow || old.still != still;
}
