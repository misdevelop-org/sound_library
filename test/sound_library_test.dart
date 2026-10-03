import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_library/sound_library.dart';

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

    test('is a singleton', () {
      expect(identical(SoundPlayer(), SoundPlayer.instance), isTrue);
      expect(identical(SoundPlayer.i, SoundPlayer.instance), isTrue);
    });
  });
}
