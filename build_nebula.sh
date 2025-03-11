#!/bin/bash
set -e

echo "Building Nebula VPN AAR for Flutter"
echo "=================================="

# Check if required tools are installed
command -v go >/dev/null 2>&1 || { echo "Go is not installed. Please install Go first."; exit 1; }
command -v git >/dev/null 2>&1 || { echo "Git is not installed. Please install Git first."; exit 1; }

# Install gomobile if needed
echo "Installing/updating gomobile..."
go install golang.org/x/mobile/cmd/gomobile@latest
go install golang.org/x/mobile/cmd/gobind@latest

# Initialize gomobile
export PATH=$PATH:$(go env GOPATH)/bin
echo "Initializing gomobile..."
gomobile init

# Create directory for the AAR
mkdir -p android/app/src/main/libs

# Clone Nebula mobile repo if not already present
if [ ! -d "mobile_nebula" ]; then
  echo "Cloning mobile_nebula repository..."
  git clone https://github.com/DefinedNet/mobile_nebula.git
else
  echo "mobile_nebula repository found, updating..."
  cd mobile_nebula
  git pull
  cd ..
fi

# Build the Nebula AAR file
echo "Building Nebula AAR file..."
cd mobile_nebula/nebula
make
cd ../..

# Copy the AAR file to the app
echo "Copying AAR file to project..."
cp mobile_nebula/nebula/mobileNebula.aar android/app/src/main/libs/

echo "Done! Nebula AAR file built and copied to android/app/src/main/libs/mobileNebula.aar"