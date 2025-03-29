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

# Usage: ./uninstall_go_with_command.sh 1.23.1
GO_VERSION=$1

# Check if the version argument is provided
if [ -z "${GO_VERSION}" ]; then
  print_error "Go バージョンの引数がありません。"
  print_info "使用法: $0 <go_version>"
  echo -e "例: ${CYAN}$0 1.23.1${NC}"
  exit 1
fi

# Path to the installed Go version in ${HOME}/go/bin
GO_BINARY="${HOME}/go/bin/go${GO_VERSION}"

# Check if the specified version is installed
if [ -f "${GO_BINARY}" ]; then
  # Prompt user for confirmation
  print_warning "Go バージョン ${GO_VERSION} を ${HOME}/go/bin から削除しようとしています。"
  read -r -p "本当に削除しますか？ (y/N): " confirm
  if [[ "${confirm}" =~ ^[Yy]$ ]]; then
    if rm "${GO_BINARY}"; then
      print_success "Go バージョン ${GO_VERSION} を ${HOME}/go/bin から削除しました。"
    else
      print_error "Go バージョン ${GO_VERSION} の削除に失敗しました。"
      exit 1
    fi

    # Display message to update PATH
    print_info "PATH を更新するには 'source ~/.bashrc' を実行するか、"
    print_info "'source gomvm switch <go_version>' を使用して Go バージョンを更新してください。"
  else
    print_info "アンインストールを中止しました。"
  fi
else
  print_warning "Go バージョン ${GO_VERSION} は ${HOME}/go/bin にインストールされていません。"
  print_info "インストール済みのバージョンを確認するには: ${CYAN}gomvm installed${NC}"
fi
