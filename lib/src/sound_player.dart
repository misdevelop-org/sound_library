import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// How many sounds can overlap before the oldest one is cut.
  static const int maxConcurrentSounds = 4;

  /// Bundled sounds live under `packages/sound_library/...`, so they are resolved without the `assets/` prefix that
  /// `audioplayers` adds by default.
  static final AudioCache _bundledCache = AudioCache(prefix: '');

  final List<AudioPlayer> _players = [];
  int _next = 0;
  bool _enabled = true;
  bool _contextConfigured = false;
  SharedPreferences? _prefs;

  /// Plays a bundled [sound].
  ///
  /// Sets the [volume] from `0.0` to `1.0`, defaults to `1.0`.
  /// Starts at [position] on the track when it is given.
  static Future<void> play(Sounds sound, {double volume = 1, Duration? position}) =>
      _play(AssetSource(sound.assetPath), volume, position, cache: _bundledCache);

  /// Plays the audio file at the given network [url].
  static Future<void> playFromUrl(String url, {double volume = 1, Duration? position}) =>
      _play(UrlSource(url), volume, position);

  /// Plays the audio file of the given Flutter [asset] key.
  ///
  /// The key is relative to the `assets/` folder of the bundle, like `AssetSource` in `audioplayers`.
  static Future<void> playFromAssetPath(String asset, {double volume = 1, Duration? position}) =>
      _play(AssetSource(asset), volume, position);

  /// Plays the audio file of the given [bytes].
  static Future<void> playFromBytes(Uint8List bytes, {double volume = 1, Duration? position}) =>
      _play(BytesSource(bytes), volume, position);

  /// Plays the audio file at the given [file] path on the device.
  static Future<void> playFromDeviceFilePath(String file, {double volume = 1, Duration? position}) =>
      _play(DeviceFileSource(file), volume, position);

  /// Loads the given [sounds] into memory so their first play has no delay.
  static Future<void> preload(Iterable<Sounds> sounds) async {
    try {
      await _bundledCache.loadAll(sounds.map((sound) => sound.assetPath).toList());
    } on Object catch (error) {
      debugPrint('sound_library: could not preload sounds: $error');
    }
  }

  /// Stops everything that is playing.
  static Future<void> stop() => Future.wait(instance._players.map((player) => player.stop()));

  /// Releases the audio players. They are created again on the next play.
  static Future<void> dispose() async {
    final players = List<AudioPlayer>.of(instance._players);
    instance._players.clear();
    instance._next = 0;
    await Future.wait(players.map((player) => player.dispose()));
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

  static Future<void> _play(Source source, double volume, Duration? position, {AudioCache? cache}) async {
    if (!isAudioEnabled) return;
    try {
      final player = await instance._nextPlayer();
      player.audioCache = cache ?? AudioCache.instance;
      await player.play(source, volume: volume, position: position);
    } on Object catch (error) {
      debugPrint('sound_library: could not play sound: $error');
    }
  }

  Future<AudioPlayer> _nextPlayer() async {
    await _configureContext();
    if (_players.length < maxConcurrentSounds) {
      final player = AudioPlayer();
      _players.add(player);
      return player;
    }
    final player = _players[_next];
    _next = (_next + 1) % _players.length;
    return player;
  }

  /// UI sounds should not pause the music or the podcast the user is listening to.
  Future<void> _configureContext() async {
    if (_contextConfigured) return;
    _contextConfigured = true;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
      );
    } on Object catch (error) {
      debugPrint('sound_library: audio context not supported on this platform: $error');
    }
  }
}
