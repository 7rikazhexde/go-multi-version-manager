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

# Usage: ./install_go_replace_default.sh 1.23.2
GO_VERSION=$1

if [ -z "$GO_VERSION" ]; then
  print_error "バージョン番号が指定されていません。"
  print_info "使用法: $0 <go_version>"
  echo -e "例: ${CYAN}$0 1.23.2${NC}"
  exit 1
fi

# Check for the existing /usr/local/go directory
if [ -d "/usr/local/go" ]; then
  print_warning "/usr/local/go は既に存在します。"
  read -r -p "これを削除して Go ${GO_VERSION} のインストールを続行しますか？ (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_info "インストールを中止しました。"
    exit 1
  fi
  # Remove the directory
  print_info "/usr/local/go を削除しています..."
  sudo rm -rf /usr/local/go
  print_success "/usr/local/go を削除しました。"
fi

# Download and install Go
print_info "Go ${GO_VERSION} をダウンロードしています..."
if ! wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"; then
  print_error "Go ${GO_VERSION} のダウンロードに失敗しました。"
  print_info "指定したバージョンが存在するか確認してください: ${CYAN}gomvm list${NC}"
  exit 1
fi

print_info "Go ${GO_VERSION} を /usr/local にインストールしています..."
if ! sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"; then
  print_error "Go ${GO_VERSION} のインストールに失敗しました。"
  exit 1
fi
rm "go${GO_VERSION}.linux-amd64.tar.gz"

# Set up environment variables
if ! echo "$PATH" | grep -q ':/usr/local/go/bin'; then
  print_info "Go を使用するには、PATH に追加する必要があります:"
  echo -e "  ${CYAN}echo 'export PATH=/usr/local/go/bin:\$PATH' >> ~/.bashrc${NC}"
  print_info "その後、以下のコマンドで変更を適用してください:"
  echo -e "  ${CYAN}source ~/.bashrc${NC}"
  print_info "最後に、以下のコマンドでインストールを確認してください:"
  echo -e "  ${CYAN}go version${NC}"
else
  print_info "/usr/local/go/bin は既に PATH に含まれています"
  go version
  print_success "Go ${GO_VERSION} が /usr/local にインストールされました。"
fi
