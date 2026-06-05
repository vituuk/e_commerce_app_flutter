#!/bin/bash
# One-command deploy script for Flutter Web → Vercel
# Usage: bash deploy.sh

set -e

echo "🔨 Building Flutter Web..."
flutter build web --release

echo "🚀 Deploying to Vercel..."
cmd /c "npx vercel build/web --prod --yes"

echo "✅ Deploy complete!"
