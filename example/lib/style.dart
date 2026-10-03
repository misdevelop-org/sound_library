import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens of the MIS design system (`mis_design_system`), copied here so this app only depends on
/// `sound_library` and does not pull the design system or its own dependencies.
class MisColors {
  static const Color blue = Color(0xFF272CA3);
  static const Color blue300 = Color(0xFF9B9ECC);
  static const Color lightBlue = Color(0xFF6984E3);
  static const Color lightBlue50 = Color(0xFFDAE2FF);
  static const Color lightBlue200 = Color(0xFFC6D2FF);
  static const Color lightBlue300 = Color(0xFFA9BCFF);
  static const Color lightBlue800 = Color(0xFF252644);
  static const Color yellow = Color(0xFFF9DE54);
  static const Color green = Color(0xFF5BE271);
  static const Color magenta = Color(0xFFF231F6);
  static const Color darkBackground = Color(0xFF07081C);
  static const Color grey = Color(0xFFC2C5FF);
}

class MisGradients {
  static const List<double> _stops = [0, .5, 1];

  /// Green, light blue and magenta: the signature gradient of MIS.
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MisColors.green, MisColors.lightBlue, MisColors.magenta],
    stops: _stops,
  );

  static const LinearGradient primaryHorizontal = LinearGradient(
    colors: [MisColors.green, MisColors.lightBlue, MisColors.magenta],
    stops: _stops,
  );

  /// Light blue, green and yellow.
  static const LinearGradient secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MisColors.lightBlue, MisColors.green, MisColors.yellow],
    stops: _stops,
  );

  /// Blue, light blue and green.
  static const LinearGradient tertiary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MisColors.blue, MisColors.lightBlue, MisColors.green],
    stops: _stops,
  );
}

/// The design system uses Karla, light, with a letter spacing of 0.5.
TextStyle misText(double size, {FontWeight weight = FontWeight.w300, Color color = Colors.white, double? height}) =>
    GoogleFonts.karla(fontSize: size, fontWeight: weight, color: color, letterSpacing: .5, height: height);

ThemeData misTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: MisColors.blue,
    brightness: Brightness.dark,
    surface: MisColors.darkBackground,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MisColors.darkBackground,
    splashFactory: InkSparkle.splashFactory,
  );
}

/// Text painted with a gradient.
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style, this.gradient = MisGradients.primaryHorizontal});

  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
        child: Text(text, style: style),
      );
}
