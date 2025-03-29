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

# Usage: ./install_go_with_command.sh 1.23.2
GO_VERSION=$1

if [ -z "$GO_VERSION" ]; then
  print_error "バージョン番号が指定されていません。"
  print_info "使用法: $0 <go_version>"
  echo -e "例: ${CYAN}$0 1.23.2${NC}"
  exit 1
fi

# Check if the go command is available
if ! command -v go &> /dev/null; then
  print_error "'go' コマンドが見つかりません。"
  print_info "'install_go_initial.sh' または公式のインストール手順に従って、最初に Go をインストールしてください。"
  print_info "Go のダウンロードは ${CYAN}https://go.dev/doc/install${NC} から可能です。"
  exit 1
fi

# Check if the specified version is already installed
if command -v "go${GO_VERSION}" &> /dev/null; then
  print_info "Go $GO_VERSION は既にインストールされています。インストールをスキップします。"
  exit 0
fi

# Temporarily add $HOME/go/bin to PATH
print_info "\$HOME/go/bin を PATH に一時的に追加します"
export PATH="$HOME/go/bin:$PATH"

# Install Go
print_info "Go $GO_VERSION をインストールしています..."
if ! go install golang.org/dl/go"${GO_VERSION}"@latest; then
  print_error "Go $GO_VERSION のインストールに失敗しました。"
  exit 1
fi

# Confirm that go${GO_VERSION} command is available
if ! command -v "go${GO_VERSION}" &> /dev/null; then
  print_error "インストール後に go${GO_VERSION} コマンドが見つかりません。インストールに失敗した可能性があります。"
  exit 1
fi

# Download the version
print_info "Go $GO_VERSION をダウンロードしています..."
if ! go"${GO_VERSION}" download; then
  print_error "Go $GO_VERSION のダウンロードに失敗しました。"
  exit 1
fi

# Installation success message with instructions
print_success "Go $GO_VERSION が正常にインストールされました。"
print_info "Go $GO_VERSION の環境変数を設定するには、次のコマンドを実行してください:"
echo -e "  ${CYAN}source gomvm switch ${GO_VERSION}${NC}"
