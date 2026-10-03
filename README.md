<img alt="Sound Library by MIS Develop"
    src="https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2Freadme%2FPackages%20pub.dev%201.png?alt=media&token=7727067e-6fee-49ac-9573-834b42d70cf8">

# sound_library

[![pub package](https://img.shields.io/pub/v/sound_library.svg)](https://pub.dev/packages/sound_library)
[![CI](https://github.com/misdevelop-org/sound_library/actions/workflows/ci.yml/badge.svg)](https://github.com/misdevelop-org/sound_library/actions/workflows/ci.yml)
[![Web deploy](https://github.com/misdevelop-org/sound_library/actions/workflows/web_deploy_dev.yml/badge.svg)](https://github.com/misdevelop-org/sound_library/actions/workflows/web_deploy_dev.yml)

23 free UI sounds in 5 categories, bundled inside the package, plus a tiny `SoundPlayer` to play them.

**Hear them all, and copy the code, at [sounds.library.misdevelop.com](https://sounds.library.misdevelop.com).**

## Features

- **Bundled assets**: the sounds ship with the package. There is no backend, no account and no network request
  to play them, so they work offline.
- **Categorized**: every sound belongs to a `SoundCategory`, so you can browse, search or build a settings screen from
  `SoundCategory.values` and `Sounds.byCategory`.
- **Made for UI**: sounds mix with the music or podcast the user is listening to instead of pausing it, and several
  sounds can overlap.
- **Any source**: besides the bundled sounds, play network URLs, assets of your app, files and bytes.
- **Mute switch**: one call turns sounds off, and the choice is remembered on the device.

## Getting started

```shell
flutter pub add sound_library
```

```dart
import 'package:sound_library/sound_library.dart';
```

No extra setup is needed. The sounds are declared by the package, so you do not add them to your `pubspec.yaml`.

Android, iOS, macOS, Windows, Linux and the web are supported, including WebAssembly builds. Native platforms play with `audioplayers`, and the web plays with the Web Audio API.

## Usage

### Play a sound

```dart
SoundPlayer.play(Sounds.click);

// Volume from 0.0 to 1.0, and a start position on the track.
SoundPlayer.play(Sounds.success, volume: 0.5, position: const Duration(milliseconds: 200));
```

Every `play` call returns a `Future` that completes when playback starts. It never throws: if a sound cannot play, for
example because a browser blocks audio until the first user gesture, the error is logged and the app keeps running.

### Preload for zero delay

The first play of a sound loads it. Preload the ones you use most when your app starts:

```dart
await SoundPlayer.preload([Sounds.click, Sounds.success, Sounds.addToCart]);
```

### Browse by category

```dart
for (final category in SoundCategory.values) {
  print('${category.label}: ${category.sounds.map((s) => s.label).join(', ')}');
}

final Map<SoundCategory, List<Sounds>> grouped = Sounds.byCategory;
final String label = Sounds.woodHit.label; // 'Close (wood hit)'
final String description = Sounds.woodHit.description;
```

### Play from other sources

```dart
SoundPlayer.playFromUrl('https://example.com/ding.mp3');
SoundPlayer.playFromAssetPath('sounds/ding.mp3'); // assets/sounds/ding.mp3 in your app
SoundPlayer.playFromDeviceFilePath('/path/to/ding.mp3');
SoundPlayer.playFromBytes(bytes);
```

### Turn sounds on and off

```dart
// On startup: load the saved choice (sounds are on by default).
await SoundPlayer.checkLocalStorageEnabled();

// From a settings switch: saves the choice and stops what is playing.
await SoundPlayer.setAudioEnabled(false);

final bool enabled = SoundPlayer.isAudioEnabled;
```

### Stop and release

```dart
await SoundPlayer.stop(); // stop everything that is playing
await SoundPlayer.dispose(); // release the audio players; they are created again on the next play
```

## The sounds

#### Interaction

Taps, clicks, drags and pops: the direct response to a touch.

| Sound | Code | Format | Use it for |
|---|---|---|---|
| Click | `Sounds.click` | mp3 | General button click. |
| Tap | `Sounds.tap` | wav | Soft tap for dense UIs and frequent taps. |
| Bip | `Sounds.bip` | mp3 | Short beep, for example when scanning a code. |
| Drag | `Sounds.drag` | mp3 | Drag and drop. |
| Pop in | `Sounds.popIn` | wav | A tooltip, chip or bubble appears. |
| Pop out | `Sounds.popOut` | wav | A tooltip, chip or bubble disappears. |
| Action | `Sounds.action` | mp3 | General action, usually without user interaction. |

#### Navigation

Opening and closing pages, panels, menus and drawers.

| Sound | Code | Format | Use it for |
|---|---|---|---|
| Open | `Sounds.open` | mp3 | Open a drawer, menu or popup. |
| Close (wood hit) | `Sounds.woodHit` | mp3 | High pitched hit of two wood blocks to close. |
| Open page | `Sounds.openPage` | wav | Navigate forward to a page. |
| Close page | `Sounds.closePage` | wav | Navigate back from a page. |
| Open panel | `Sounds.openPanel` | wav | Slide a side panel or sheet in. |
| Close panel | `Sounds.closePanel` | wav | Slide a side panel or sheet out. |

#### Feedback

The outcome of an action: success, deletion and alerts.

| Sound | Code | Format | Use it for |
|---|---|---|---|
| Success | `Sounds.success` | mp3 | Something succeeded or completed. |
| Deleted | `Sounds.deleted` | mp3 | Delete an item or a file. |
| Remove | `Sounds.remove` | wav | A lighter delete, for removing a row or a chip. |
| Glass | `Sounds.glass` | mp3 | Long glass chime for notices worth noticing. |

#### Commerce

Carts, orders and payments.

| Sound | Code | Format | Use it for |
|---|---|---|---|
| Add to cart | `Sounds.addToCart` | mp3 | Item added to the cart. |
| Order complete | `Sounds.orderComplete` | mp3 | An order was completed. |
| Cashing machine | `Sounds.cashingMachine` | mp3 | Cash register ka-ching. |

#### Brand

Intros and welcomes that give your app its personality.

| Sound | Code | Format | Use it for |
|---|---|---|---|
| Intro | `Sounds.intro` | mp3 | Full intro jingle, about 6 seconds. |
| Intro (short) | `Sounds.introShort` | wav | Short intro jingle, about 4 seconds. |
| Welcome | `Sounds.welcome` | mp3 | Welcome sound. |

## Platform notes

- **Web**: browsers only start audio after the user interacts with the page, so a sound triggered on load will be
  skipped. Sounds triggered by a tap or click work. All sounds play through the Web Audio API, which is what makes
  the shortest ones audible on iPhone. Call `SoundPlayer.init()` when your app starts so the first touch unlocks audio.
  Like other Web Audio sounds on iOS, they follow the silent switch of the device.
- **iOS and Android**: sounds mix with other audio and do not take audio focus.

## Roadmap

Ideas for the next releases. Open an issue if one of them matters to you.

- **Notification**: `notification`, `mention`, `reminder`, `alarm` for in-app alerts.
- **Feedback**: `error`, `warning`, `info` and a `toggleOn` / `toggleOff` pair for switches.
- **Interaction**: `hover`, `scroll tick`, `slider tick`, `select` for pickers.
- **Communication**: `messageSent`, `messageReceived`, `typing` for chat apps.
- **Commerce**: `paymentSuccess`, `paymentFailed`, `coin` for checkout flows.
- **Progress**: `startRecording`, `stopRecording`, `countdownTick`, `levelUp` for timers and gamified flows.
- A `SoundTheme` to swap a whole set at once (soft, playful, classic) and a haptics companion.

## Migrating from 1.x

Version 2.0 plays the sounds from bundled assets instead of downloading them from Firebase Storage.

- `Sounds.path` is gone; use `Sounds.assetPath`. Remove any use of the Firebase URLs.
- `SoundPlayer.audioPlayer` and `SoundPlayer.prefs` are no longer public. Use `SoundPlayer.stop()` and
  `SoundPlayer.dispose()` to control playback.
- `playFromUrl`, `playFromAssetPath`, `playFromBytes` and `playFromDeviceFilePath` now return a `Future`.
- `Sounds.deleted` and the other 1.x names are unchanged. New sounds were added, including the ones from Facturanza.

## Additional information

- Live app and example: [`example/`](https://github.com/misdevelop-org/sound_library/tree/main/example)
- Issues and contributions: [GitHub](https://github.com/misdevelop-org/sound_library/issues)
- Built by [MIS Develop](https://misdevelop.com)
