import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_library/sound_library.dart';
import 'package:sound_library/src/sound_backend_native.dart' show buildSoundContext;

void main() {
  group('Sounds', () {
    test('every sound points to an existing file', () {
      for (final sound in Sounds.values) {
        final file = File('assets/sounds/${sound.category.folder}/${sound.file}');
        expect(file.existsSync(), isTrue, reason: '${sound.name}: ${file.path} is missing');
        expect(file.lengthSync(), greaterThan(0), reason: '${sound.name}: ${file.path} is empty');
      }
    });

    test('every bundled file is exposed by a sound', () {
      final exposed = {for (final sound in Sounds.values) 'assets/sounds/${sound.category.folder}/${sound.file}'};
      final onDisk = Directory('assets/sounds')
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => file.path)
          .where((path) => !path.endsWith('.DS_Store'))
          .toSet();
      expect(onDisk, exposed);
    });

    test('every category folder is declared in the pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final category in SoundCategory.values) {
        expect(pubspec, contains('- assets/sounds/${category.folder}/'));
      }
    });

    test('asset paths are package asset keys', () {
      expect(Sounds.click.assetPath, 'packages/sound_library/assets/sounds/interaction/click.mp3');
    });

    test('every category has sounds and byCategory covers all sounds', () {
      for (final category in SoundCategory.values) {
        expect(category.sounds, isNotEmpty, reason: category.name);
      }
      expect(Sounds.byCategory.values.expand((sounds) => sounds), unorderedEquals(Sounds.values));
    });

    test('labels and descriptions are filled and unique file names per category', () {
      final seen = <String>{};
      for (final sound in Sounds.values) {
        expect(sound.label, isNotEmpty);
        expect(sound.description, isNotEmpty);
        expect(seen.add('${sound.category.folder}/${sound.file}'), isTrue, reason: sound.name);
      }
    });
  });

  group('SoundPlayer', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('audio is enabled by default and the choice is persisted', () async {
      expect(await SoundPlayer.checkLocalStorageEnabled(), isTrue);

      await SoundPlayer.setAudioEnabled(false);
      expect(SoundPlayer.isAudioEnabled, isFalse);
      expect((await SharedPreferences.getInstance()).getBool(SoundPlayer.enabledKey), isFalse);

      // Playing while disabled is a no-op and never throws.
      await SoundPlayer.play(Sounds.click);

      await SoundPlayer.setAudioEnabled(true);
      expect(await SoundPlayer.checkLocalStorageEnabled(), isTrue);
    });

    test('respectSilence is off by default and can be changed without a device', () async {
      expect(SoundPlayer.respectSilence, isFalse);

      // There is no audio plugin in unit tests: the failure is logged, never thrown.
      await SoundPlayer.setRespectSilence(true);
      expect(SoundPlayer.respectSilence, isTrue);

      await SoundPlayer.setRespectSilence(false);
      expect(SoundPlayer.respectSilence, isFalse);
    });

    test('is a singleton', () {
      expect(identical(SoundPlayer(), SoundPlayer.instance), isTrue);
      expect(identical(SoundPlayer.i, SoundPlayer.instance), isTrue);
    });
  });

  group('audio context', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('iOS mixes with other audio and ignores the silent switch by default', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final ios = buildSoundContext(respectSilence: false).iOS;
      expect(ios.category, AVAudioSessionCategory.playback);
      expect(ios.options, contains(AVAudioSessionOptions.mixWithOthers));
    });

    test('iOS respectSilence uses the ambient category, which silences and mixes on its own', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      // audioplayers rejects respectSilence together with an explicit mixWithOthers on iOS.
      final ios = buildSoundContext(respectSilence: true).iOS;
      expect(ios.category, AVAudioSessionCategory.ambient);
      expect(ios.options, isNot(contains(AVAudioSessionOptions.mixWithOthers)));
    });

    test('Android never takes audio focus and respectSilence follows the ringer mode', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final normal = buildSoundContext(respectSilence: false).android;
      expect(normal.audioFocus, AndroidAudioFocus.none);
      expect(normal.usageType, AndroidUsageType.media);

      final silent = buildSoundContext(respectSilence: true).android;
      expect(silent.audioFocus, AndroidAudioFocus.none);
      expect(silent.usageType, AndroidUsageType.notificationRingtone);
    });

    test('other platforms build without error', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(() => buildSoundContext(respectSilence: true), returnsNormally);
      expect(() => buildSoundContext(respectSilence: false), returnsNormally);
    });
  });
}
