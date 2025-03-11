#!/bin/bash
set -e

# Install gomobile if needed
go install golang.org/x/mobile/cmd/gomobile@latest
go install golang.org/x/mobile/cmd/gobind@latest

# Initialize gomobile
export PATH=$PATH:$(go env GOPATH)/bin
gomobile init

# Create directory for the AAR
mkdir -p android/app/src/main/libs

# Build the AAR file
echo "Building AAR file..."
cd go
gomobile bind -target=android -androidapi 21 -o ../android/app/src/main/libs/gomain.aar ./src/gomain
cd ..

echo "AAR file built at android/app/src/main/libs/gomain.aar"