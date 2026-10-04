import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sound_backend.dart';
import 'sound_backend_native.dart' if (dart.library.js_interop) 'sound_backend_web.dart';
import 'sounds.dart';

/// Plays the sounds of the library, or any other audio source.
///
/// Playback is skipped while audio is disabled. Failures (for example a browser that blocks audio until the
/// first user gesture) are logged and never thrown, because a missing UI sound should not break an app.
class SoundPlayer {
  SoundPlayer._internal();

  /// The single instance behind all static methods.
  static final SoundPlayer instance = SoundPlayer._internal();

  /// Shorthand for [instance].
  static SoundPlayer get i => instance;

  /// Returns [instance].
  factory SoundPlayer() => instance;

  /// Key under which the enabled flag is persisted.
  static const String enabledKey = 'soundEnabled';

  final SoundBackend _backend = createBackend();
  bool _enabled = true;
  bool _respectSilence = false;
  SharedPreferences? _prefs;

  /// Plays a bundled [sound].
  ///
  /// Sets the [volume] from `0.0` to `1.0`, defaults to `1.0`.
  /// Starts at [position] on the track when it is given.
  static Future<void> play(Sounds sound, {double volume = 1, Duration? position}) =>
      _play(() => instance._backend.playBundled(sound.assetPath, volume: volume, position: position));

  /// Plays the audio file at the given network [url].
  static Future<void> playFromUrl(String url, {double volume = 1, Duration? position}) =>
      _play(() => instance._backend.playUrl(url, volume: volume, position: position));

  /// Plays the audio file of the given Flutter [asset] key.
  ///
  /// The key is relative to the `assets/` folder of the bundle, so `sounds/ding.mp3` plays `assets/sounds/ding.mp3`.
  static Future<void> playFromAssetPath(String asset, {double volume = 1, Duration? position}) =>
      _play(() => instance._backend.playAsset(asset, volume: volume, position: position));

  /// Plays the audio file of the given [bytes].
  static Future<void> playFromBytes(Uint8List bytes, {double volume = 1, Duration? position}) =>
      _play(() => instance._backend.playBytes(bytes, volume: volume, position: position));

  /// Plays the audio file at the given [file] path on the device.
  ///
  /// On the web there are no device paths: pass an URL the browser can open, like a blob URL.
  static Future<void> playFromDeviceFilePath(String file, {double volume = 1, Duration? position}) =>
      _play(() => instance._backend.playFile(file, volume: volume, position: position));

  /// Gets audio ready. Optional: the first play does it too.
  ///
  /// On the web, browsers lock audio until the user touches the page. Call this when your app starts so the first touch
  /// unlocks it, instead of the first sound.
  static void init() => instance._backend.init();

  /// Loads the given [sounds] into memory so their first play has no delay.
  static Future<void> preload(Iterable<Sounds> sounds) async {
    try {
      await instance._backend.preload(sounds.map((sound) => sound.assetPath));
    } on Object catch (error) {
      debugPrint('sound_library: could not preload sounds: $error');
    }
  }

  /// Stops everything that is playing.
  static Future<void> stop() => instance._backend.stop();

  /// Releases the audio players. They are created again on the next play.
  static Future<void> dispose() => instance._backend.dispose();

  /// Whether sounds follow the silent switch (iOS) or the ringer mode (Android) of the device. Defaults to `false`.
  static bool get respectSilence => instance._respectSilence;

  /// Makes sounds follow the silent switch (iOS) or the ringer mode (Android) when [value] is true, so a UI sound is
  /// not heard on a silenced phone. Off by default. It is not saved: call it on startup, right after [init].
  ///
  /// Sounds keep mixing with other audio, like the music the user is playing. It has no effect on the web, where
  /// sounds already follow the silent switch, nor on desktop.
  static Future<void> setRespectSilence(bool value) async {
    instance._respectSilence = value;
    try {
      await instance._backend.setRespectSilence(value);
    } on Object catch (error) {
      debugPrint('sound_library: could not change respectSilence: $error');
    }
  }

  /// Whether audio is currently enabled on this instance.
  static bool get isAudioEnabled => instance._enabled;

  /// Loads the enabled flag from the device storage into [isAudioEnabled] and returns it.
  static Future<bool> checkLocalStorageEnabled() async {
    instance._enabled = (await _preferences).getBool(enabledKey) ?? true;
    return instance._enabled;
  }

  /// Enables or disables audio, and saves the choice on the device storage.
  static Future<void> setAudioEnabled(bool enable) async {
    instance._enabled = enable;
    if (!enable) await stop();
    await (await _preferences).setBool(enabledKey, enable);
  }

  static Future<SharedPreferences> get _preferences async => instance._prefs ??= await SharedPreferences.getInstance();

  static Future<void> _play(Future<void> Function() play) async {
    if (!isAudioEnabled) return;
    try {
      await play();
    } on Object catch (error) {
      debugPrint('sound_library: could not play sound: $error');
    }
  }
}
