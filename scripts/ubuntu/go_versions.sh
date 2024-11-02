#!/bin/bash

# List installed Go versions
echo "Installed Go versions in \$HOME/go/bin:"
for go_version in "${HOME}/go/bin/go"*; do
  if [[ -x "$go_version" ]]; then
    # Extract and display the version number
    version_name=$(basename "$go_version")
    echo "$version_name"
  fi
done

# Display the currently active Go version
echo ""
echo "Current Go version in PATH:"
go version
