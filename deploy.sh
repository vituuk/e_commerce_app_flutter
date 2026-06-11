#!/bin/bash
# One-command deploy: Flutter Web → Vercel (e-commerce-app-flutter)
# Usage: bash deploy.sh

set -e

echo "🔨 Building Flutter Web..."
flutter build web --release

echo "🚀 Deploying to Vercel (e-commerce-app-flutter)..."
cd build/web
cmd /c "npx vercel --prod --yes"

echo "✅ Live at https://e-commerce-app-flutter.vercel.app"
