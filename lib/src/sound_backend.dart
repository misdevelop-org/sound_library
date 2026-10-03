import 'dart:typed_data';

/// How sounds actually reach the speakers. There is one backend per kind of platform: `audioplayers` on Android, iOS,
/// desktop, and the Web Audio API on the web. The web one does not depend on `audioplayers`, which keeps the web build
/// small and compatible with WebAssembly.
abstract class SoundBackend {
  /// Gets audio ready. Safe to call many times.
  void init();

  /// Loads the bundled sounds with the given asset [keys] into memory.
  Future<void> preload(Iterable<String> keys);

  /// Plays a sound bundled with this package, by its full asset [key].
  Future<void> playBundled(String key, {required double volume, Duration? position});

  /// Plays an asset of the app, by its path relative to the `assets/` folder.
  Future<void> playAsset(String asset, {required double volume, Duration? position});

  /// Plays the audio file at a network [url].
  Future<void> playUrl(String url, {required double volume, Duration? position});

  /// Plays the audio file in [bytes].
  Future<void> playBytes(Uint8List bytes, {required double volume, Duration? position});

  /// Plays the audio file at a [path] on the device.
  Future<void> playFile(String path, {required double volume, Duration? position});

  /// Stops everything that is playing.
  Future<void> stop();

  /// Releases everything held. The backend works again on the next play.
  Future<void> dispose();
}
