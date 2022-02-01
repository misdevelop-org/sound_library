
## Features

Easy Free UI sounds library for your app

## Getting started

Add this import line

```dart
import 'package:sound_library/sound_library.dart';
```


## Usage

Play a sound from the library

```dart
  SoundPlayer.i.play(Sounds.click);
```

Check if audio is enabled locally

```dart
  bool enabled = SoundPlayer.i.checkAudioEnabled();
```

Enable/disable sounds

```dart
  SoundPlayer.i.setAudioEnabled(true/false);
```

## Additional information

This package assumes corresponding permissions depending on platform