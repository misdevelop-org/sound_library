import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:storage_manager/storage_manager.dart';

///List of sounds available to use
enum Sounds {
  click,
  order_complete,
  success,
  welcome,
  wood_hit,
  add_to_cart,
  action,
  trash,
  drag,
  open,
  intro,
  kaching
}

class SoundPlayer {
  ///Turns the audio on/off
  bool enable = true;

  Uint8List? buffer;

  ///Searches the audio file locally or downloads and caches it
  String _getSoundBytes(Sounds sound) {
    String path =
        'https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2F';
    switch (sound) {
      case Sounds.click:
        path +=
            'click.mp3?alt=media&token=ed19939f-7703-475e-8367-1a70629c011b';
        break;
      case Sounds.drag:
        path += 'drag.mp3?alt=media&token=057e9b1e-b074-41c8-81ee-10c9a3bd7a8a';
        break;
      case Sounds.trash:
        path +=
            'trash.mp3?alt=media&token=d5424098-1562-4f3b-9576-625b00fb3457';
        break;
      case Sounds.success:
        path +=
            'success.mp3?alt=media&token=32dd1ca2-44cb-4e6a-b48b-3525c6994b89';
        break;
      case Sounds.welcome:
        path +=
            'welcome.mp3?alt=media&token=08cf0c5b-3ad6-4f2f-80c7-fd6e1006f2e7';
        break;
      case Sounds.wood_hit:
        path +=
            'wood_hit.mp3?alt=media&token=45ead6f3-d244-4aaf-8d65-be6cbdd612e6';
        break;
      case Sounds.order_complete:
        path +=
            'order_complete.mp3?alt=media&token=098ac606-79d6-4c22-9ea6-fc3888a644c6';
        break;
      case Sounds.add_to_cart:
        path +=
            'add_to_cart.mp3?alt=media&token=c62baff3-09b1-4f7c-9f3f-f71f74cdbb90';
        break;
      case Sounds.action:
        path +=
            'action.mp3?alt=media&token=e17f955c-ebb9-4300-a02f-41f137107180';
        break;
      case Sounds.intro:
        path +=
            'intro.mp3?alt=media&token=fd3dd422-1b7e-4e7f-bd2e-9ad4aab69ea1';
        break;
      case Sounds.open:
        path +=
            'boton.mp3?alt=media&token=da09829c-f159-4e2f-a57b-36eac5a1d346';
        break;
      case Sounds.kaching:
        path +=
            'kaching.mp3?alt=media&token=19c09a9d-d062-4ef2-b266-27f3773a1d7e';
        break;
      default:
        path +=
            'click.mp3?alt=media&token=ed19939f-7703-475e-8367-1a70629c011b';
    }
    // Uint8List bytes = await DataPersistor().getImage(path);
    // if (bytes.isEmpty) {
    //   var response = await get(Uri.parse(path));
    //   if (response.statusCode == 200) {
    //     bytes = response.bodyBytes;
    //     DataPersistor().saveImage(path, bytes);
    //   }
    // }
    return path;
  }

  ///Checks if the selected sound is cached
  ///if is cached, plays the audio immediately
  ///else downloads and caches the audio and then plays it
  ///
  /// Set the volume from 0.0 to 1.0, defaults to 1.0
  void play(Sounds sound, {double volume = 1}) async {
    if (i.enable) {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.play(_getSoundBytes(sound), volume: volume);
    }
  }

  ///Plays the audio file of the fiven path
  ///
  /// Set the volume from 0.0 to 1.0, defaults to 1.0
  void playLocal(String path, {double volume = 1}) async {
    if (i.enable) {
      AudioCache audioPlayer = AudioCache();
      await audioPlayer.play(path, volume: volume);
    }
  }

  ///Checks if audio is enabled locally
  static Future<bool> checkAudioEnabled() async {
    i.enable = (await DataPersistor().getString('soundEnabled') == 'true');
    return i.enable;
  }

  ///Sets audio enable/disable
  static setAudioEnabled(bool enable) async {
    DataPersistor().saveString('soundEnabled', enable ? 'true' : 'false');
  }

  ///Allows access to all SoundPlayer functions
  static final SoundPlayer i = SoundPlayer._internal();

  SoundPlayer._internal();

  factory SoundPlayer() {
    return i;
  }
}
