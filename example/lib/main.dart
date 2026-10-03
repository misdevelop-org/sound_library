import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sound_library/sound_library.dart';
import 'package:url_launcher/url_launcher.dart';

import 'style.dart';
import 'ui/backdrop.dart';
import 'ui/sound_card.dart';

void main() {
  runApp(const SoundLibraryApp());
}

class SoundLibraryApp extends StatefulWidget {
  const SoundLibraryApp({super.key});

  @override
  State<SoundLibraryApp> createState() => _SoundLibraryAppState();
}

class _SoundLibraryAppState extends State<SoundLibraryApp> {
  /// Follows the system until the user picks a mode.
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sound Library by MIS Develop',
        debugShowCheckedModeBanner: false,
        theme: misTheme(Brightness.light),
        darkTheme: misTheme(Brightness.dark),
        themeMode: _mode,
        home: Builder(
          builder: (context) => SoundLibraryPage(
            onToggleTheme: () => setState(
              () => _mode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
            ),
          ),
        ),
      );
}

class SoundLibraryPage extends StatefulWidget {
  const SoundLibraryPage({super.key, required this.onToggleTheme});

  /// Switches between light and dark mode.
  final VoidCallback onToggleTheme;

  @override
  State<SoundLibraryPage> createState() => _SoundLibraryPageState();
}

class _SoundLibraryPageState extends State<SoundLibraryPage> {
  static const _installCommand = 'flutter pub add sound_library';

  final _searchController = TextEditingController();
  SoundCategory? _category;
  double _volume = 1;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    SoundPlayer.checkLocalStorageEnabled().then((enabled) {
      if (mounted) setState(() => _enabled = enabled);
    });
    // Decode every sound once so the first tap on a card has no delay.
    SoundPlayer.preload(Sounds.values);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _query => _searchController.text.trim().toLowerCase();

  List<Sounds> _visible(SoundCategory category) {
    if (_category != null && _category != category) return const [];
    return category.sounds
        .where(
          (sound) =>
              _query.isEmpty ||
              sound.label.toLowerCase().contains(_query) ||
              sound.description.toLowerCase().contains(_query) ||
              sound.name.toLowerCase().contains(_query),
        )
        .toList();
  }

  Future<void> _toggleSound() async {
    final enabled = !_enabled;
    setState(() => _enabled = enabled);
    await SoundPlayer.setAudioEnabled(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      for (final category in SoundCategory.values)
        if (_visible(category).isNotEmpty) (category: category, sounds: _visible(category)),
    ];
    final width = MediaQuery.sizeOf(context).width;
    final gutter = width < 600 ? 16.0 : 40.0;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Backdrop()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 32, gutter, 0),
                    sliver: SliverToBoxAdapter(child: _Header(installCommand: _installCommand)),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 32, gutter, 8),
                    sliver: SliverToBoxAdapter(
                      child: _Toolbar(
                        controller: _searchController,
                        onQueryChanged: () => setState(() {}),
                        category: _category,
                        onCategory: (category) => setState(() => _category = category),
                        volume: _volume,
                        onVolume: (value) => setState(() => _volume = value),
                        enabled: _enabled,
                        onToggleSound: _toggleSound,
                        onToggleTheme: widget.onToggleTheme,
                      ),
                    ),
                  ),
                  if (sections.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('No sounds match "${_searchController.text}"',
                            style: misText(18, color: context.mis.textMuted)),
                      ),
                    ),
                  for (final section in sections) ...[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 32, gutter, 14),
                      sliver: SliverToBoxAdapter(
                          child: _SectionTitle(category: section.category, count: section.sounds.length)),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: gutter),
                      sliver: SliverGrid.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 290,
                          mainAxisExtent: 196,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: section.sounds.length,
                        itemBuilder: (context, index) => SoundCard(sound: section.sounds[index], volume: _volume),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(child: _Footer(gutter: gutter)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.installCommand});

  final String installCommand;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText('Sound Library', style: misText(compact ? 44 : 64, weight: FontWeight.w700, height: 1.05)),
        const SizedBox(height: 12),
        Text(
          'Free UI sounds for your Flutter apps. ${Sounds.values.length} sounds in ${SoundCategory.values.length} categories, '
          'bundled as assets: no backend, no network.',
          style: misText(compact ? 16 : 19, color: context.mis.textSubtitle, height: 1.4),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _CommandChip(command: installCommand),
            _PillLink(
                label: 'pub.dev', icon: Icons.inventory_2_outlined, url: 'https://pub.dev/packages/sound_library'),
            _PillLink(
                label: 'GitHub', icon: Icons.code_rounded, url: 'https://github.com/misdevelop-org/sound_library'),
          ],
        ),
      ],
    );
    final logo = Image.asset('assets/mis_iso.png', height: compact ? 96 : 150, semanticLabel: 'MIS Develop');
    return compact
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [logo, const SizedBox(height: 16), title])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: title),
              const SizedBox(width: 32),
              logo,
            ],
          );
  }
}

class _CommandChip extends StatelessWidget {
  const _CommandChip({required this.command});

