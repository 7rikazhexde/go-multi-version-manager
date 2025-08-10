#!/bin/bash

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# メッセージ表示のヘルパー関数
print_info() {
  echo -e "${BLUE}ℹ️ $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

# Usage: source ./switch_go_version.sh 1.23.2
GO_VERSION=$1

# Ensure the script is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_error "source コマンドが必要です。"
  print_info "次のように実行してください: source $0 <go_version>"
  exit 1
fi

if [ -z "$GO_VERSION" ]; then
  print_error "Go バージョンを指定してください。"
  print_info "使用法: source $0 <go_version>"
  echo -e "例: ${CYAN}source $0 1.23.2${NC}"
  return 1
fi

# Temporarily add $HOME/go/bin to PATH
if ! echo "$PATH" | grep -q "$HOME/go/bin"; then
  print_info "$HOME/go/bin を PATH に一時的に追加します"
  export PATH="$HOME/go/bin:$PATH"
fi

# Check if goX.X.X command exists
if ! command -v "go${GO_VERSION}" &> /dev/null; then
  print_info "Go バージョン $GO_VERSION がインストールされていません。インストールを開始します..."
  
  # Get script directory relative to this script
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  
  # Install the version
  "${SCRIPT_DIR}/install_go_with_command.sh" "${GO_VERSION}"

  # Verify installation after setting PATH
  if ! command -v "go${GO_VERSION}" &> /dev/null; then
    print_error "Go $GO_VERSION のインストールに失敗しました。セットアップを確認してください。"
    return 1
  fi
  print_success "Go $GO_VERSION のインストールに成功しました"
fi

# Get the correct GOROOT for the specified version
# First, find the binary location
GO_BINARY_PATH=$(command -v "go${GO_VERSION}")

if [ -z "$GO_BINARY_PATH" ]; then
  print_error "go${GO_VERSION} バイナリが見つかりません。"
  return 1
fi

# Get GOROOT from the specific version binary
NEW_GOROOT=$("go${GO_VERSION}" env GOROOT)

if [ -z "$NEW_GOROOT" ] || [ ! -d "$NEW_GOROOT" ]; then
  print_error "Go ${GO_VERSION} の GOROOT が取得できません。"
  return 1
fi

# Update environment variables in the correct order
export GOROOT="$NEW_GOROOT"
export PATH="$NEW_GOROOT/bin:$HOME/go/bin:$PATH"

# Remove duplicate entries from PATH
PATH_TEMP=$(echo "$PATH" | awk -v RS=':' '!a[$1]++' | paste -sd:)
export PATH="$PATH_TEMP"

# Set GOPATH to default if not set
if [ -z "$GOPATH" ]; then
  export GOPATH="$HOME/go"
fi

# バージョン選択を永続化
GO_SELECTED_VERSION_FILE="$HOME/.go_selected_version"
echo "$GO_VERSION" > "$GO_SELECTED_VERSION_FILE"
print_info "Go $GO_VERSION をデフォルトのバージョンとして設定しました"

# Confirm version switch
print_success "Go $GO_VERSION に切り替えました。"
print_info "現在の Go バージョン:"
echo -e "${CYAN}$(go version)${NC}"
print_info "GOROOT: $GOROOT"
print_info "GOPATH: $GOPATH"
print_info "バイナリの場所: $(which go)"
print_warning "この設定は現在のシェルセッションのみ有効です"
print_info "デフォルト設定に戻すには: ${CYAN}source ~/.bashrc${NC}"
