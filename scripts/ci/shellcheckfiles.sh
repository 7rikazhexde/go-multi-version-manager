#!/bin/bash

# Note: If shellcheck is not yet installed, run `sudo apt install shellcheck`.
# Usage: ./shellcheckfiles.sh /path/to/folder

# Check if the directory argument is provided
TARGET_DIR=$1
if [ -z "$TARGET_DIR" ]; then
  echo "Error: Please specify a directory containing .sh files."
  echo "Usage: $0 /path/to/folder"
  exit 1
fi

# Check if the specified directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Flag to track if any errors are detected
errors_found=0

# Loop through each .sh file in the specified directory
for script in "$TARGET_DIR"/*.sh; do
  if [ -f "$script" ]; then
    echo "Running shellcheck on $script..."
    shellcheck "$script"
    if [ $? -ne 0 ]; then
      errors_found=1
    fi
    echo "----------------------------------------"
  else
    echo "No .sh files found in '$TARGET_DIR'."
    exit 0
  fi
done

echo "All .sh files have been checked."

# If an error is found, return a non-zero exit code to abort the commit
exit $errors_found
