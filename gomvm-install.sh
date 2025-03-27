#!/bin/bash
# gomvm-install.sh - Go Multi Version Manager インストーラー

set -e

# 自動モードかどうかを確認
AUTO_MODE=0
if [ "$1" = "-y" ] || [ "$1" = "--yes" ]; then
  AUTO_MODE=1
fi

# curl | bash で実行された場合のディレクトリ処理
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "$0" ]; then
  # スクリプトがパイプから実行された場合、一時ディレクトリを作成
  if [ -t 0 ]; then
    # 通常の実行
    :
  else
    # パイプからの実行
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    trap 'cd - > /dev/null; rm -rf "$TMP_DIR"' EXIT
    AUTO_MODE=1
  fi
fi

echo "==== Go Multi Version Manager (gomvm) インストーラー ===="
echo ""

# リポジトリのクローン先を指定
INSTALL_DIR="${HOME}/golang/go-multi-version-manager"

# 自動モードでない場合、インストール先を確認
if [ $AUTO_MODE -eq 0 ]; then
  read -r -p "インストール先 [$INSTALL_DIR]: " custom_dir
  if [ -n "$custom_dir" ]; then
    INSTALL_DIR="$custom_dir"
  fi
fi

# ディレクトリを作成
mkdir -p "$(dirname "$INSTALL_DIR")"

# リポジトリのクローン/更新
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "既存のリポジトリを更新しています..."
  cd "$INSTALL_DIR"
  git pull origin main
else
  echo "リポジトリをクローンしています..."
  git clone https://github.com/7rikazhexde/go-multi-version-manager.git "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# gomvm スクリプトを作成
echo "gomvm スクリプトを作成しています..."
cat > gomvm << 'EOF'
#!/bin/bash

# gomvm - Go Multi Version Manager
# A wrapper script for managing multiple Go versions

# 安全な終了処理のための関数
safe_exit() {
  # スクリプトが source で実行された場合は return を使用
  # そうでない場合は exit を使用
  if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    return "$1"
  else
    exit "$1"
  fi
}

# Dynamic configuration - automatically find the script directory
# Try to load the configuration file if it exists
GOMVM_CONFIG_DIR="$HOME/.config/gomvm"
GOMVM_CONFIG_FILE="$GOMVM_CONFIG_DIR/config"

if [ -f "$GOMVM_CONFIG_FILE" ]; then
  # shellcheck source=/dev/null
  source "$GOMVM_CONFIG_FILE" || echo "Warning: Failed to source config file"
fi

# If the environment variable is set, use it
if [ -n "$GOMVM_SCRIPTS_DIR" ]; then
  SCRIPT_DIR="$GOMVM_SCRIPTS_DIR"
else
  # Try to find the script directory based on this script's location
  REAL_PATH="$(readlink -f "$0")"
  
  # Try various possible locations for the scripts
  for dir in \
    "$(dirname "$(dirname "$REAL_PATH")")/scripts/ubuntu" \
    "$(dirname "$REAL_PATH")/scripts/ubuntu" \
    "$HOME/go-multi-version-manager/scripts/ubuntu" \
    "$HOME/golang/go-multi-version-manager/scripts/ubuntu"; do
    if [ -d "$dir" ]; then
      SCRIPT_DIR="$dir"
      break
    fi
  done
fi

# Verify the SCRIPT_DIR exists and contains required scripts
if [ -z "$SCRIPT_DIR" ] || [ ! -d "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/switch_go_version.sh" ]; then
  echo "Error: Could not locate the scripts directory or missing required scripts."
  echo "Please set the GOMVM_SCRIPTS_DIR environment variable to the path of the ubuntu scripts directory."
  echo "Example: export GOMVM_SCRIPTS_DIR=/path/to/go-multi-version-manager/scripts/ubuntu"
  safe_exit 1
fi

