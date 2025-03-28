#!/bin/bash

# Usage: ./uninstall_go_with_command.sh 1.23.1
GO_VERSION=$1

# Check if the version argument is provided
if [ -z "${GO_VERSION}" ]; then
  echo "Error: Missing Go version argument."
  echo "Usage: $0 <go_version>"
  echo "Example: $0 1.23.1"
  exit 1
fi

# Path to the installed Go version in ${HOME}/go/bin
GO_BINARY="${HOME}/go/bin/go${GO_VERSION}"

# Check if the specified version is installed
if [ -f "${GO_BINARY}" ]; then
  # Prompt user for confirmation
  read -r -p "Are you sure you want to remove Go version ${GO_VERSION} from ${HOME}/go/bin? (y/N): " confirm
  if [[ "${confirm}" =~ ^[Yy]$ ]]; then
    rm "${GO_BINARY}"
    echo "Go version ${GO_VERSION} has been removed from ${HOME}/go/bin."

    # Display message to update PATH
    echo "Please run 'source ~/.bashrc' or use 'source gomvm switch <go_version>' to update your Go version."
  else
    echo "Uninstallation aborted."
  fi
else
  echo "Go version ${GO_VERSION} is not installed in ${HOME}/go/bin."
fi
