#!/bin/bash

# Download Flutter if it's not already cached
if test -d "flutter"; then
  echo "Flutter already installed."
else
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Add flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

# Build the web app
flutter build web --release