# Help function
show_help() {
  echo "Go Multi Version Manager (gomvm)"
  echo ""
  echo "Usage:"
  echo "  gomvm install <version>  - Install Go version"
  echo "  gomvm switch <version>   - Switch to Go version (use with 'source')"
  echo "  gomvm list               - List available Go versions"
  echo "  gomvm installed          - List installed Go versions"
  echo "  gomvm uninstall <version> - Uninstall Go version"
  echo "  gomvm setup              - Setup gomvm for current user"
  echo "  gomvm uninstall-self     - Uninstall gomvm itself"
  echo "  gomvm help               - Show this help message"
  echo ""
  echo "Examples:"
  echo "  gomvm install 1.24.1     - Install Go 1.24.1"
  echo "  source gomvm switch 1.24.1 - Switch to Go 1.24.1"
}

# Function to execute a script with arguments
run_script() {
  local script="$1"
  shift
  
  # Check if the script exists
  if [ ! -f "${SCRIPT_DIR}/${script}" ]; then
    echo "Error: Script ${script} not found in ${SCRIPT_DIR}"
    safe_exit 1
  fi
  
  if [[ "$script" == "switch_go_version.sh" ]]; then
    # 安全に実行するための処理
    # 元のスクリプトの代わりに直接処理を行う
    switch_go_directly "$@"
  else
    # For other scripts, we can execute them directly
    "${SCRIPT_DIR}/${script}" "$@" || {
      echo "Error: Script ${script} failed with exit code $?"
      safe_exit 1
    }
  fi
}

# Safer alternative to switch_go_version.sh
switch_go_directly() {
  local GO_VERSION=$1
  
  if [ -z "$GO_VERSION" ]; then
    echo "Error: Missing Go version argument."
    echo "Usage: source gomvm switch <go_version>"
    safe_exit 1
  fi
  
  # Temporarily add $HOME/go/bin to PATH
  if ! echo "$PATH" | grep -q "$HOME/go/bin"; then
    export PATH="$HOME/go/bin:$PATH"
  fi
  
  # Check if goX.X.X command exists
  if ! command -v "go${GO_VERSION}" &> /dev/null; then
    echo "Go version $GO_VERSION is not installed. Installing..."
    "${SCRIPT_DIR}/install_go_with_command.sh" "${GO_VERSION}" || {
      echo "Installation of Go $GO_VERSION failed. Please check your setup."
      safe_exit 1
    }
    
    # Verify installation after setting PATH
    if ! command -v "go${GO_VERSION}" &> /dev/null; then
      echo "Installation verification failed. Please check your PATH settings."
      safe_exit 1
    fi
  fi
  
  # Set GOROOT for the specified version
  local GOROOT
  GOROOT=$(go"${GO_VERSION}" env GOROOT)
  
  # Update GOROOT and PATH for the current shell session only
  export GOROOT="$GOROOT"
  export PATH="$GOROOT/bin:$PATH"
  
  # Confirm version switch
  echo "Switched to Go $GO_VERSION."
  go version
}

