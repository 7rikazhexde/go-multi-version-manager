#!/bin/bash
# check_latest_go.sh - Go 最新バージョンをチェックしてインストールするスクリプト
# 注意: 'source ./check_latest_go.sh [--force]' で実行してください

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

# Go インストールディレクトリを動的に取得
get_gomvm_install_dir() {
  CONFIG_FILE="$HOME/.config/gomvm/config"
  if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    if [ -n "$GOMVM_SCRIPTS_DIR" ]; then
      INSTALL_DIR=$(dirname "$(dirname "$GOMVM_SCRIPTS_DIR")")
      print_info "gomvm インストール先: $INSTALL_DIR"
    else
      print_warning "GOMVM_SCRIPTS_DIR が未定義です"
      return 1
    fi
  else
    print_error "$CONFIG_FILE が見つかりません"
    return 1
  fi
  if [ ! -d "$INSTALL_DIR" ]; then
    print_error "$INSTALL_DIR が存在しません"
    return 1
  fi
}

# 指定されたバージョンがシステム内の任意の場所にインストールされているかチェック
is_go_version_installed() {
  local VERSION=$1
  
  # $HOME/go/bin 内のバージョンをチェック
  if [ -x "$HOME/go/bin/go${VERSION}" ]; then
    return 0
  fi
  
  # /usr/local/go にインストールされたバージョンをチェック
  if [ -x "/usr/local/go/bin/go" ]; then
    local usr_local_ver
    usr_local_ver=$(/usr/local/go/bin/go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/^go//')
    if [ "$usr_local_ver" = "$VERSION" ]; then
      return 0
    fi
  fi
  
  # /usr/bin/go をチェック (パッケージマネージャでインストールされた場合)
  if [ -x "/usr/bin/go" ]; then
    local usr_bin_ver
    usr_bin_ver=$(/usr/bin/go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/^go//')
    if [ "$usr_bin_ver" = "$VERSION" ]; then
      return 0
    fi
  fi
  
  # カスタムインストールパスを探す (sdk など)
  if [ -d "$HOME/sdk" ]; then
    for sdk_dir in "$HOME/sdk/go"*; do
      if [ -x "$sdk_dir/bin/go" ]; then
        local sdk_ver
        sdk_ver=$("$sdk_dir/bin/go" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/^go//')
        if [ "$sdk_ver" = "$VERSION" ]; then
          return 0
        fi
      fi
    done
  fi
  
  # GOROOT 環境変数を確認
  if [ -n "$GOROOT" ] && [ -x "$GOROOT/bin/go" ]; then
    local goroot_ver
    goroot_ver=$("$GOROOT/bin/go" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/^go//')
    if [ "$goroot_ver" = "$VERSION" ]; then
      return 0
    fi
  fi
  
  # 他の可能性のあるパスを確認 (ユーザー固有のカスタム設定)
  local go_cmd
  go_cmd=$(command -v go 2>/dev/null)
  if [ -n "$go_cmd" ]; then
    local path_ver
    path_ver=$("$go_cmd" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/^go//')
    if [ "$path_ver" = "$VERSION" ]; then
      return 0
    fi
  fi
  
  return 1
}

# Go 最新バージョンをチェックしてインストール
check_and_install_latest_go() {
  local force_check="$1"
  if ! command -v gomvm > /dev/null 2>&1; then
    print_warning "gomvm が未インストールです"
    print_info "インストール方法: ${CYAN}curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh | bash${NC}"
    return 1
  fi
  TIMESTAMP_FILE="$HOME/.gomvm_last_check"
  CURRENT_TIME=$(date +%s)
  if [ "$force_check" != "--force" ] && [ -f "$TIMESTAMP_FILE" ]; then
    LAST_CHECK=$(cat "$TIMESTAMP_FILE")
    if [ "$LAST_CHECK" -ge 0 ] 2>/dev/null && [ $((CURRENT_TIME - LAST_CHECK)) -lt 86400 ]; then
      print_info "前回のチェックから24時間経過していないため、スキップします"
      return 0
    fi
  fi
  print_info "Go の最新バージョンを確認しています..."
  LATEST_VERSION=$(gomvm list | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -V | tail -n 1)
  if [ -z "$LATEST_VERSION" ]; then
    print_error "最新バージョンの取得に失敗しました"
    return 1
  fi
  VERSION_NUM=${LATEST_VERSION#go}
  
  # 任意の場所にインストールされているかをチェック
  if is_go_version_installed "$VERSION_NUM"; then
    print_success "最新バージョン ($LATEST_VERSION) はすでにシステム上にインストールされています"
    # 現在のgoコマンドのバージョン情報を取得
    current_go_version=$(go version)
    current_go_path=$(which go)

    print_info "現在使用中のGoバージョン: ${CYAN}${current_go_version}${NC}"
    print_info "バイナリの場所: ${CYAN}${current_go_path}${NC}"
    print_info "${CYAN}gomvm installed${NC} コマンドで詳細を確認できます"
    date +%s > "$TIMESTAMP_FILE"
    return 0
  fi
  
  print_info "最新バージョン ($LATEST_VERSION) が利用可能です"
  read -r -p "インストールしますか？ (y/N): " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    print_info "インストール中: $LATEST_VERSION..."
    if gomvm install "$VERSION_NUM"; then
      print_success "$LATEST_VERSION のインストールが完了しました"
      read -r -p "この最新バージョンをデフォルトに設定しますか？ (y/N): " set_default
      if [[ "$set_default" =~ ^[Yy]$ ]]; then
        source "$(command -v gomvm)" switch "$VERSION_NUM"
        print_success "$LATEST_VERSION をデフォルトバージョンに設定しました"
      fi
      date +%s > "$TIMESTAMP_FILE"
    else
      print_error "$LATEST_VERSION のインストールに失敗しました"
      return 1
    fi
  else
    print_info "インストールをスキップしました"
    date +%s > "$TIMESTAMP_FILE"
  fi
}

# 直接実行時はエラーで中断
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  print_error "'source ./check_latest_go.sh [--force]' で実行してください"
  exit 1
fi

# メイン処理
print_header "🚀 Go Multi Version Manager (gomvm)による最新バージョンチェックを開始します"
if ! get_gomvm_install_dir; then
  print_error "gomvm インストール先の特定に失敗しました"
  return 1
fi
SCRIPT_PATH="$INSTALL_DIR/check_latest_go.sh"
if [ ! -f "$SCRIPT_PATH" ]; then
  print_warning "$SCRIPT_PATH が見つかりません"
  return 1
else
  print_info "スクリプト位置: $SCRIPT_PATH"
fi
if [ "$1" = "--force" ]; then
  check_and_install_latest_go "--force"
else
  check_and_install_latest_go
fi
print_header "🏁 gomvmによる最新バージョンチェックを終了します"
