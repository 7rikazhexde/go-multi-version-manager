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

# Usage: ./install_go_specific.sh 1.23.2
GO_VERSION=$1

if [ -z "$GO_VERSION" ]; then
  print_error "バージョン番号が指定されていません。"
  print_info "使用法: $0 <go_version>"
  echo -e "例: ${CYAN}$0 1.23.2${NC}"
  exit 1
fi

# Set the installation directory
INSTALL_DIR="/usr/local/go${GO_VERSION}"

# Check if the version is already installed
if [ -d "$INSTALL_DIR" ]; then
  print_info "Go $GO_VERSION は既に $INSTALL_DIR にインストールされています。インストールをスキップします。"
  exit 0
fi

# Download Go
print_info "Go $GO_VERSION をダウンロードしています..."
if ! wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"; then
  print_error "Go $GO_VERSION のダウンロードに失敗しました。"
  print_info "指定したバージョンが存在するか確認してください: ${CYAN}gomvm list${NC}"
  exit 1
fi

# Extract and install to the specified directory
print_info "Go $GO_VERSION を $INSTALL_DIR にインストールしています..."
sudo mkdir -p "$INSTALL_DIR"
if ! sudo tar -C "$INSTALL_DIR" --strip-components=1 -xzf "go${GO_VERSION}.linux-amd64.tar.gz"; then
  print_error "Go $GO_VERSION のインストールに失敗しました。"
  exit 1
fi
rm "go${GO_VERSION}.linux-amd64.tar.gz"

# Verify installation
if [ -x "$INSTALL_DIR/bin/go" ]; then
  print_success "Go $GO_VERSION のインストールが完了しました。"
  print_info "インストールされたバージョン:"
  echo -e "${CYAN}$("$INSTALL_DIR/bin/go" version)${NC}"
  print_info "このバージョンを使用するには、以下のコマンドを実行してください:"
  echo -e "  ${CYAN}export PATH=$INSTALL_DIR/bin:\$PATH${NC}"
  print_info "または、このバージョンに完全に切り替えるには:"
  echo -e "  ${CYAN}export GOROOT=$INSTALL_DIR${NC}"
  echo -e "  ${CYAN}export PATH=\$GOROOT/bin:\$PATH${NC}"
else
  print_error "インストール後にGoバイナリが見つかりません。インストールに失敗した可能性があります。"
  exit 1
fi