# Main command handler
case "$1" in
  "install")
    if [ -z "$2" ]; then
      echo "Error: Version number required."
      echo "Usage: gomvm install <version>"
      safe_exit 1
    fi
    run_script "install_go_with_command.sh" "$2"
    ;;
  
  "replace-default")
    if [ -z "$2" ]; then
      echo "Error: Version number required."
      echo "Usage: gomvm replace-default <version>"
      safe_exit 1
    fi
    run_script "install_go_replace_default.sh" "$2"
    ;;
    
  "install-specific")
    if [ -z "$2" ]; then
      echo "Error: Version number required."
      echo "Usage: gomvm install-specific <version>"
      safe_exit 1
    fi
    run_script "install_go_specific.sh" "$2"
    ;;
    
  "switch")
    if [ -z "$2" ]; then
      echo "Error: Version number required."
      echo "Usage: source gomvm switch <version>"
      safe_exit 1
    fi
    
    # スクリプトが source で実行されたかを確認
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
      echo "Warning: 'gomvm switch' must be run with 'source' to affect the current shell."
      echo "Please run: source gomvm switch $2"
      safe_exit 1
    fi
    
    switch_go_directly "$2"
    ;;
    
  "list")
    run_script "list_go_versions.sh"
    ;;
    
  "installed")
    run_script "go_versions.sh"
    ;;
    
  "uninstall")
    if [ -z "$2" ]; then
      echo "Error: Version number required."
      echo "Usage: gomvm uninstall <version>"
      safe_exit 1
    fi
    run_script "uninstall_go_with_command.sh" "$2"
    ;;
    
  "setup")
    # Setup gomvm for current user
    echo "Setting up gomvm for current user..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    
    # Copy or create a symlink to this script
    SCRIPT_PATH="$(readlink -f "$0")"
    TARGET_PATH="$HOME/.local/bin/gomvm"
    
    if [ "$SCRIPT_PATH" != "$TARGET_PATH" ]; then
      cp "$SCRIPT_PATH" "$TARGET_PATH"
      chmod +x "$TARGET_PATH"
      echo "Copied gomvm to $TARGET_PATH"
    else
      echo "gomvm is already installed at $TARGET_PATH"
    fi
    
    # Check if PATH includes ~/.local/bin
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
      echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
      echo "Added \$HOME/.local/bin to PATH in ~/.bashrc"
      echo "Please run 'source ~/.bashrc' to update your current session"
    else
      echo "\$HOME/.local/bin is already in PATH"
    fi
    
    # Store the scripts directory in user config
    mkdir -p "$GOMVM_CONFIG_DIR"
    echo "GOMVM_SCRIPTS_DIR=\"$SCRIPT_DIR\"" > "$GOMVM_CONFIG_FILE"
    echo "Configuration saved to $GOMVM_CONFIG_FILE"
    
    echo ""
    echo "gomvm has been set up successfully!"
    echo "You can now use 'gomvm' from anywhere."
    echo "To switch Go versions, use: source gomvm switch <version>"
    echo "Example: source gomvm switch 1.24.0"
    echo "Current scripts directory: $SCRIPT_DIR"
    ;;
  
  "uninstall-self")
    # Uninstall gomvm
    echo "Uninstalling gomvm..."
    
    # Confirm uninstallation
    read -r -p "Are you sure you want to uninstall gomvm? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Uninstallation cancelled."
      safe_exit 0
    fi
    
    # Remove gomvm binary
    if [ -f "$HOME/.local/bin/gomvm" ]; then
      rm -f "$HOME/.local/bin/gomvm"
      echo "Removed gomvm binary from $HOME/.local/bin/gomvm"
    else
      echo "gomvm binary not found in $HOME/.local/bin"
    fi
    
    # Remove configuration
    if [ -d "$GOMVM_CONFIG_DIR" ]; then
      rm -rf "$GOMVM_CONFIG_DIR"
      echo "Removed configuration directory $GOMVM_CONFIG_DIR"
    fi
    
    echo ""
    echo "gomvm has been uninstalled successfully."
    echo "Note: The Go version installations and repository remain untouched."
    echo "To completely remove everything, you can also delete:"
    echo "1. The repository directory containing the scripts"
    echo "2. The Go versions in $HOME/go/bin/ (if installed with 'gomvm install')"
    ;;
    
  "help"|"--help"|"-h")
    show_help
    ;;
    
  *)
    echo "Unknown command: $1"
    show_help
    safe_exit 1
    ;;
esac

safe_exit 0
EOF

# スクリプトに実行権限を付与
chmod +x gomvm

# セットアップを実行
echo "gomvm のセットアップを実行しています..."
./gomvm setup

echo ""
echo "==== インストール完了 ===="
echo "使用例:"
echo "  gomvm list               - 利用可能なGoバージョンを一覧表示"
echo "  gomvm install 1.24.1     - Go 1.24.1をインストール" 
echo "  source gomvm switch <version> - 指定したGoバージョンに切り替え"
echo "  gomvm installed          - インストール済みのGoバージョンを表示"
echo ""
echo "インストール完了しました。次のコマンドを実行して設定を反映してください："
echo "  source ~/.bashrc"