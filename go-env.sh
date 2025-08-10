#!/bin/bash
# go-env.sh - Go環境変数とPATH設定スクリプト
# このスクリプトはgomvmによるGo環境の自動設定を行います

# Go環境設定 - gomvmの有無で分岐
if command -v gomvm &> /dev/null || [ -f "$HOME/.config/gomvm/config" ]; then
  # gomvmが存在する場合の処理
  
  # バージョン永続化ファイルのチェック
  GO_SELECTED_VERSION_FILE="$HOME/.go_selected_version"
  if [ -f "$GO_SELECTED_VERSION_FILE" ] && [ -s "$GO_SELECTED_VERSION_FILE" ]; then
    GO_VERSION=$(cat "$GO_SELECTED_VERSION_FILE")
    if [ -x "$HOME/go/bin/go$GO_VERSION" ]; then
      # 選択されたバージョンのGOROOTを設定
      GOROOT_TEMP=$("$HOME/go/bin/go$GO_VERSION" env GOROOT)
      export GOROOT="$GOROOT_TEMP"
      # PATHを設定（選択バージョン優先）
      export PATH="$GOROOT/bin:$HOME/go/bin:$PATH"
    else
      # 選択バージョンが見つからない場合はデフォルト設定
      export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
    fi
  else
    # 永続化ファイルがない場合はデフォルト設定
    export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
  fi
  
  # 最新バージョンチェック（デフォルトで無効）
  # 有効にするには下記のコメントアウトを解除してください
  if [ -f "$HOME/.config/gomvm/config" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.config/gomvm/config"
    if [ -n "$GOMVM_SCRIPTS_DIR" ]; then
      INSTALL_DIR=$(dirname "$(dirname "$GOMVM_SCRIPTS_DIR")")
      SCRIPT_PATH="$INSTALL_DIR/check_latest_go.sh"
      if [ -f "$SCRIPT_PATH" ]; then
        # shellcheck source=/dev/null
        # source "$SCRIPT_PATH"  # この行のコメントを解除すると最新バージョンチェックが有効になります
        :  # 何もしない（プレースホルダー）
      fi
    fi
  fi
else
  # gomvmがない場合は標準的なGo設定のみを適用
  export PATH="/usr/local/go/bin:$PATH"
  export PATH="$HOME/go/bin:$PATH"
fi
