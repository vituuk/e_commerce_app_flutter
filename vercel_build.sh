#!/bin/bash
set -e

echo "🐦 Installing Flutter SDK..."

FLUTTER_VERSION="3.32.2"
FLUTTER_DIR="$HOME/flutter"

# Download Flutter stable release
curl -fsSL \
  "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
  -o flutter.tar.xz

echo "📦 Extracting Flutter..."
tar xf flutter.tar.xz -C "$HOME"
rm flutter.tar.xz

export PATH="$PATH:$FLUTTER_DIR/bin"

echo "✅ Flutter version:"
flutter --version --no-version-check

echo "⚙️  Pre-caching web tools..."
flutter precache --web --no-version-check

echo "📥 Getting dependencies..."
flutter pub get --no-version-check

echo "🔨 Building Flutter Web..."
flutter build web --release --no-tree-shake-icons --no-version-check

echo "🎉 Build complete! Output in build/web"
