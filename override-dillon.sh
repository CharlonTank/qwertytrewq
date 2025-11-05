#!/bin/bash
# Script to set up local Lamdera package overrides
#
# Usage from your lamdera app directory:
#   ./override-dillon.sh <package-root>
#
# Example: ./override-dillon.sh ../../

set -e

if [ $# -eq 0 ]; then
  echo "Error: Package root directory required"
  echo "Usage: $0 <package-root>"
  exit 1
fi

PACKAGE_ROOT="$1"
APP_ROOT="$(pwd)"

# Verify package root exists
if [ ! -f "$PACKAGE_ROOT/elm.json" ]; then
  echo "Error: elm.json not found at $PACKAGE_ROOT"
  exit 1
fi

# Extract package info using jq
PACKAGE_NAME=$(jq -r '.name' "$PACKAGE_ROOT/elm.json")
VERSION=$(jq -r '.version' "$PACKAGE_ROOT/elm.json")

if [ -z "$PACKAGE_NAME" ] || [ -z "$VERSION" ] || [ "$PACKAGE_NAME" = "null" ] || [ "$VERSION" = "null" ]; then
  echo "Error: Could not read package name or version from elm.json"
  exit 1
fi

# Split package name into author/package
AUTHOR=$(echo "$PACKAGE_NAME" | cut -d'/' -f1)
PACKAGE=$(echo "$PACKAGE_NAME" | cut -d'/' -f2)

echo "Setting up override for $PACKAGE_NAME $VERSION"
echo ""

# Setup override directory structure
OVERRIDE_BASE="$APP_ROOT/overrides/packages/$AUTHOR/$PACKAGE"
OVERRIDE_DIR="$OVERRIDE_BASE/$VERSION"

mkdir -p "$OVERRIDE_DIR"

# Copy source files
echo "Syncing source files..."
rsync -a --delete "$PACKAGE_ROOT/src/" "$OVERRIDE_DIR/src/"
rsync -a "$PACKAGE_ROOT/elm.json" "$OVERRIDE_DIR/elm.json"

# Build the override package
echo "Building override package..."
rm -rf "$OVERRIDE_DIR/elm-stuff"
(cd "$OVERRIDE_DIR" && lamdera make)
(cd "$OVERRIDE_BASE" && rm -f pack.zip && zip -r pack.zip "$VERSION/" -x "*/.git/*" -x "*/elm-stuff/*" > /dev/null)

# Generate endpoint.json
HASH=$(cd "$OVERRIDE_BASE" && shasum pack.zip | cut -d' ' -f1)
(cd "$OVERRIDE_BASE" && echo "{\"url\":\"https://static.lamdera.com/r/$PACKAGE_NAME/pack.zip\",\"hash\":\"$HASH\"}" > "$VERSION/endpoint.json")

# Clean caches
echo "Cleaning caches..."
rm -rf ~/.elm
rm -rf elm-stuff
yes | lamdera reset > /dev/null 2>&1

LDEBUG=1 EXPERIMENTAL=1 LOVR="$APP_ROOT/overrides" lamdera live
