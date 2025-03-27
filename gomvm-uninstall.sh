#!/bin/bash
# gomvm-uninstall.sh - Go Multi Version Manager アンインストーラー

set -e

echo "==== Go Multi Version Manager (gomvm) アンインストーラー ===="
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
    echo "設定ファイルから検出したインストール先: $INSTALL_DIR"
  else
    echo "警告: 設定ファイルに GOMVM_SCRIPTS_DIR が定義されていません。"
  fi
fi

# INSTALL_DIR が未定義の場合、ユーザーに手動で指定させる
if [ -z "$INSTALL_DIR" ]; then
  while true; do
    read -r -p "削除する gomvm のインストール先を指定してください（例: /home/user/golang）: " INSTALL_DIR < /dev/tty
    if [ -n "$INSTALL_DIR" ]; then
      break
    else
      echo "エラー: インストール先を指定する必要があります。"
    fi
  done
  # ユーザーが指定したパスに "go-multi-version-manager" を追加
  INSTALL_DIR="${INSTALL_DIR}/go-multi-version-manager"
fi

# インストール先の存在確認
if [ ! -d "$INSTALL_DIR" ]; then
  echo "警告: 指定されたインストール先 ($INSTALL_DIR) が見つかりません。"
else
  echo "リポジトリディレクトリを削除しています: $INSTALL_DIR"
  if rm -rf "$INSTALL_DIR"; then
    echo "リポジトリディレクトリを正常に削除しました。"
  else
    echo "エラー: リポジトリディレクトリの削除に失敗しました。"
    exit 1
  fi
fi

# 構成ディレクトリの削除
if [ -d "$GOMVM_CONFIG_DIR" ]; then
  echo "構成ディレクトリを削除しています: $GOMVM_CONFIG_DIR"
  if rm -rf "$GOMVM_CONFIG_DIR"; then
    echo "構成ディレクトリを正常に削除しました。"
  else
    echo "エラー: 構成ディレクトリの削除に失敗しました。"
    exit 1
  fi
else
  echo "構成ディレクトリ ($GOMVM_CONFIG_DIR) は存在しません。"
fi

# バイナリの削除
if [ -f "$GOMVM_BINARY" ]; then
  echo "gomvm バイナリを削除しています: $GOMVM_BINARY"
  if rm -f "$GOMVM_BINARY"; then
    echo "gomvm バイナリを正常に削除しました。"
  else
    echo "エラー: gomvm バイナリの削除に失敗しました。"
    exit 1
  fi
else
  echo "gomvm バイナリ ($GOMVM_BINARY) は存在しません。"
fi

echo ""
echo "==== アンインストール完了 ===="
echo "gomvm がシステムから削除されました。"
echo "注意: Go のバージョン自体（例: $HOME/go/bin/ 内のファイル）は削除されていません。"
echo "必要に応じて手動で削除してください。"
echo ""
echo "再インストールする場合は、以下のように実行してください："
echo "  curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh | bash"
echo ""
echo "スクリプトディレクトリが見つからない場合の対処法（必要に応じて）:"
echo "  export GOMVM_SCRIPTS_DIR=/path/to/go-multi-version-manager/scripts/ubuntu"
echo "現在のシェルセッションに設定を反映するには、次のコマンドを実行してください："
echo "  source ~/.bashrc"

exit 0