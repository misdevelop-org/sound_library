import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

///List of sounds available to use
enum Sounds {
  click('click.mp3?alt=media&token=ed19939f-7703-475e-8367-1a70629c011b'),
  orderComplete('order_complete.mp3?alt=media&token=098ac606-79d6-4c22-9ea6-fc3888a644c6'),
  success('success.mp3?alt=media&token=32dd1ca2-44cb-4e6a-b48b-3525c6994b89'),
  welcome('welcome.mp3?alt=media&token=08cf0c5b-3ad6-4f2f-80c7-fd6e1006f2e7'),
  woodHit('wood_hit.mp3?alt=media&token=45ead6f3-d244-4aaf-8d65-be6cbdd612e6'),
  addToCart('add_to_cart.mp3?alt=media&token=c62baff3-09b1-4f7c-9f3f-f71f74cdbb90'),
  action('action.mp3?alt=media&token=e17f955c-ebb9-4300-a02f-41f137107180'),
  deleted('trash.mp3?alt=media&token=d5424098-1562-4f3b-9576-625b00fb3457'),
  drag('drag.mp3?alt=media&token=057e9b1e-b074-41c8-81ee-10c9a3bd7a8a'),
  open('boton.mp3?alt=media&token=da09829c-f159-4e2f-a57b-36eac5a1d346'),
  intro('intro.mp3?alt=media&token=fd3dd422-1b7e-4e7f-bd2e-9ad4aab69ea1'),
  cashingMachine('kaching.mp3?alt=media&token=19c09a9d-d062-4ef2-b266-27f3773a1d7e');

  final String baseUrl = 'https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2F';
  final String _path;
  String get path => baseUrl + _path;
  const Sounds(this._path);
}

class SoundPlayer {
  ///Turns the audio on/off
  bool _enable = true;

  /// Audio player instance
  AudioPlayer? _audioPlayer;

  /// Shared preferences instance
  SharedPreferences? _prefs;

  ///Checks if the selected [sound] is cached
  ///if is cached, plays the audio immediately
  ///else downloads and caches the audio and then plays it
  ///
  /// Sets the [volume] from `0.0` to `1.0`, defaults to `1.0`
  static Future<void> play(
    Sounds sound, {
    double volume = 1,
    Duration? position,
  }) async =>
      playFromUrl(sound.path, volume: volume, position: position);

  ///Plays the audio file of the fiven [url] path
  ///
  /// Set the [volume] from `0.0` to `1.0`, defaults to `1.0`
  static void playFromUrl(
    String url, {
    double volume = 1,
    Duration? position,
  }) async {
    if (isAudioEnabled) {
      await audioPlayer.play(UrlSource(url), volume: volume, position: position);
    }
  }

  /// Plays the audio file of the given [asset]
  ///
  /// Set the [volume] from `0.0` to `1.0`, defaults to `1.0`
  static void playFromAssetPath(
    String asset, {
    double volume = 1,
    Duration? position,
  }) async {
    if (isAudioEnabled) {
      await audioPlayer.play(AssetSource(asset), volume: volume, position: position);
    }
  }

  /// Plays the audio file of the given [bytes]
  ///
  /// Set the [volume] from `0.0` to `1.0`, defaults to `1.0`
  static void playFromBytes(
    Uint8List bytes, {
    double volume = 1,
    Duration? position,
  }) async {
    if (isAudioEnabled) {
      await audioPlayer.play(BytesSource(bytes), volume: volume, position: position);
    }
  }

  /// Plays the audio file of the given [file]
  ///
  /// Set the [volume] from `0.0` to `1.0`, defaults to `1.0`
  static void playFromDeviceFilePath(
    String file, {
    double volume = 1,
    Duration? position,
  }) async {
    if (isAudioEnabled) {
      await audioPlayer.play(DeviceFileSource(file), volume: volume, position: position);
    }
  }

  ///Checks if audio is [_enable] on the instance, if null, checks on local storage
  static bool get isAudioEnabled => instance._enable;

  ///Checks if audio is [_enable] locally
  static Future<bool> checkLocalStorageEnabled() async {
    instance._enable = (await prefs).getBool('soundEnabled') ?? true;
    return instance._enable;
  }

  ///Gets the current audio player instance
  static AudioPlayer get audioPlayer {
    instance._audioPlayer ??= AudioPlayer();
    return instance._audioPlayer!;
  }

  ///Gets the current shared preferences instance
  static Future<SharedPreferences> get prefs async {
    instance._prefs ??= await SharedPreferences.getInstance();
    return instance._prefs!;
  }

  ///Sets audio [enable]/disable
  static setAudioEnabled(bool enable) async {
    instance._enable = enable;
    (await prefs).setBool('soundEnabled', enable);
  }

  ///Allows access to all SoundPlayer functions
  static final SoundPlayer instance = SoundPlayer._internal();

  static get i => instance;

  SoundPlayer._internal();

  factory SoundPlayer() => instance;
}
