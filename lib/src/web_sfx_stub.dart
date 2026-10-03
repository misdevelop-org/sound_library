/// Low latency playback of bundled sounds with the Web Audio API. Only available on the web.
class WebSfx {
  /// Whether this platform plays bundled sounds with Web Audio.
  static bool get isSupported => false;

  /// Starts listening for the first user gesture to unlock audio.
  static void init() {}

  /// Plays the bundled [assetKey]. Returns `false` when it could not be played this way.
  static Future<bool> play(String assetKey, {required double volume, Duration? position}) async => false;

  /// Decodes the given asset keys so their first play has no delay.
  static Future<void> preload(Iterable<String> assetKeys) async {}

  /// Stops everything that is playing.
  static void stop() {}
}
