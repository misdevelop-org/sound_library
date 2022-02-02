
<img  
    alt="Sound package"  
    src="https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2Freadme%2FPackages.png?alt=media&token=1da3f222-96c4-426c-90c8-2c161f4e7e69">  
  
## Features  
  
Easy Free UI sounds library for your app

<h3>Sounds list</h3>

<p>Click</p>

<audio controls>
  <source src="https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2Fclick.mp3?alt=media&token=ed19939f-7703-475e-8367-1a70629c011b" type="audio/mp3">
  Your browser does not support the audio element.
</audio>
<p>Success</p>

<audio controls>
  <source src="https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2Fsuccess.mp3?alt=media&token=32dd1ca2-44cb-4e6a-b48b-3525c6994b89" type="audio/mp3">
  Your browser does not support the audio element.
</audio>

  
## Getting started  
  
Add this import line  
  
```dart  
import 'package:sound_library/sound_library.dart';  
```  
  
## Usage  
  
##### Play a sound from the library  
  
```dart  
  SoundPlayer.i.play(Sounds.click);  
```  
  
##### Play a sound from a local path  
  
```dart  
  SoundPlayer.i.playLocal(path);  
```  
  
##### Check if audio is enabled locally  
  
```dart  
  bool enabled = SoundPlayer.i.checkAudioEnabled();  
```  
  
##### Enable/disable sounds  
  
```dart  
  SoundPlayer.i.setAudioEnabled(true/false);  
```  
  
## Additional information  
  
This package assumes corresponding permissions depending on platform