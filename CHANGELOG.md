## 2.0.2

- WebAssembly: the web build no longer includes `audioplayers`, which pub.dev flagged as not compatible with wasm because
  of its `dart:io` imports. On the web, every `SoundPlayer.play*` method now uses the Web Audio API (network URLs and
  device paths use an `<audio>` element). Android, iOS and desktop still use `audioplayers`. The public API is unchanged.
- Formatting follows `formatter: page_width: 120` in `analysis_options.yaml`, so `dart format` and pub.dev agree.
- On the web, `playFromDeviceFilePath` expects a URL the browser can open, like a blob URL.

## 2.0.1

- Fixed very short sounds, like `Sounds.click` and `Sounds.tap`, not being heard on iPhone and iPad browsers. On the web,
  bundled sounds now play through the Web Audio API: no start-up delay, they overlap freely, and audio is unlocked on
  the first touch, click or key press.
- Added `SoundPlayer.init()`, to call at app start so the first touch unlocks audio on the web. It is optional.
- Added the `web` package as a dependency.
- Example app: moved the light/dark switch to the top right corner, and the live site no longer needs a cache clear to
  show a new version (no service worker, and revalidated caching on Firebase Hosting).
  The background shapes now sit on layers at different distances with scroll and mouse parallax, are pulled toward the
  cursor, and are pushed by a ripple when a sound plays. Cards lean toward the cursor, reveal on scroll, and there are
  keyboard shortcuts and a back-to-top button.

## 2.0.0

Breaking: the sounds are now bundled with the package instead of being downloaded from Firebase Storage.

- Bundled 23 sounds as package assets: the 12 existing ones plus the Facturanza set and a few more. They work offline
  and need no setup. The files are identical to the ones previously served.
- Added `SoundCategory` (interaction, navigation, feedback, commerce, brand) and `Sounds.category`, `.label`,
  `.description`, `.assetPath` and `Sounds.byCategory`.
- New sounds: `tap`, `bip`, `popIn`, `popOut`, `openPage`, `closePage`, `openPanel`, `closePanel`, `remove`, `glass` and
  `introShort`.
- Removed `Sounds.path`, `SoundPlayer.audioPlayer` and `SoundPlayer.prefs`. All `play*` methods now return a `Future`.
- Sounds mix with other audio, up to 4 can overlap, and playback errors are logged instead of thrown.
- Added `SoundPlayer.preload`, `SoundPlayer.stop` and `SoundPlayer.dispose`.
- Requires Dart 3.6 and Flutter 3.27. Upgraded `audioplayers` to 6.8 and `shared_preferences` to 2.5, and `flutter_lints`
  to 6.
- Rewrote the README and the example app, which now follows the MIS design system and is the live app at
  sounds.library.misdevelop.com. The example no longer depends on Firebase packages.
- Added unit tests, CI, and fixed the web deploy workflow (the `--web-renderer` flag no longer exists).

## 0.2.0
- Improved methods and updated to latest dependencies
- Enhanced documentation and examples
- Included live app to demonstrate usage and test the sound collection
- Added support for playing audio from network, assets, bytes and files

## 0.1.1  
#### Added  
 * Play local audio  
 * Better readme with examples  
  
## 0.1.0  
  
Formatting and static analysis  
  
## 0.0.8  
  
Added web support  
## 0.0.7  
  
Playback through network  
  
## 0.0.6  
  
Bytes playback  
  
## 0.0.5  
  
Added sounds to src  
  
## 0.0.4  
  
Added sounds to library  

## 0.0.3  
  
Fixed exports  
  
## 0.0.2  
  
Removed license dependency  
  
## 0.0.1  
  
First free sound library for Dart