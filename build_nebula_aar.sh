#!/bin/bash
set -e

echo "==== Building Nebula VPN AAR for Flutter ===="

# Create directory for temporary files
mkdir -p temp
cd temp

# Clone Nebula mobile repo
echo "Cloning mobile_nebula repository..."
git clone https://github.com/DefinedNet/mobile_nebula.git
cd mobile_nebula/nebula

# Run make to build the AAR file
echo "Building Nebula AAR file..."
make

# Create the directory for the AAR file in your Flutter project
mkdir -p ../../../android/app/src/main/libs

# Copy the AAR file to your Flutter project
echo "Copying the AAR file to your project..."
cp mobileNebula.aar ../../../android/app/src/main/libs/

echo "Done! Nebula AAR file built and copied to android/app/src/main/libs/mobileNebula.aar"

cd ../../..