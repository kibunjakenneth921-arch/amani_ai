#!/usr/bin/env bash
set -e

if [ ! -x "$(command -v flutter)" ]; then
  if [ ! -d flutter ]; then
    git clone https://github.com/flutter/flutter.git -b stable flutter
  fi
  export PATH="$PWD/flutter/bin:$PATH"
fi

flutter --version
flutter channel stable
flutter upgrade --force
flutter pub get

build_args=""
if [ -n "$GEMINI_API_KEY" ]; then
  build_args="$build_args --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY"
fi
if [ -n "$GEMINI_API_URL" ]; then
  build_args="$build_args --dart-define=GEMINI_API_URL=$GEMINI_API_URL"
fi
if [ -n "$OPENAI_API_KEY" ]; then
  build_args="$build_args --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY"
fi

flutter build web --release $build_args
