# go-multi-version-manager

This repository contains scripts for managing, installing, and switching between multiple Go versions.

English | [日本語](README_ja.md)

## Table of Contents

- [go-multi-version-manager](#go-multi-version-manager)
  - [Table of Contents](#table-of-contents)
  - [Notes](#notes)
  - [Installation](#installation)
    - [Automatic Installation](#automatic-installation)
    - [Manual Installation](#manual-installation)
  - [Usage](#usage)
    - [Basic Commands](#basic-commands)
    - [Switching Go Versions](#switching-go-versions)
  - [Scripts](#scripts)
    - [install\_go\_replace\_default.sh](#install_go_replace_defaultsh)
    - [install\_go\_with\_command.sh](#install_go_with_commandsh)
    - [install\_go\_specific.sh](#install_go_specificsh)
    - [switch\_go\_version.sh](#switch_go_versionsh)
    - [list\_go\_versions.sh](#list_go_versionssh)
  - [Developer Options](#developer-options)
    - [Setting Up Pre-commit Hook for Shell Scripts](#setting-up-pre-commit-hook-for-shell-scripts)
    - [Steps to Set Up Pre-commit Hook](#steps-to-set-up-pre-commit-hook)

## Notes

- These scripts are designed for **Ubuntu**; they are not guaranteed to work on **Mac** and **Windows**.
- For the Go version managed by `install_go_with_command.sh`, make sure that `$HOME/go/bin` is included in your `PATH`[^1].
- Check the installed version using `go version` and make sure it is set up correctly.
- For a general Go installation guide, see [official Go documentation](https://go.dev/doc/install).

[^1]: `export PATH=/usr/local/go/bin:$PATH`

## Installation

### Automatic Installation

The easiest way to set up go-multi-version-manager is using the installer script:

```bash
# Download and run the installer script
curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh -o gomvm-install.sh
chmod +x gomvm-install.sh
./gomvm-install.sh

# Load updated PATH settings
source ~/.bashrc
```

### Manual Installation

Alternatively, you can clone the repository and set it up manually:

```bash
# Clone the repository
git clone https://github.com/7rikazhexde/go-multi-version-manager.git
cd go-multi-version-manager

# Set up gomvm
./gomvm setup

# Load updated PATH settings
source ~/.bashrc
```

## Usage

### Basic Commands

After installation, you can use the following commands:

```bash
# List available Go versions
gomvm list

# Install a specific Go version
gomvm install 1.24.1

# List installed Go versions
gomvm installed

# Uninstall a specific Go version
gomvm uninstall 1.24.1
```

### Switching Go Versions

To switch between installed Go versions, use the `source` command with `gomvm switch`:

```bash
# Switch to Go 1.24.1
source gomvm switch 1.24.1
```

> [!IMPORTANT]
> Always use the `source` command with `switch` to make the changes take effect in your current shell.

## Scripts

The following scripts are used internally by the `gomvm` command, but can also be used directly if needed:

### install_go_replace_default.sh

Installs the default version of Go in `/usr/local/go`, replacing any existing version.

Usage

```bash
./install_go_replace_default.sh <go_version>
```

- Example: `./install_go_replace_default.sh 1.23.2`

The script will prompt you to confirm the deletion of `/usr/local/go` if it already exists, and then install the specified version.

---

### install_go_with_command.sh

Installs Go using the `go install` command, allowing multiple versions to be installed in `${HOME}/go/bin`.

Usage

```bash
./install_go_with_command.sh <go_version>
```

- Example: `./install_go_with_command.sh 1.23.1`

The script installs the specified version using `go install` and places it in `${HOME}/go/bin/go<version>`.

---

### install_go_specific.sh

Installs a specific version of Go in `/usr/local/go<version>`. If the specified version is already installed, it will be skipped.

Usage

```bash
./install_go_specific.sh <go_version>
```

- Example: `./install_go_specific.sh 1.23.0`

This script allows for multiple versions to be installed in separate directories.

---

### switch_go_version.sh

Switches to a specified Go version. Run this script with source to use the specified Go version in the current shell session. If the specified Go version is not installed, this script will execute install_go_with_command.sh internally to install it.

Usage

```bash
source ./switch_go_version.sh <go_version>
```

- Example: `source ./switch_go_version.sh 1.23.0`

To return to the default version set in `.bashrc`, run `source ~/.bashrc`.

---

### list_go_versions.sh

Fetches a list of available Go versions from the official download page.

Usage

```bash
./list_go_versions.sh
```

This script retrieves all available versions from the [Go download page](https://go.dev/dl/) and displays them.

---

## Developer Options

### Setting Up Pre-commit Hook for Shell Scripts

To help maintain code quality, you can set up a `pre-commit` hook that automatically runs `shellcheck` on all shell scripts before each commit. This will prevent commits if `shellcheck` finds any issues, ensuring that only error-free scripts are committed.

### Steps to Set Up Pre-commit Hook

1. Install `shellcheck`

  Make sure `shellcheck` is installed on your system. If it is not installed, use the following command to install it.

  ```bash
  sudo apt install shellcheck
  ```

1. Add Execution Permission

  First, make sure the `create_pre-commit.sh` script has execution permission:

  ```bash
  chmod +x scripts/ci/create_pre-commit.sh
  ```

1. Run the `create_pre-commit.sh` script

  Execute the following command from the root directory of the project to set up the `pre-commit` hook

  ```bash
  ./scripts/ci/create_pre-commit.sh
  ```

  This will create a `pre-commit` hook under `.git/hooks/`. The hook will automatically execute `shellcheck` on all `.sh` files located in `scripts/ubuntu` each time a commit is attempted.  
  If you want to run the `pre-commit` hook manually before committing, run `.git/hooks/pre-commit`.
