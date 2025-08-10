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

# Paths to check and potentially remove
GO_BINARY="${HOME}/go/bin/go${GO_VERSION}"
GO_SDK_DIR="${HOME}/sdk/go${GO_VERSION}"
GO_SELECTED_VERSION_FILE="${HOME}/.go_selected_version"

# Find all items that exist and can be removed
items_found=()
removal_details=()

# Check for binary file
if [ -f "${GO_BINARY}" ]; then
  items_found+=("binary")
  removal_details+=("バイナリファイル: ${GO_BINARY}")
fi

# Check for SDK directory
if [ -d "${GO_SDK_DIR}" ]; then
  items_found+=("sdk")
  removal_details+=("インストールディレクトリ: ${GO_SDK_DIR}")
fi

# Check for alternative SDK locations (just in case)
for alt_sdk in "${HOME}/.go/versions/${GO_VERSION}" "/usr/local/go${GO_VERSION}"; do
  if [ -d "$alt_sdk" ]; then
    items_found+=("alt_sdk")
    removal_details+=("代替インストールディレクトリ: ${alt_sdk}")
    break
  fi
done

# Always proceed with removal attempt, even if nothing is found
# This ensures we clean up any missed items and provide clear feedback

echo ""
print_info "Go バージョン ${GO_VERSION} の削除を実行します..."

if [ ${#items_found[@]} -gt 0 ]; then
  print_warning "以下の項目が見つかりました："
  for detail in "${removal_details[@]}"; do
    echo -e "  ${YELLOW}• $detail${NC}"
  done
  
  # Calculate total size if SDK directory exists
  if [ -d "${GO_SDK_DIR}" ]; then
    sdk_size=$(du -sh "${GO_SDK_DIR}" 2>/dev/null | cut -f1)
    if [ -n "$sdk_size" ]; then
      print_info "SDKディレクトリのサイズ: $sdk_size"
    fi
  fi
else
  print_warning "インストールされたファイルが見つかりませんでしたが、削除処理を続行します。"
fi

echo ""
read -r -p "削除を実行しますか？ (y/N): " confirm

if [[ "${confirm}" =~ ^[Yy]$ ]]; then
  removed_items=0
  
  # Remove binary file if it exists
  if [ -f "${GO_BINARY}" ]; then
    print_info "バイナリファイルを削除しています..."
    if rm "${GO_BINARY}" 2>/dev/null; then
      print_success "バイナリファイルを削除しました: ${GO_BINARY}"
      ((removed_items++))
    else
      print_error "バイナリファイルの削除に失敗しました: ${GO_BINARY}"
    fi
  fi
  
  # Remove SDK directory if it exists
  if [ -d "${GO_SDK_DIR}" ]; then
    print_info "SDKディレクトリを削除しています（時間がかかる場合があります）..."
    if rm -rf "${GO_SDK_DIR}" 2>/dev/null; then
      print_success "SDKディレクトリを削除しました: ${GO_SDK_DIR}"
      ((removed_items++))
    else
      print_error "SDKディレクトリの削除に失敗しました: ${GO_SDK_DIR}"
    fi
  fi
  
  # Remove alternative SDK directories
  for alt_sdk in "${HOME}/.go/versions/${GO_VERSION}" "/usr/local/go${GO_VERSION}"; do
    if [ -d "$alt_sdk" ]; then
      print_info "代替SDKディレクトリを削除しています: $alt_sdk"
      if rm -rf "$alt_sdk" 2>/dev/null; then
        print_success "代替SDKディレクトリを削除しました: $alt_sdk"
        ((removed_items++))
      else
        print_error "代替SDKディレクトリの削除に失敗しました: $alt_sdk"
      fi
    fi
  done
  
  # Clean up version selection if this version was selected
  if [ -f "${GO_SELECTED_VERSION_FILE}" ]; then
    SELECTED_VERSION=$(cat "${GO_SELECTED_VERSION_FILE}" 2>/dev/null)
    if [ "${SELECTED_VERSION}" = "${GO_VERSION}" ]; then
      if rm "${GO_SELECTED_VERSION_FILE}" 2>/dev/null; then
        print_warning "削除したバージョン ${GO_VERSION} は現在デフォルトとして設定されていました。"
        print_info "バージョン選択設定をクリアしました。"
        ((removed_items++))
        
        # 現在のシェルセッションのGOROOTもクリア（削除したバージョンを参照している場合）
        if [ -n "$GOROOT" ] && [[ "$GOROOT" == *"go${GO_VERSION}"* ]]; then
          print_warning "現在のGOROOT環境変数が削除されたディレクトリを参照しています。"
          print_info "環境変数をクリアします..."
          unset GOROOT
          export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
          print_success "環境変数をクリアしました。"
        fi
      else
        print_error "バージョン選択設定の削除に失敗しました。"
        print_info "手動で削除するには: ${CYAN}rm ${GO_SELECTED_VERSION_FILE}${NC}"
      fi
    fi
  fi
  
  # Final status
  if [ "$removed_items" -gt 0 ]; then
    print_success "Go バージョン ${GO_VERSION} の削除処理が完了しました（${removed_items}個の項目を処理）。"
  else
    print_warning "削除対象のファイルやディレクトリが見つかりませんでした。"
    print_info "既に削除済みの可能性があります。"
  fi
  
  echo ""
  print_info "環境を更新するには以下のいずれかを実行してください："
  print_info "• デフォルト環境に戻す: ${CYAN}source ~/.bashrc${NC}"
  print_info "• 他のGoバージョンに切り替え: ${CYAN}source gomvm switch <go_version>${NC}"
  print_info "• インストール済みバージョンを確認: ${CYAN}gomvm installed${NC}"
  
else
  print_info "削除を中止しました。"
fi
