<img alt="Sounds library package by MIS Develop"
    src="https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2Freadme%2FPackages%20pub.dev%201.png?alt=media&token=7727067e-6fee-49ac-9573-834b42d70cf8">

## Features

Easy and free 🆓 UI sounds library 🎶 for your general purposes 🎧 🔊


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

##### Try out the sounds in the example project

Live example: [Sounds Library](https://sounds.library.misdevelop.com)

## Usage  
  
##### Play a sound from the `Sounds` library
  
```dart  
  SoundPlayer.play(Sounds.click);
```  
  
##### Play a sound from a local `path`
  
```dart  
  SoundPlayer.playFromUrl(path);
```  
  
##### Check if audio is `enabled` locally
  
```dart  
  bool enabled = SoundPlayer.checkAudioEnabled();
```  
  
##### Enable/disable sounds  
  
```dart  
  SoundPlayer.setAudioEnabled(true/false);
```  
  
## Additional information  

This package assumes corresponding permissions depending on platform.
Also, take a look at the example project for more information.