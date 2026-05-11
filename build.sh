#!/bin/bash

# Download Flutter if it's not already cached
if test -d "flutter"; then
  echo "Flutter already installed."
else
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Add flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

# Create the .env file from Vercel's environment variables
echo "GROQ_API_KEY=$GROQ_API_KEY" > .env

# Build the web app
flutter build web --release
