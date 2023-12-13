<img alt="Sounds library package by MIS Develop"
    src="https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2Freadme%2FPackages%20pub.dev%201.png?alt=media&token=7727067e-6fee-49ac-9573-834b42d70cf8">

## Features

Easy and free 🆓 UI sounds library 🎶 for your general purposes 🎧 🔊

[![Web deploy](https://github.com/misdevelop-org/sound_library/actions/workflows/web_deploy_dev.yml/badge.svg)](https://github.com/misdevelop-org/sound_library/actions/workflows/web_deploy_dev.yml)

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  sound_library: ^1.0.0
```
  
Add this import line  
  
```dart  
import 'package:sound_library/sound_library.dart';  
```

#### Available sounds

##### Try out the sounds in the example project

Live example: [Sounds Library](https://sounds.library.misdevelop.com)

| Name | Description |
| ---- | ---- |
| Click | General button click |
| Action | General action sound (Usually no user interaction) |
| Open | Open drawer, open menu, open popup, etc. |
| Deleted | Delete item, delete file, etc. |
| Welcome | Welcome sound |
| Success | Indicates success or completed action |
| Drag | Drag and drop sound |
| Intro | Intro sound |
| Add to cart | Add to cart sound |
| Close (Wood hit) | High pitched sound of two wood blocks |
| Order Complete | Order completed sound |
| Cashing machine | Cashing machine sound |


## Usage  
  
##### Play a sound with a `volume` level and `position` on the track

```dart
  SoundPlayer.play(Sounds.click, volume: 0.5, position: Duration(milliseconds: 500);
```

##### Play a sound from the `Sounds` library

```dart
  SoundPlayer.play(Sounds.click);
```
  
##### Play a sound from a `URL` path
  
```dart  
  SoundPlayer.playFromUrl(path);
```

##### Play a sound from a `file` path

```dart
  SoundPlayer.playFromDeviceFilePath(file);
```

##### Play a sound from an `asset` path

```dart
  SoundPlayer.playFromAssetPath(asset);
```

##### Play a sound from `bytes`

```dart
  SoundPlayer.playFromBytes(bytes);
```

##### Check if audio is currently `enabled`
  
```dart  
  bool enabled = SoundPlayer.isAudioEnabled;
```

##### Check if audio is `enabled` on the device storage
This will also load the state from the device storage onto the `isAudioEnabled` property

```dart
  bool enabled = await SoundPlayer.checkLocalStorageEnabled();
```

##### Enable/disable sounds
This will also save the state to the device storage
  
```dart  
  SoundPlayer.setAudioEnabled(true/false);
```

#####
  
## Additional information  

This package assumes corresponding permissions depending on platform.
Also, take a look at the example project for more information.