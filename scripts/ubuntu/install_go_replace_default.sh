#!/bin/bash

# Usage: ./install_go_replace_default.sh 1.23.2
GO_VERSION=$1

if [ -z "$GO_VERSION" ]; then
  echo "Usage: $0 <go_version>"
  echo "Example: $0 1.23.2"
  exit 1
fi

# Check for the existing /usr/local/go directory
if [ -d "/usr/local/go" ]; then
  read -r -p "/usr/local/go already exists. Do you want to remove it and proceed with the installation of Go ${GO_VERSION}? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
  fi
  # Remove the directory
  sudo rm -rf /usr/local/go
  echo "/usr/local/go has been removed."
fi

# Download and install Go
echo "Downloading Go ${GO_VERSION}..."
wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"

echo "Installing Go ${GO_VERSION} to /usr/local..."
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"

# Set up environment variables
if ! echo "$PATH" | grep -q ':/usr/local/go/bin'; then
  echo "To use Go, add it to your PATH by running:"
  echo "  echo 'export PATH=/usr/local/go/bin:\$PATH' >> ~/.bashrc"
  echo "Then apply the changes with:"
  echo "  source ~/.bashrc"
  echo "Finally, verify the installation with:"
  echo "  go version"
else
  echo "/usr/local/go/bin is already in PATH"
  go version
  echo "Go ${GO_VERSION} has been installed to /usr/local."
fi
