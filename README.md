<img alt="Sound Library by MIS Develop"
    src="https://firebasestorage.googleapis.com/v0/b/misdevelop.appspot.com/o/sound_library%2Freadme%2FPackages%20pub.dev%201.png?alt=media&token=7727067e-6fee-49ac-9573-834b42d70cf8">

# sound_library

[![pub package](https://img.shields.io/pub/v/sound_library.svg)](https://pub.dev/packages/sound_library)
[![CI](https://github.com/misdevelop-org/sound_library/actions/workflows/ci.yml/badge.svg)](https://github.com/misdevelop-org/sound_library/actions/workflows/ci.yml)
[![Web deploy](https://github.com/misdevelop-org/sound_library/actions/workflows/web_deploy_dev.yml/badge.svg)](https://github.com/misdevelop-org/sound_library/actions/workflows/web_deploy_dev.yml)

39 free UI sounds in 7 categories, bundled inside the package, plus a tiny `SoundPlayer` to play them.

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

### Follow the silent switch

By default sounds play even when the iPhone is silenced, because they use the `playback` audio session so they mix
with the user's music. Turn this on for UI sounds that should respect the silent switch (iOS) and the ringer mode
(Android):

```dart
// On startup, after SoundPlayer.init(). Not saved: call it every time the app starts.
await SoundPlayer.setRespectSilence(true);
```

Sounds still mix with other audio and never pause it. It has no effect on the web, where sounds already follow the
silent switch, nor on desktop.

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
| Toggle on | `Sounds.toggleOn` | wav | A switch or checkbox turns on. |
| Toggle off | `Sounds.toggleOff` | wav | A switch or checkbox turns off. |
| Select | `Sounds.select` | wav | Pick an item in a list, a tab or a picker. |

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
| Error | `Sounds.error` | mp3 | Something went wrong. Two falling, buzzy notes. |
| Warning | `Sounds.warning` | mp3 | Heads up: a double beep. |
| Info | `Sounds.info` | mp3 | A soft bell for neutral information. |

#### Notification

Alerts, mentions, reminders and alarms.

| Sound | Code | Format | Use it for |
|---|---|---|---|
| Notification | `Sounds.notification` | mp3 | A new notification. Two rising bells. |
| Mention | `Sounds.mention` | mp3 | Someone mentioned you. A quick rising arpeggio. |
| Reminder | `Sounds.reminder` | mp3 | A reminder is due. Two bells with an echo. |
| Alarm | `Sounds.alarm` | mp3 | An alarm or timer going off. Alternating beeps. |

#### Communication

Sending, receiving and typing messages.

| Sound | Code | Format | Use it for |
|---|---|---|---|
| Message sent | `Sounds.messageSent` | wav | A message was sent. A quick upward swoosh. |
| Message received | `Sounds.messageReceived` | mp3 | A message arrived. Two soft rising notes. |
| Typing | `Sounds.typing` | wav | A typewriter key strike, for typing indicators and keyboards. |

#### Commerce

Carts, orders and payments.

| Sound | Code | Format | Use it for |
|---|---|---|---|
| Payment success | `Sounds.paymentSuccess` | mp3 | A payment went through. A rising arpeggio. |
| Payment failed | `Sounds.paymentFailed` | mp3 | A payment was declined. Two falling notes. |
| Coin | `Sounds.coin` | mp3 | A coin drops: a bright two-note blip. |
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
- **iOS and Android**: sounds mix with other audio and do not take audio focus. They ignore the silent switch and the
  ringer mode unless you call `SoundPlayer.setRespectSilence(true)`.

## Roadmap

Ideas for the next releases. Open an issue if one of them matters to you.

- **Progress**: `startRecording`, `stopRecording`, `countdownTick`, `levelUp` for timers and gamified flows.
- **Interaction**: `hover`, `scroll tick` and `slider tick` for very dense UIs.
- A `SoundTheme` to swap a whole set at once (soft, playful, classic) and a haptics companion.

The sounds added in 2.2.0 are generated by [`tools/generate_sounds.py`](https://github.com/misdevelop-org/sound_library/blob/main/tools/generate_sounds.py),
so they can be tuned and regenerated.

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
