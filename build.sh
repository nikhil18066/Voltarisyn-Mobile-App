#!/bin/bash
set -e

# Download Flutter if it's not already cached
if test -d "flutter"; then
  echo "Flutter already installed."
else
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add flutter to path
export PATH="$PATH:$(pwd)/flutter/bin"

# Disable Flutter analytics for CI
flutter config --no-analytics

# Print Flutter version for debugging
flutter --version

# Create the .env file from Vercel's environment variables
# This MUST exist before 'flutter pub get' / 'flutter build web'
# because it is listed as an asset in pubspec.yaml
echo "GROQ_API_KEY=${GROQ_API_KEY:-}" > .env

# Get dependencies
flutter pub get

# Build the web app
flutter build web --release
