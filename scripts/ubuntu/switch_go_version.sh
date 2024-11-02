#!/bin/bash

# Usage: source ./switch_go_version.sh 1.23.2
GO_VERSION=$1

# Ensure the script is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Error: source command is required."
  echo "Please run it as: source $0 <go_version>"
  exit 1
fi

if [ -z "$GO_VERSION" ]; then
  echo "Usage: source $0 <go_version>"
  echo "Example: source $0 1.23.2"
  return 1
fi

# Temporarily add $HOME/go/bin to PATH
export PATH="$HOME/go/bin:$PATH"

# Check if goX.X.X command exists
if ! command -v "go${GO_VERSION}" &> /dev/null; then
  echo "Go version $GO_VERSION is not installed. Installing..."
  ./install_go_with_command.sh "${GO_VERSION}"

  # Verify installation after setting PATH
  if ! command -v "go${GO_VERSION}" &> /dev/null; then
    echo "Installation of Go $GO_VERSION failed. Please check your setup."
    return 1
  fi
fi

# Set GOROOT for the specified version
GOROOT=$(go"${GO_VERSION}" env GOROOT)

# Update GOROOT and PATH for the current shell session only
export GOROOT="$GOROOT"
export PATH="$GOROOT/bin:$PATH"

# Confirm version switch
echo "Switched to Go $GO_VERSION."
go version
