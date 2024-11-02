#!/bin/bash

# Usage: ./install_go_specific.sh 1.23.2
GO_VERSION=$1

if [ -z "$GO_VERSION" ]; then
  echo "Usage: $0 <go_version>"
  echo "Example: $0 1.23.2"
  exit 1
fi

# Set the installation directory
INSTALL_DIR="/usr/local/go${GO_VERSION}"

# Check if the version is already installed
if [ -d "$INSTALL_DIR" ]; then
  echo "Go $GO_VERSION is already installed in $INSTALL_DIR. Skipping installation."
  exit 0
fi

# Download Go
echo "Downloading Go $GO_VERSION..."
wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"

# Extract and install to the specified directory
echo "Installing Go $GO_VERSION to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo tar -C "$INSTALL_DIR" --strip-components=1 -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"

# Verify installation
"$INSTALL_DIR/bin/go" version
echo "Go $GO_VERSION has been installed to $INSTALL_DIR."
