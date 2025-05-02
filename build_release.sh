#!/bin/bash

set -e  # Exit immediately if a command fails

BUILD_DIR="./build/linux/x64/release/bundle"
TARGET_DIR="./release/Debian/nebulashade_1.0_x86_64/usr/local/bin"
DEB_DIR="./release/Debian/nebulashade_1.0_x86_64"
DEB_PACKAGE="nebulashade_1.0_x86_64"

# Build the Linux app
flutter build linux || { echo "Flutter build failed!"; exit 1; }

# Ensure target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Target directory $TARGET_DIR does not exist. Creating..."
    mkdir -p "$TARGET_DIR"
fi

# Remove old files safely
rm -rf "$TARGET_DIR"/*
echo "Removed Successfully: $TARGET_DIR/*"

# Copy new build files
cp -r "$BUILD_DIR"/* "$TARGET_DIR/"
echo "Successfully Copied everything to $TARGET_DIR"

# Step 6: Build the .deb package
cd ./release/Debian || { echo "Failed to change directory"; exit 1; }
dpkg-deb --build nebulashade_1.0_x86_64 || { echo "Failed to build Debian package"; exit 1; }
echo "Successfully built Debian package: $(realpath ../$DEB_PACKAGE.deb)"