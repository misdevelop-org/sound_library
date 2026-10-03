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
