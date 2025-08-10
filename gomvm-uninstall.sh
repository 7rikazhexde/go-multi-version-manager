#!/bin/bash
# gomvm-uninstall.sh - Go Multi Version Manager アンインストーラー

set -e

# カラーコードを省略したシンプルな表示関数
print_header() {
  echo "==== $1 ===="
}

print_info() {
  echo "ℹ️ $1"
}

print_success() {
  echo "✅ $1"
}

print_warning() {
  echo "⚠️ $1"
}

print_error() {
  echo "❌ $1"
}

print_header "Go Multi Version Manager (gomvm) アンインストーラー"
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
    echo -n "📂 削除する gomvm のインストール先を指定してください（例: $HOME/golang）: "
    read -r INSTALL_DIR < /dev/tty
    if [ -n "$INSTALL_DIR" ]; then
      break
    else
      print_error "インストール先を指定する必要があります。"
    fi
  done
  # ユーザーが指定したパスに "go-multi-version-manager" を追加
  INSTALL_DIR="${INSTALL_DIR}/go-multi-version-manager"
fi

echo ""
print_info "以下の項目を削除します："
echo "• リポジトリディレクトリ: $INSTALL_DIR"
echo "• 設定ディレクトリ: $GOMVM_CONFIG_DIR"
echo "• バイナリファイル: $GOMVM_BINARY"
echo "• .bashrcの設定行"
echo ""

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

# 構成ディレクトリの削除（go-env.shも含む）
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

# .bashrcからgomvm関連の設定行を削除
BASHRC_FILE="$HOME/.bashrc"
if [ -f "$BASHRC_FILE" ]; then
  print_info ".bashrcからgomvm関連の設定を削除しています..."
  
  # 一時ファイルを作成して.bashrcをバックアップ
  cp "$BASHRC_FILE" "${BASHRC_FILE}.gomvm_backup"
  
  # gomvm関連の行を削除（複数パターンに対応）
  sed -i '/# Go環境設定 - gomvm/d' "$BASHRC_FILE"
  sed -i '/gomvm\/go-env\.sh/d' "$BASHRC_FILE"
  
  # 空行が連続する場合は1つにまとめる
  sed -i '/^$/N;/^\n$/d' "$BASHRC_FILE"
  
  print_success ".bashrcからgomvm関連の設定を削除しました"
  print_info "バックアップ: ${BASHRC_FILE}.gomvm_backup"
else
  print_warning ".bashrcファイルが見つかりません: $BASHRC_FILE"
fi

echo ""
print_header "アンインストール完了"
print_success "gomvm がシステムから削除されました。"
print_warning "注: Go のバージョン自体（例: $HOME/go/bin/ 内のファイル）は削除されていません。"
print_info "必要に応じて手動で削除してください。"
echo ""
print_info "再インストールする場合は、以下のように実行してください："
echo "  curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh | bash"
echo ""
print_info "現在のシェルセッションに設定を反映するには、次のコマンドを実行してください："
echo "  source ~/.bashrc"

exit 0
