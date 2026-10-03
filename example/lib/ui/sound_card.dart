import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sound_library/sound_library.dart';

import '../style.dart';

const Map<Sounds, IconData> _icons = {
  Sounds.click: Icons.ads_click_rounded,
  Sounds.tap: Icons.touch_app_rounded,
  Sounds.bip: Icons.qr_code_scanner_rounded,
  Sounds.drag: Icons.open_with_rounded,
  Sounds.popIn: Icons.add_comment_rounded,
  Sounds.popOut: Icons.comments_disabled_rounded,
  Sounds.action: Icons.bolt_rounded,
  Sounds.open: Icons.menu_open_rounded,
  Sounds.woodHit: Icons.close_fullscreen_rounded,
  Sounds.openPage: Icons.arrow_forward_rounded,
  Sounds.closePage: Icons.arrow_back_rounded,
  Sounds.openPanel: Icons.view_sidebar_rounded,
  Sounds.closePanel: Icons.view_sidebar_outlined,
  Sounds.success: Icons.check_circle_rounded,
  Sounds.deleted: Icons.delete_rounded,
  Sounds.remove: Icons.backspace_rounded,
  Sounds.glass: Icons.notifications_active_rounded,
  Sounds.addToCart: Icons.add_shopping_cart_rounded,
  Sounds.orderComplete: Icons.inventory_2_rounded,
  Sounds.cashingMachine: Icons.point_of_sale_rounded,
  Sounds.intro: Icons.rocket_launch_rounded,
  Sounds.introShort: Icons.flash_on_rounded,
  Sounds.welcome: Icons.waving_hand_rounded,
};

const Map<SoundCategory, Gradient> _gradients = {
  SoundCategory.interaction: MisGradients.primary,
  SoundCategory.navigation: MisGradients.tertiary,
  SoundCategory.feedback: MisGradients.secondary,
  SoundCategory.commerce: LinearGradient(colors: [MisColors.yellow, MisColors.green]),
  SoundCategory.brand: LinearGradient(colors: [MisColors.magenta, MisColors.lightBlue]),
};

Gradient gradientOf(SoundCategory category) => _gradients[category]!;

IconData iconOf(SoundCategory category) => switch (category) {
      SoundCategory.interaction => Icons.touch_app_rounded,
      SoundCategory.navigation => Icons.explore_rounded,
      SoundCategory.feedback => Icons.notifications_rounded,
      SoundCategory.commerce => Icons.shopping_bag_rounded,
      SoundCategory.brand => Icons.auto_awesome_rounded,
    };

/// A tappable card that plays [sound] locally. The code snippet copies `Sounds.<name>` to the clipboard.
class SoundCard extends StatefulWidget {
  const SoundCard({super.key, required this.sound, required this.volume});

  final Sounds sound;
  final double volume;

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard> {
  bool _hovered = false;
  bool _playing = false;
  Timer? _reset;

  Gradient get _gradient => gradientOf(widget.sound.category);

  Future<void> _play() async {
    setState(() => _playing = true);
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _playing = false);
    });
    await SoundPlayer.play(widget.sound, volume: widget.volume);
  }

  Future<void> _copy() async {
    final code = 'Sounds.${widget.sound.name}';
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 280,
          backgroundColor: MisColors.lightBlue800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          duration: const Duration(seconds: 2),
          content: Text('Copied $code', textAlign: TextAlign.center, style: misText(14, weight: FontWeight.w600)),
        ),
      );
  }

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sound = widget.sound;
    final active = _hovered || _playing;
    return Semantics(
      button: true,
      label: 'Play ${sound.label}. ${sound.description}',
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _playing ? .97 : 1,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(active ? 1.5 : 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: active ? _gradient : null,
              color: active ? null : MisColors.lightBlue300.withValues(alpha: .18),
              boxShadow: _playing
                  ? [BoxShadow(color: MisColors.lightBlue.withValues(alpha: .45), blurRadius: 30, spreadRadius: 1)]
                  : const [],
            ),
            child: Material(
              color: Color.alphaBlend(MisColors.lightBlue800.withValues(alpha: .75), MisColors.darkBackground),
              borderRadius: BorderRadius.circular(23),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _play,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _IconBadge(icon: _icons[sound]!, gradient: _gradient, playing: _playing),
                          const Spacer(),
                          Icon(
                            _playing ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                            color: active ? Colors.white : MisColors.blue300,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(sound.label, style: misText(18, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          sound.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: misText(13, color: MisColors.grey, height: 1.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Tooltip(
                        message: 'Copy code',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: _copy,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Sounds.${sound.name}',
                                    overflow: TextOverflow.ellipsis,
                                    style: misText(
                                      12.5,
                                      weight: FontWeight.w600,
                                      color: MisColors.lightBlue300,
                                    ).copyWith(fontFamily: 'monospace', fontFamilyFallback: const ['Menlo', 'Courier']),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.copy_rounded, size: 14, color: MisColors.blue300),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.gradient, required this.playing});

  final IconData icon;
  final Gradient gradient;
  final bool playing;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: playing ? gradient : null,
          color: playing ? null : MisColors.darkBackground.withValues(alpha: .6),
          border: Border.all(color: MisColors.lightBlue300.withValues(alpha: playing ? 0 : .25)),
        ),
        child: Icon(icon, size: 22, color: playing ? MisColors.darkBackground : Colors.white),
      );
}
