#!/bin/bash
set -e

HUGO_VERSION="0.160.1"
HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz"

echo "Downloading Hugo ${HUGO_VERSION}..."
curl -L -o hugo.tar.gz "$HUGO_URL"
tar -xzf hugo.tar.gz hugo
chmod +x hugo
rm hugo.tar.gz

echo "Building site..."
./hugo --minify --gc

echo "Build complete."
