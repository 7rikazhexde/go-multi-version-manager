# 🔄 go-multi-version-manager

A collection of scripts for managing, installing, and switching between multiple Go versions.

English | [日本語](README_ja.md)

## 📋 Table of Contents

- [🔄 go-multi-version-manager](#-go-multi-version-manager)
  - [📋 Table of Contents](#-table-of-contents)
  - [⚠️ Notes](#️-notes)
  - [📋 Prerequisite](#-prerequisite)
  - [📥 Installation](#-installation)
    - [🔄 Automatic Installation](#-automatic-installation)
    - [👨‍💻 Manual Installation](#-manual-installation)
    - [🗑️ Automatic Uninstallation](#️-automatic-uninstallation)
  - [🚀 Usage](#-usage)
    - [💻 Basic Commands](#-basic-commands)
    - [🔄 Switching Go Versions](#-switching-go-versions)
    - [🔍 Enabling Latest Version Check](#-enabling-latest-version-check)
  - [📜 Scripts](#-scripts)
    - [📄 install\_go\_replace\_default.sh](#-install_go_replace_defaultsh)
    - [📄 install\_go\_with\_command.sh](#-install_go_with_commandsh)
    - [📄 install\_go\_specific.sh](#-install_go_specificsh)
    - [📄 switch\_go\_version.sh](#-switch_go_versionsh)
    - [📄 list\_go\_versions.sh](#-list_go_versionssh)
  - [🛠️ Developer Options](#️-developer-options)
    - [🔗 Setting Up Pre-commit Hook for Shell Scripts](#-setting-up-pre-commit-hook-for-shell-scripts)
    - [📝 Steps to Set Up Pre-commit Hook](#-steps-to-set-up-pre-commit-hook)

## ⚠️ Notes

- These scripts are designed for **Ubuntu**; they are not supported on **Mac** and **Windows**
- For Go versions managed by `install_go_with_command.sh`, ensure `$HOME/go/bin` is included in your `PATH`
- Always verify installation with `go version` after setup
- When switching Go versions using `gomvm switch`, the selected version persists across shell sessions and `.bashrc` reloads
- For general Go installation guidance, refer to the [official Go documentation](https://go.dev/doc/install)

## 📋 Prerequisite

> [!IMPORTANT]
> gomvm automatically sets up Go environment configuration during installation. For more details, see [Go Environment Variables and PATH Configuration Guide](docs/go-environment-settings.md).

**Automatic Setup**: The installer adds the following single line to your `~/.bashrc`:

```bash
# Go環境設定 - gomvm
[ -f "$HOME/.config/gomvm/go-env.sh" ] && source "$HOME/.config/gomvm/go-env.sh"
```

This configuration enables:

- ✅ Version persistence across shell sessions
- ✅ Automatic version selection based on your saved preferences
- ✅ Clean separation of Go environment settings
- ✅ Easy maintenance through a single configuration file

**Advanced Configuration**: The actual Go environment logic is managed in `~/.config/gomvm/go-env.sh`, which provides:

- Dynamic PATH management based on selected Go version
- Fallback to system defaults when no version is selected
- Optional latest version checking (disabled by default)

> [!NOTE]
> After installation, the configuration is automatically applied. Manual setup is not required.

> [!TIP]
> If you need more details about how gomvm manages Go environment variables and PATH settings, check the [Go Environment Variables and PATH Configuration Guide](docs/go-environment-settings.md).

## 📥 Installation

### 🔄 Automatic Installation

The easiest way to set up go-multi-version-manager.  
gomvm is added to `$HOME/.local/bin/gomvm`.  
It can be added automatically by executing the following command.

```bash
# Download and run the installer script
curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh | bash

# Load updated PATH settings
source ~/.bashrc
```

### 👨‍💻 Manual Installation

Alternatively, you can clone the repository and set it up manually.

```bash
# Clone the repository
git clone https://github.com/7rikazhexde/go-multi-version-manager.git
cd go-multi-version-manager

# Set up gomvm
./gomvm setup

# Load updated PATH settings
source ~/.bashrc
```

### 🗑️ Automatic Uninstallation

To completely remove gomvm from your system, run the following command.

```bash
curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-uninstall.sh | bash
```

This uninstallation script performs the following actions.

- 🧹 Removes the gomvm repository directory from your system
- 🧹 Deletes the configuration directory (`~/.config/gomvm`)
- 🧹 Removes the gomvm binary from `~/.local/bin`
- 🧹 Cleans up Go environment settings from `~/.bashrc`

> [!WARNING]
> The uninstallation process does not remove the following.
>
> - Go versions installed in `$HOME/go/bin` (installed via `gomvm install`)
> - Go versions installed in system directories (e.g., `/usr/local/go`)
>
> If you want to completely remove everything, you can manually delete the following.
>
> 1. Go versions in `$HOME/go/bin/`
> 2. The default Go installation in `/usr/local/go`

## 🚀 Usage

### 💻 Basic Commands

After installation, you can use the following commands.

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

### 🔄 Switching Go Versions

To switch between installed Go versions.

```bash
# Switch to Go 1.24.1
source gomvm switch 1.24.1
```

The `switch` command will:

1. 🔀 Change the Go version for your current shell session
2. 💾 Save your version preference to make it persist across shell sessions
3. 🔒 Ensure the selected version remains active even after reloading `.bashrc`

> [!IMPORTANT]
> ⚠️ Always use the `source` command with `switch` to make the changes take effect in your current shell.

If you wish to return to the system default Go version, you can either:

- 🗑️ Delete the saved preference: `rm $HOME/.go_selected_version`
- 🔄 Then reload your shell: `source ~/.bashrc`

### 🔍 Enabling Latest Version Check

The latest version check feature is **disabled by default** to avoid unnecessary network requests. To enable it:

1. ✏️ Edit the Go environment configuration file:

   ```bash
   nano ~/.config/gomvm/go-env.sh
   ```

2. 🔎 Find the commented line:

   ```bash
   # source "$SCRIPT_PATH"  # この行のコメントを解除すると最新バージョンチェックが有効になります
   ```

3. 🔧 Uncomment it by removing the `#` character:

   ```bash
   source "$SCRIPT_PATH"  # 最新バージョンチェックを実行
   ```

4. 💾 Save the file and reload your configuration:

   ```bash
   source ~/.bashrc
   ```

Once enabled, this feature:

- 🔍 Checks for the latest Go version at login
- ⏱️ Only checks once per 24 hours to avoid excessive network requests
- 💡 Suggests installation if the latest version isn't installed
- 🚀 Can be forced to check using the `--force` option, ignoring the 24-hour rule

To manually check for the latest version:

```bash
source ~/path/to/go-multi-version-manager/check_latest_go.sh --force
```

## 📜 Scripts

### 📄 install_go_replace_default.sh

Installs the default version of Go in `/usr/local/go`, replacing any existing version.

Usage:

```bash
./install_go_replace_default.sh 1.23.2
```

The script will prompt you to confirm the deletion of `/usr/local/go` if it already exists, and then install the specified version.

### 📄 install_go_with_command.sh

Installs Go using the `go install` command, allowing multiple versions to be installed in `${HOME}/go/bin`.

Usage:

```bash
./install_go_with_command.sh 1.23.1
```

The script installs the specified version and places it in `${HOME}/go/bin/go<version>`.

### 📄 install_go_specific.sh

Installs a specific version of Go in `/usr/local/go<version>`. If the specified version is already installed, it will be skipped.

Usage:

```bash
./install_go_specific.sh 1.23.0
```

This script allows for multiple versions to be installed in separate directories.

### 📄 switch_go_version.sh

Switches to a specified Go version. Run this script with `source` to use the specified Go version in the current shell session and to save it as the default for future sessions. If the specified Go version is not installed, this script will automatically install it.

Usage:

```bash
source ./switch_go_version.sh 1.23.0
```

### 📄 list_go_versions.sh

Fetches a list of available Go versions from the official download page.

Usage:

```bash
./list_go_versions.sh
```

This script retrieves all available versions from the [Go download page](https://go.dev/dl/) and displays them.

## 🛠️ Developer Options

### 🔗 Setting Up Pre-commit Hook for Shell Scripts

To help maintain code quality, you can set up a `pre-commit` hook that automatically runs `shellcheck` on all shell scripts before each commit.

### 📝 Steps to Set Up Pre-commit Hook

1. Install `shellcheck`

   ```bash
   sudo apt install shellcheck
   ```

2. Add Execution Permission

   ```bash
   chmod +x scripts/ci/create_pre-commit.sh
   ```

3. Run the Create Pre-commit Script

   ```bash
   ./scripts/ci/create_pre-commit.sh
   ```

This will create a `pre-commit` hook under `.git/hooks/` that will automatically check all `.sh` files in `scripts/ubuntu` before each commit.
To run the pre-commit hook manually, execute `.git/hooks/pre-commit`.
