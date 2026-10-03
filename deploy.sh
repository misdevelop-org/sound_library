#!/bin/zsh
# Manual release: bump pubspec.yaml + CHANGELOG.md first, then run this script.
# The live app (sounds.library.misdevelop.com) is deployed by .github/workflows/web_deploy_dev.yml on push to main.
set -e
flutter pub get
dart format -l 120 lib test example/lib example/test
flutter analyze
flutter test
flutter pub publish --dry-run
flutter pub publish