  final String command;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(60),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: command));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                width: 280,
                backgroundColor: MisColors.lightBlue800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                content: Text('Copied to clipboard',
                    textAlign: TextAlign.center, style: misText(14, weight: FontWeight.w600, color: Colors.white)),
              ),
            );
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: context.mis.surface,
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: context.mis.accent.withValues(alpha: .35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r'$ ',
                style: misText(14,
                        weight: FontWeight.w700,
                        color:
                            Theme.of(context).brightness == Brightness.dark ? MisColors.green : const Color(0xFF1B8F3A))
                    .copyWith(fontFamily: 'monospace'),
              ),
              Flexible(
                child: Text(
                  command,
                  overflow: TextOverflow.ellipsis,
                  style: misText(14, weight: FontWeight.w600).copyWith(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.copy_rounded, size: 16, color: context.mis.accent),
            ],
          ),
        ),
      );
}

class _PillLink extends StatelessWidget {
  const _PillLink({required this.label, required this.icon, required this.url});

  final String label;
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(60),
        onTap: () => launchUrl(Uri.parse(url), webOnlyWindowName: '_blank'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: context.mis.accent),
              const SizedBox(width: 8),
              Text(label, style: misText(15, weight: FontWeight.w600, color: context.mis.accent)),
            ],
          ),
        ),
      );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.onQueryChanged,
    required this.category,
    required this.onCategory,
    required this.volume,
    required this.onVolume,
    required this.enabled,
    required this.onToggleSound,
    required this.onToggleTheme,
  });

  final TextEditingController controller;
  final VoidCallback onQueryChanged;
  final SoundCategory? category;
  final ValueChanged<SoundCategory?> onCategory;
  final double volume;
  final ValueChanged<double> onVolume;
  final bool enabled;
  final VoidCallback onToggleSound;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      controller: controller,
      onChanged: (_) => onQueryChanged(),
      style: misText(16),
      cursorColor: MisColors.green,
      decoration: InputDecoration(
        hintText: 'Search sounds',
        hintStyle: misText(16, color: context.mis.textFaint),
        prefixIcon: Icon(Icons.search_rounded, color: context.mis.accent),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: Icon(Icons.close_rounded, color: context.mis.accent),
                onPressed: () {
                  controller.clear();
                  onQueryChanged();
                },
              ),
        filled: true,
        fillColor: context.mis.surface.withValues(alpha: .8),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: _border(context.mis.accent.withValues(alpha: .3)),
        focusedBorder: _border(MisColors.lightBlue),
      ),
    );
    final volumeControl = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: enabled ? 'Mute' : 'Unmute',
          onPressed: onToggleSound,
          icon: Icon(enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: enabled ? MisColors.green : MisColors.magenta),
        ),
        SizedBox(
          width: 150,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: MisColors.lightBlue,
              inactiveTrackColor: context.mis.surface,
              thumbColor: MisColors.green,
              overlayColor: MisColors.green.withValues(alpha: .15),
            ),
            child: Slider(value: volume, onChanged: enabled ? onVolume : null),
          ),
        ),
        IconButton(
          tooltip: Theme.of(context).brightness == Brightness.dark ? 'Light mode' : 'Dark mode',
          onPressed: onToggleTheme,
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: context.mis.accent,
          ),
        ),
      ],
    );
    final wide = MediaQuery.sizeOf(context).width >= 760;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wide
            ? Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 20),
                  volumeControl,
                ],
              )
            : Column(children: [search, const SizedBox(height: 8), volumeControl]),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CategoryPill(
                label: 'All', icon: Icons.apps_rounded, selected: category == null, onTap: () => onCategory(null)),
            for (final item in SoundCategory.values)
              _CategoryPill(
                label: item.label,
                icon: iconOf(item),
                gradient: gradientOf(item),
                selected: category == item,
                onTap: () => onCategory(category == item ? null : item),
              ),
          ],
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(60), borderSide: BorderSide(color: color));
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.gradient = MisGradients.primary,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? MisColors.darkBackground : context.mis.text;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: selected ? gradient : null,
            color: selected ? null : context.mis.surface.withValues(alpha: .8),
            border: Border.all(color: selected ? Colors.transparent : context.mis.accent.withValues(alpha: .25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Text(label, style: misText(15, weight: FontWeight.w700, color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.category, required this.count});

  final SoundCategory category;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradientOf(category)),
            child: Icon(iconOf(category), color: MisColors.darkBackground, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${category.label} · $count', style: misText(24, weight: FontWeight.w700)),
                Text(category.description, style: misText(14, color: context.mis.textMuted)),
              ],
            ),
          ),
        ],
      );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.gutter});

  final double gutter;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(gutter, 56, gutter, 40),
        child: Column(
          children: [
            Divider(color: context.mis.accent.withValues(alpha: .2)),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => launchUrl(Uri.parse('https://misdevelop.com'), webOnlyWindowName: '_blank'),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GradientText('By MIS Develop', style: misText(16, weight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 4),
            Text('Free to use in personal and commercial projects.', style: misText(13, color: context.mis.textFaint)),
          ],
        ),
      );
}
