import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'sound_backend.dart';

/// Creates the backend for Android, iOS and desktop.
SoundBackend createBackend() => _NativeBackend();

/// Plays through `audioplayers`, with a small pool so several sounds can overlap.
class _NativeBackend implements SoundBackend {
  /// How many sounds can overlap before the oldest one is cut.
  static const int _maxConcurrent = 4;

  /// Bundled sounds live under `packages/sound_library/...`, so they are resolved without the `assets/` prefix that
  /// `audioplayers` adds by default.
  final AudioCache _bundledCache = AudioCache(prefix: '');

  final List<AudioPlayer> _players = [];
  int _next = 0;
  bool _contextConfigured = false;
  bool _respectSilence = false;

  @override
  void init() {}

  @override
  Future<void> preload(Iterable<String> keys) => _bundledCache.loadAll(keys.toList());

  @override
  Future<void> playBundled(String key, {required double volume, Duration? position}) =>
      _play(AssetSource(key), volume, position, _bundledCache);

  @override
  Future<void> playAsset(String asset, {required double volume, Duration? position}) =>
      _play(AssetSource(asset), volume, position, AudioCache.instance);

  @override
  Future<void> playUrl(String url, {required double volume, Duration? position}) =>
      _play(UrlSource(url), volume, position, AudioCache.instance);

  @override
  Future<void> playBytes(Uint8List bytes, {required double volume, Duration? position}) =>
      _play(BytesSource(bytes), volume, position, AudioCache.instance);

  @override
  Future<void> playFile(String path, {required double volume, Duration? position}) =>
      _play(DeviceFileSource(path), volume, position, AudioCache.instance);

  @override
  Future<void> stop() => Future.wait(_players.map((player) => player.stop()));

  @override
  Future<void> dispose() async {
    final players = List<AudioPlayer>.of(_players);
    _players.clear();
    _next = 0;
    await Future.wait(players.map((player) => player.dispose()));
  }

  Future<void> _play(Source source, double volume, Duration? position, AudioCache cache) async {
    final player = await _nextPlayer();
    player.audioCache = cache;
    await player.play(source, volume: volume, position: position);
  }

  Future<AudioPlayer> _nextPlayer() async {
    await _configureContext();
    if (_players.length < _maxConcurrent) {
      final player = AudioPlayer();
      _players.add(player);
      return player;
    }
    final player = _players[_next];
    _next = (_next + 1) % _players.length;
    return player;
  }

  @override
  Future<void> setRespectSilence(bool value) async {
    if (_respectSilence == value) return;
    _respectSilence = value;
    // Before the first play the context is built with the new value anyway.
    if (_contextConfigured) await _applyContext();
  }

  /// UI sounds should not pause the music or the podcast the user is listening to.
  Future<void> _configureContext() async {
    if (_contextConfigured) return;
    _contextConfigured = true;
    await _applyContext();
  }

  /// Sets the audio context globally and on the players that already exist (on Android a context is per player).
  Future<void> _applyContext() async {
    try {
      final context = buildSoundContext(respectSilence: _respectSilence);
      await AudioPlayer.global.setAudioContext(context);
      for (final player in List<AudioPlayer>.of(_players)) {
        await player.setAudioContext(context);
      }
    } on Object catch (error) {
      debugPrint('sound_library: audio context not supported on this platform: $error');
    }
  }
}

/// The audio context used for UI sounds: they mix with other audio and never take audio focus.
///
/// With [respectSilence] they also follow the silent switch (iOS) or the ringer mode (Android).
/// On iOS that means the `ambient` category, which silences and mixes on its own. `audioplayers` rejects asking for
/// `respectSilence` and `mixWithOthers` together there.
@visibleForTesting
AudioContext buildSoundContext({required bool respectSilence}) {
  final config = respectSilence && defaultTargetPlatform == TargetPlatform.iOS
      ? AudioContextConfig(respectSilence: true)
      : AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers, respectSilence: respectSilence);
  return config.build();
}
