#!/bin/bash
# gomvm-install.sh - Go Multi Version Manager インストーラー

set -e

# curl | bash で実行された場合のディレクトリ処理
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "$0" ]; then
  # スクリプトがパイプから実行された場合、一時ディレクトリを作成
  if [ -t 0 ]; then
    # 通常の実行
    :
  else
    # パイプからの実行
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    trap 'cd - > /dev/null; rm -rf "$TMP_DIR"' EXIT
  fi
fi

echo "==== Go Multi Version Manager (gomvm) インストーラー ===="
echo ""

# インストール先をユーザーに必ず指定させる
# パイプ経由でも端末から入力を受け取るために /dev/tty を使用
while true; do
  read -r -p "インストール先を指定してください（例: /home/user/golang）: " INSTALL_DIR < /dev/tty
  if [ -n "$INSTALL_DIR" ]; then
    break
  else
    echo "エラー: インストール先を指定する必要があります。"
  fi
done

# ユーザーが指定したパスに "go-multi-version-manager" を追加
INSTALL_DIR="${INSTALL_DIR}/go-multi-version-manager"

# INSTALL_DIR が空でないことを確認
if [ -z "$INSTALL_DIR" ]; then
  echo "エラー: インストール先が設定されていません。処理を中止します。"
  exit 1
fi

# ディレクトリを作成
mkdir -p "$(dirname "$INSTALL_DIR")"

# リポジトリのクローン/更新
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "既存のリポジトリを更新しています..."
  cd "$INSTALL_DIR"
  git pull origin main
else
  echo "リポジトリをクローンしています..."
  git clone https://github.com/7rikazhexde/go-multi-version-manager.git "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# gomvm スクリプトを curl で取得
echo "gomvm スクリプトをダウンロードしています..."
if ! curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm -o gomvm; then
  echo "エラー: gomvm スクリプトのダウンロードに失敗しました。"
  exit 1
fi

# スクリプトに実行権限を付与
chmod +x gomvm

# セットアップを実行
echo "gomvm のセットアップを実行しています..."
./gomvm setup

echo ""
echo "==== インストール完了 ===="
echo "使用例:"
echo "  gomvm list                    - 利用可能なGoバージョンを一覧表示"
echo "  gomvm install 1.24.1          - Go 1.24.1をインストール" 
echo "  source gomvm switch <version> - 指定したGoバージョンに切り替え"
echo "  gomvm installed               - インストール済みのGoバージョンを表示"
echo ""
echo "インストール完了しました。次のコマンドを実行して設定を反映してください："
echo "  source ~/.bashrc"