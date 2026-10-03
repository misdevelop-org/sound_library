import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:web/web.dart' as web;

/// Low latency playback of bundled sounds with the Web Audio API.
///
/// Browsers, and iOS Safari in particular, drop or cut very short sounds played through an `<audio>` element, because
/// the audio hardware takes a moment to wake up. Decoded buffers played through an `AudioContext` have none of that,
/// they start instantly and can overlap freely. iOS also keeps the context locked until a user gesture, so [init]
/// unlocks it on the first touch, click or key press.
class WebSfx {
  static web.AudioContext? _context;
  static final Map<String, Future<web.AudioBuffer?>> _buffers = {};
  static final Set<web.AudioBufferSourceNode> _playing = {};
  static bool _listening = false;

  static const _gestures = ['touchstart', 'touchend', 'pointerdown', 'pointerup', 'mousedown', 'click', 'keydown'];

  /// Whether this platform plays bundled sounds with Web Audio.
  static bool get isSupported => true;

  static web.AudioContext get _ctx => _context ??= web.AudioContext();

  /// Starts listening for the first user gesture to unlock audio.
  static void init() {
    if (_listening) return;
    _listening = true;
    final listener = ((web.Event _) => _unlock()).toJS;
    for (final gesture in _gestures) {
      web.window.addEventListener(gesture, listener, web.AddEventListenerOptions(capture: true, passive: true));
    }
  }

  static void _unlock() {
    final ctx = _ctx;
    if (ctx.state == 'running') return;
    ctx.resume().toDart.ignore();
    // A silent one-sample sound inside the gesture is what fully unlocks audio on iOS.
    final source = ctx.createBufferSource()
      ..buffer = ctx.createBuffer(1, 1, 22050)
      ..connect(ctx.destination);
    source.start(0);
  }

  /// Plays the bundled [assetKey]. Returns `false` when it could not be played this way.
  static Future<bool> play(String assetKey, {required double volume, Duration? position}) async {
    init();
    _unlock();
    try {
      final buffer = await _load(assetKey);
      if (buffer == null) return false;
      final ctx = _ctx;
      if (ctx.state != 'running') await ctx.resume().toDart;
      final gain = ctx.createGain()..gain.value = volume.clamp(0.0, 1.0);
      gain.connect(ctx.destination);
      final source = ctx.createBufferSource()
        ..buffer = buffer
        ..connect(gain);
      source.onended = ((web.Event _) {
        _playing.remove(source);
        source.disconnect();
        gain.disconnect();
      }).toJS;
      _playing.add(source);
      final offset = (position?.inMicroseconds ?? 0) / Duration.microsecondsPerSecond;
      source.start(0, offset);
      return true;
    } on Object {
      return false;
    }
  }

  /// Decodes the given asset keys so their first play has no delay.
  static Future<void> preload(Iterable<String> assetKeys) async {
    init();
    await Future.wait(assetKeys.map(_load));
  }

  /// Stops everything that is playing.
  static void stop() {
    for (final source in _playing.toList()) {
      try {
        source.stop();
      } on Object {
        // Already stopped.
      }
    }
    _playing.clear();
  }

  static Future<web.AudioBuffer?> _load(String assetKey) => _buffers.putIfAbsent(assetKey, () async {
        try {
          final data = await rootBundle.load(assetKey);
          // decodeAudioData detaches the buffer it is given, so hand it a copy.
          final bytes = Uint8List.fromList(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
          return await _ctx.decodeAudioData(bytes.buffer.toJS).toDart;
        } on Object {
          // Allow a retry on the next play.
          _buffers.remove(assetKey);
          return null;
        }
      });
}
