#!/bin/bash

# Build script for LivingRoom app

APP_NAME="LivingRoom"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building $APP_NAME..."

# Clean and create directories
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compile Swift application
swiftc LivingRoomApp.swift -o "$MACOS_DIR/$APP_NAME" -framework Cocoa

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# Copy Info.plist
cp Info.plist "$CONTENTS_DIR/"

# Copy resources
cp AirPlay.scpt "$RESOURCES_DIR/"
cp LivingRoom.icns "$RESOURCES_DIR/"

# Set executable permissions
chmod +x "$MACOS_DIR/$APP_NAME"

# Sign the app bundle
codesign --force --deep --sign - "$APP_BUNDLE"

echo "Build complete! Application bundle created at: $APP_BUNDLE"
echo ""
echo "To run the app:"
echo "  open $APP_BUNDLE"
echo ""
echo "To install to Applications folder:"
echo "  cp -r $APP_BUNDLE /Applications/"
