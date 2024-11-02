#!/bin/bash

# Fetch available Go versions from the official download page
echo "Fetching available Go versions from https://go.dev/dl/..."

# Extract version information from the download page
wget -qO- https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+' | sort -u

echo "Go version list retrieved successfully."
