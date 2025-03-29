#!/bin/bash
# gomvm-uninstall.sh - Go Multi Version Manager アンインストーラー

set -e

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
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

print_header() {
  echo -e "${BOLD}${PURPLE}$1${NC}"
}

print_header "==== Go Multi Version Manager (gomvm) アンインストーラー ===="
echo ""

# gomvm の構成ディレクトリとバイナリのパス
GOMVM_CONFIG_DIR="$HOME/.config/gomvm"
GOMVM_CONFIG_FILE="$GOMVM_CONFIG_DIR/config"
GOMVM_BINARY="$HOME/.local/bin/gomvm"

# 設定ファイルから GOMVM_SCRIPTS_DIR を取得
if [ -f "$GOMVM_CONFIG_FILE" ]; then
  # shellcheck source=/dev/null
  source "$GOMVM_CONFIG_FILE"
  if [ -n "$GOMVM_SCRIPTS_DIR" ]; then
    # GOMVM_SCRIPTS_DIR から INSTALL_DIR を逆算（scripts/ubuntu を取り除く）
    INSTALL_DIR=$(dirname "$(dirname "$GOMVM_SCRIPTS_DIR")")
    print_info "設定ファイルから検出したインストール先: $INSTALL_DIR"
  else
    print_warning "設定ファイルに GOMVM_SCRIPTS_DIR が定義されていません。"
  fi
fi

# INSTALL_DIR が未定義の場合、ユーザーに手動で指定させる
if [ -z "$INSTALL_DIR" ]; then
  while true; do
    read -r -p "📂 削除する gomvm のインストール先を指定してください（例: ${CYAN}$HOME/golang${NC}）: " INSTALL_DIR < /dev/tty
    if [ -n "$INSTALL_DIR" ]; then
      break
    else
      print_error "インストール先を指定する必要があります。"
    fi
  done
  # ユーザーが指定したパスに "go-multi-version-manager" を追加
  INSTALL_DIR="${INSTALL_DIR}/go-multi-version-manager"
fi

# インストール先の存在確認
if [ ! -d "$INSTALL_DIR" ]; then
  print_warning "指定されたインストール先 ($INSTALL_DIR) が見つかりません。"
else
  print_info "リポジトリディレクトリを削除しています: $INSTALL_DIR"
  if rm -rf "$INSTALL_DIR"; then
    print_success "リポジトリディレクトリを正常に削除しました。"
  else
    print_error "リポジトリディレクトリの削除に失敗しました。"
    exit 1
  fi
fi

# 構成ディレクトリの削除
if [ -d "$GOMVM_CONFIG_DIR" ]; then
  print_info "構成ディレクトリを削除しています: $GOMVM_CONFIG_DIR"
  if rm -rf "$GOMVM_CONFIG_DIR"; then
    print_success "構成ディレクトリを正常に削除しました。"
  else
    print_error "構成ディレクトリの削除に失敗しました。"
    exit 1
  fi
else
  print_info "構成ディレクトリ ($GOMVM_CONFIG_DIR) は存在しません。"
fi

# バイナリの削除
if [ -f "$GOMVM_BINARY" ]; then
  print_info "gomvm バイナリを削除しています: $GOMVM_BINARY"
  if rm -f "$GOMVM_BINARY"; then
    print_success "gomvm バイナリを正常に削除しました。"
  else
    print_error "gomvm バイナリの削除に失敗しました。"
    exit 1
  fi
else
  print_info "gomvm バイナリ ($GOMVM_BINARY) は存在しません。"
fi

echo ""
print_header "==== アンインストール完了 ===="
print_success "gomvm がシステムから削除されました。"
print_warning "注: Go のバージョン自体（例: $HOME/go/bin/ 内のファイル）は削除されていません。"
print_info "必要に応じて手動で削除してください。"
echo ""
print_info "再インストールする場合は、以下のように実行してください："
echo -e "  ${CYAN}curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh | bash${NC}"
echo ""
print_info "スクリプトディレクトリが見つからない場合の対処法（必要に応じて）:"
echo -e "  ${CYAN}export GOMVM_SCRIPTS_DIR=/path/to/go-multi-version-manager/scripts/ubuntu${NC}"
print_info "現在のシェルセッションに設定を反映するには、次のコマンドを実行してください："
echo -e "  ${CYAN}source ~/.bashrc${NC}"

exit 0
