import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:web/web.dart' as web;

import 'sound_backend.dart';

/// Creates the backend for the web.
SoundBackend createBackend() => _WebBackend();

/// Plays with the Web Audio API, without `audioplayers`.
///
/// Browsers, and iOS Safari in particular, drop or cut very short sounds played through an `<audio>` element, because
/// the audio hardware takes a moment to wake up. Decoded buffers played through an `AudioContext` have none of that:
/// they start instantly and can overlap freely. iOS also keeps the context locked until a user gesture, so [init]
/// unlocks it on the first touch, click or key press.
///
/// Network URLs and device paths use an `<audio>` element instead, because decoding them would need the server to
/// allow cross-origin requests.
class _WebBackend implements SoundBackend {
  static const _gestures = ['touchstart', 'touchend', 'pointerdown', 'pointerup', 'mousedown', 'click', 'keydown'];

  web.AudioContext? _context;
  final Map<String, Future<web.AudioBuffer?>> _buffers = {};
  final Set<web.AudioBufferSourceNode> _sources = {};
  final Set<web.HTMLAudioElement> _elements = {};
  bool _listening = false;

  web.AudioContext get _ctx => _context ??= web.AudioContext();

  @override
  void init() {
    if (_listening) return;
    _listening = true;
    final listener = ((web.Event _) => _unlock()).toJS;
    for (final gesture in _gestures) {
      web.window.addEventListener(gesture, listener, web.AddEventListenerOptions(capture: true, passive: true));
    }
  }

  void _unlock() {
    final ctx = _ctx;
    if (ctx.state == 'running') return;
    ctx.resume().toDart.ignore();
    // A silent one-sample sound inside the gesture is what fully unlocks audio on iOS.
    final source = ctx.createBufferSource()
      ..buffer = ctx.createBuffer(1, 1, 22050)
      ..connect(ctx.destination);
    source.start(0);
  }

  @override
  Future<void> preload(Iterable<String> keys) async {
    init();
    await Future.wait(keys.map(_load));
  }

  @override
  Future<void> playBundled(String key, {required double volume, Duration? position}) async {
    init();
    _unlock();
    final buffer = await _load(key);
    if (buffer == null) throw StateError('Could not load the sound $key');
    await _playBuffer(buffer, volume, position);
  }

  @override
  Future<void> playAsset(String asset, {required double volume, Duration? position}) =>
      playBundled('assets/$asset', volume: volume, position: position);

  @override
  Future<void> playBytes(Uint8List bytes, {required double volume, Duration? position}) async {
    init();
    _unlock();
    final buffer = await _decode(bytes);
    await _playBuffer(buffer, volume, position);
  }

  @override
  Future<void> playUrl(String url, {required double volume, Duration? position}) async {
    init();
    final element = web.HTMLAudioElement()
      ..src = url
      ..volume = volume.clamp(0.0, 1.0);
    if (position != null) element.currentTime = position.inMicroseconds / Duration.microsecondsPerSecond;
    _elements.add(element);
    element.onended = ((web.Event _) => _elements.remove(element)).toJS;
    await element.play().toDart;
  }

  /// On the web a device path can only be something the browser can open, like a blob or object URL.
  @override
  Future<void> playFile(String path, {required double volume, Duration? position}) =>
      playUrl(path, volume: volume, position: position);

  @override
  Future<void> stop() async {
    for (final source in _sources.toList()) {
      try {
        source.stop();
      } on Object {
        // Already stopped.
      }
    }
    _sources.clear();
    for (final element in _elements) {
      element.pause();
    }
    _elements.clear();
  }

  @override
  Future<void> dispose() async {
    await stop();
    _buffers.clear();
  }

  Future<void> _playBuffer(web.AudioBuffer buffer, double volume, Duration? position) async {
    final ctx = _ctx;
    if (ctx.state != 'running') await ctx.resume().toDart;
    final gain = ctx.createGain()..gain.value = volume.clamp(0.0, 1.0);
    gain.connect(ctx.destination);
    final source = ctx.createBufferSource()
      ..buffer = buffer
      ..connect(gain);
    source.onended = ((web.Event _) {
      _sources.remove(source);
      source.disconnect();
      gain.disconnect();
    }).toJS;
    _sources.add(source);
    source.start(0, (position?.inMicroseconds ?? 0) / Duration.microsecondsPerSecond);
  }

  Future<web.AudioBuffer> _decode(Uint8List bytes) {
    // decodeAudioData detaches the buffer it is given, so hand it a copy.
    final copy = Uint8List.fromList(bytes);
    return _ctx.decodeAudioData(copy.buffer.toJS).toDart;
  }

  Future<web.AudioBuffer?> _load(String key) => _buffers.putIfAbsent(key, () async {
        try {
          final data = await rootBundle.load(key);
          return await _decode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        } on Object {
          // Allow a retry on the next play.
          _buffers.remove(key);
          return null;
        }
      });
}
