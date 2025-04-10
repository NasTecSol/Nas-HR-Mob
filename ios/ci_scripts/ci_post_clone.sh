#!/bin/sh

set -e

# Change working directory to the root of your cloned repo.
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Clone Flutter SDK (custom repo or standard one).
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.29.4 $HOME/flutter

# Add Flutter to PATH.
export PATH="$PATH:$HOME/flutter/bin"

# Pre-cache Flutter artifacts for iOS.
flutter precache --ios

# Install Flutter package dependencies.
flutter pub get

# Install CocoaPods via Homebrew without auto-updating Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

# Navigate to the iOS directory and install pod dependencies.
cd ios
pod install

# Exit script successfully.
exit 0
