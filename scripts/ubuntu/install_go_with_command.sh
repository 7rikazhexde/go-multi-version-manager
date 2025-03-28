#!/bin/bash

# Usage: ./install_go_with_command.sh 1.23.2
GO_VERSION=$1

if [ -z "$GO_VERSION" ]; then
  echo "Usage: $0 <go_version>"
  echo "Example: $0 1.23.2"
  exit 1
fi

# Check if the go command is available
if ! command -v go &> /dev/null; then
  echo "Error: 'go' command not found. Please install Go initially using 'install_go_initial.sh' or by following the official installation steps."
  echo "You can download Go from https://go.dev/doc/install"
  exit 1
fi

# Check if the specified version is already installed
if command -v "go${GO_VERSION}" &> /dev/null; then
  echo "Go $GO_VERSION is already installed. Skipping installation."
  exit 0
fi

# Temporarily add $HOME/go/bin to PATH
export PATH="$HOME/go/bin:$PATH"

# Install Go
echo "Installing Go $GO_VERSION..."
go install golang.org/dl/go"${GO_VERSION}"@latest

# Confirm that go${GO_VERSION} command is available
if ! command -v "go${GO_VERSION}" &> /dev/null; then
  echo "Error: go${GO_VERSION} command not found after installation. Installation may have failed."
  exit 1
fi

# Download the version
echo "Downloading Go $GO_VERSION..."
go"${GO_VERSION}" download

# Installation success message with instructions
echo "Go $GO_VERSION has been installed successfully."
echo "To set up the environment variables for Go $GO_VERSION, please run 'source gomvm switch ${GO_VERSION}' in the ubuntu directory."
