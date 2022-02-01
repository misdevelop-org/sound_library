import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:storage_manager/storage_manager.dart';

enum Sounds { click, order_complete, success, welcome, wood_hit, add_to_cart, action, trash, drag }

// Soundpool pool = Soundpool(streamType: StreamType.notification);
class SoundPlayer {
  bool enable = true;
  Uint8List? buffer;
  // -------  Here is the code to playback a remote file -----------------------
  String _getAssetName(Sounds sound) {
    String path;
    switch (sound) {
      case Sounds.click:
        path = 'click.mp3';
        break;
      case Sounds.drag:
        path = 'drag.mp3';
        break;
      case Sounds.trash:
        path = 'trash.mp3';
        break;
      case Sounds.success:
        path = 'success.mp3';
        break;
      case Sounds.welcome:
        path = 'welcome.mp3';
        break;
      case Sounds.wood_hit:
        path = 'wood_hit.mp3';
        break;
      case Sounds.order_complete:
        path = 'order_complete.mp3';
        break;
      case Sounds.add_to_cart:
        path = 'add_to_cart.mp3';
        break;
      case Sounds.action:
        path = 'action.mp3';
        break;
      default:
        path = 'click.mp3';
    }
    return path;
  }

  void play(Sounds sound) async {
    if (i.enable) {
      AudioCache audioPlayer = AudioCache();
      double volume = 1;
      if (sound == Sounds.success) {
        volume = .7;
      }
      await audioPlayer.play(_getAssetName(sound), volume: volume);
    }
  }

  static Future<bool> checkAudioEnabled() async {
    i.enable = (await DataPersistor().getString('soundEnabled') == 'true');
    return i.enable;
  }

  static setAudioEnabled(bool enable) async {
    DataPersistor().saveString('soundEnabled', enable ? 'true' : 'false');
  }

  static final SoundPlayer i = SoundPlayer._internal();

  SoundPlayer._internal();

  factory SoundPlayer() {
    // checkAudioPermission();
    return i;
  }
}
