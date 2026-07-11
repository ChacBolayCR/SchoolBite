#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.32.7"
FLUTTER_CACHE_ROOT="${VERCEL_CACHE_DIR:-$PWD/.vercel-cache}/flutter"
FLUTTER_HOME="$FLUTTER_CACHE_ROOT/$FLUTTER_VERSION"

echo "Using Flutter $FLUTTER_VERSION for SchoolBite Parent"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  rm -rf "$FLUTTER_HOME"
  mkdir -p "$FLUTTER_CACHE_ROOT"
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
