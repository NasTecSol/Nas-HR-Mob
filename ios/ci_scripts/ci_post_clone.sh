#!/bin/sh
set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

# Clone Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.35.6 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get

# Install CocoaPods
export COCOAPODS_DISABLE_STATS=true
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

cd ios

# Fix CocoaPods CDN timeout issue
pod repo remove master || true
pod repo add master https://github.com/CocoaPods/Specs.git

# Update repo
pod repo update master --verbose

# Clean old pods
rm -rf Pods
rm -rf Podfile.lock

# Install pods
pod install --verbose

exit 0
