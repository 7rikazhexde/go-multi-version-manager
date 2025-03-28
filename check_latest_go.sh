#!/bin/bash
# check_latest_go.sh - Go 最新バージョンをチェックしてインストールするスクリプト
# 注意: 'source ./check_latest_go.sh [--force]' で実行してください

# Go インストールディレクトリを動的に取得
get_gomvm_install_dir() {
  CONFIG_FILE="$HOME/.config/gomvm/config"
  if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    if [ -n "$GOMVM_SCRIPTS_DIR" ]; then
      INSTALL_DIR=$(dirname "$(dirname "$GOMVM_SCRIPTS_DIR")")
      echo "インストール先: $INSTALL_DIR"
    else
      echo "警告: GOMVM_SCRIPTS_DIR が未定義です"
      return 1
    fi
  else
    echo "エラー: $CONFIG_FILE が見つかりません"
    return 1
  fi
  if [ ! -d "$INSTALL_DIR" ]; then
    echo "エラー: $INSTALL_DIR が存在しません"
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
    echo "警告: gomvm が未インストールです"
    echo "インストール: curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh | bash"
    return 1
  fi
  TIMESTAMP_FILE="$HOME/.gomvm_last_check"
  CURRENT_TIME=$(date +%s)
  if [ "$force_check" != "--force" ] && [ -f "$TIMESTAMP_FILE" ]; then
    LAST_CHECK=$(cat "$TIMESTAMP_FILE")
    if [ "$LAST_CHECK" -ge 0 ] 2>/dev/null && [ $((CURRENT_TIME - LAST_CHECK)) -lt 86400 ]; then
      echo "24時間以内なのでスキップ"
      return 0
    fi
  fi
  echo "最新バージョンを確認中..."
  LATEST_VERSION=$(gomvm list | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -V | tail -n 1)
  if [ -z "$LATEST_VERSION" ]; then
    echo "エラー: 最新バージョンの取得に失敗"
    return 1
  fi
  # SC2001: sedの代わりにbash変数置換を使用
  VERSION_NUM=${LATEST_VERSION#go}
  
  # 修正: 任意の場所にインストールされているかをチェック
  if is_go_version_installed "$VERSION_NUM"; then
    echo "最新バージョン ($LATEST_VERSION) はシステム上にインストール済み"
    echo "実行 'gomvm installed' で詳細を確認できます"
    date +%s > "$TIMESTAMP_FILE"
    return 0
  fi
  
  echo "最新バージョン ($LATEST_VERSION) が利用可能"
  read -r -p "インストールしますか？ (y/N): " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "インストール中: $LATEST_VERSION..."
    if gomvm install "$VERSION_NUM"; then
      echo "$LATEST_VERSION をインストール完了"
      read -r -p "デフォルトに設定しますか？ (y/N): " set_default
      if [[ "$set_default" =~ ^[Yy]$ ]]; then
        # SC1091: gomvmが外部コマンドであることを明示
        # shellcheck source=/dev/null
        source "$(command -v gomvm)" switch "$VERSION_NUM"
        echo "$LATEST_VERSION をデフォルトに設定"
      fi
      date +%s > "$TIMESTAMP_FILE"
    else
      echo "エラー: $LATEST_VERSION のインストールに失敗"
      return 1
    fi
  else
    echo "インストールをスキップ"
    date +%s > "$TIMESTAMP_FILE"
  fi
}

# 直接実行時はエラーで中断
# SC2128: BASH_SOURCEは配列として扱う
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  echo "エラー: 'source ./check_latest_go.sh [--force]' で実行してください"
  exit 1
fi

# メイン処理
echo "開始"
if ! get_gomvm_install_dir; then
  echo "エラー: インストール先の特定に失敗"
  return 1
fi
SCRIPT_PATH="$INSTALL_DIR/check_latest_go.sh"
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "警告: $SCRIPT_PATH が見つかりません"
  return 1
else
  echo "スクリプト位置: $SCRIPT_PATH"
fi
if [ "$1" = "--force" ]; then
  check_and_install_latest_go "--force"
else
  check_and_install_latest_go
fi
echo "終了"