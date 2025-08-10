#!/bin/bash

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

# 現在のPATHにある Go バージョンを取得
get_current_go_version() {
  if command -v go &> /dev/null; then
    local current_version
    current_version=$(go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
    echo "$current_version"
  fi
}

CURRENT_VERSION=$(get_current_go_version)

# $HOME/go/bin ディレクトリにインストールされたGoバージョンの一覧表示
print_header "📦 \$HOME/go/bin にインストールされたGoバージョン:"
has_versions=false
for go_version in "${HOME}/go/bin/go"*; do
  if [[ -x "$go_version" && $(basename "$go_version") =~ ^go[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # バージョン番号を抽出して表示
    version_name=$(basename "$go_version")
    
    # 現在のバージョンを強調表示
    if [ "$version_name" = "$CURRENT_VERSION" ]; then
      echo -e "  ${YELLOW}★ $version_name${NC} (現在使用中)"
    else
      echo -e "  ${GREEN}$version_name${NC}"
    fi
    
    has_versions=true
  fi
done

if [ "$has_versions" = false ]; then
  print_warning "  該当するGoバージョンがありません"
fi

# システムの主要な場所にインストールされたGoバージョンをチェック
print_header "\n🖥️ システムの主要な場所にインストールされたGoバージョン:"
system_has_versions=false

# /usr/local/go (標準的なインストール場所)
if [ -x "/usr/local/go/bin/go" ]; then
  ver=$(/usr/local/go/bin/go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
  if [ "$ver" = "$CURRENT_VERSION" ]; then
    echo -e "  ${YELLOW}★ /usr/local/go/bin/go: $ver${NC} (現在使用中)"
  else
    echo -e "  ${GREEN}/usr/local/go/bin/go: $ver${NC}"
  fi
  system_has_versions=true
fi

# /usr/bin/go (パッケージマネージャからインストールされた場合)
if [ -x "/usr/bin/go" ]; then
  ver=$(/usr/bin/go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
  if [ "$ver" = "$CURRENT_VERSION" ]; then
    echo -e "  ${YELLOW}★ /usr/bin/go: $ver${NC} (現在使用中)"
  else
    echo -e "  ${GREEN}/usr/bin/go: $ver${NC}"
  fi
  system_has_versions=true
fi

# カスタムインストールパスを探す (sdk など)
if [ -d "$HOME/sdk" ]; then
  for sdk_dir in "$HOME/sdk/go"*; do
    if [ -x "$sdk_dir/bin/go" ]; then
      ver=$("$sdk_dir/bin/go" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
      if [ "$ver" = "$CURRENT_VERSION" ]; then
        echo -e "  ${YELLOW}★ $sdk_dir/bin/go: $ver${NC} (現在使用中)"
      else
        echo -e "  ${GREEN}$sdk_dir/bin/go: $ver${NC}"
      fi
      system_has_versions=true
    fi
  done
fi

# /usr/local/go<version> ディレクトリもチェック (install_go_specific.sh でインストールされた場合)
for specific_dir in /usr/local/go[0-9]*; do
  if [ -d "$specific_dir" ] && [ -x "$specific_dir/bin/go" ]; then
    ver=$("$specific_dir/bin/go" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
    if [ "$ver" = "$CURRENT_VERSION" ]; then
      echo -e "  ${YELLOW}★ $specific_dir/bin/go: $ver${NC} (現在使用中)"
    else
      echo -e "  ${GREEN}$specific_dir/bin/go: $ver${NC}"
    fi
    system_has_versions=true
  fi
done

# GOROOT環境変数が設定されている場合の情報表示
if [ -n "$GOROOT" ] && [ -x "$GOROOT/bin/go" ]; then
  # GOROOTが設定されている場合は、実際に使用されているGoバイナリを確認
  current_go_path=$(which go)
  goroot_go_path="$GOROOT/bin/go"
  
  if [ "$current_go_path" = "$goroot_go_path" ]; then
    ver=$("$GOROOT/bin/go" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
    echo -e "  ${YELLOW}★ \$GOROOT/bin/go ($GOROOT/bin/go): $ver${NC} (GOROOT設定により使用中)"
  else
    ver=$("$GOROOT/bin/go" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
    echo -e "  ${GREEN}\$GOROOT/bin/go ($GOROOT/bin/go): $ver${NC} (設定されているが未使用)"
  fi
  system_has_versions=true
fi

if [ "$system_has_versions" = false ]; then
  print_warning "  該当するGoバージョンがシステムにインストールされていません"
fi

# 現在アクティブなGoバージョンを表示
print_header "\n⚡ 現在のPATHで使用されているGoバージョン:"
if command -v go &> /dev/null; then
  current_version=$(go version)
  current_path=$(which go)
  print_success "$current_version"
  print_info "バイナリの場所: $current_path"
  
  # 現在の環境変数を正確に表示
  current_goroot=$(go env GOROOT)
  current_gopath=$(go env GOPATH)
  
  print_info "GOROOT: $current_goroot"
  print_info "GOPATH: $current_gopath"
  
  # 環境変数として設定されているGOROOTとgoコマンドから取得したGOROOTが異なる場合は警告
  if [ -n "$GOROOT" ] && [ "$GOROOT" != "$current_goroot" ]; then
    print_warning "環境変数GOROOT ($GOROOT) と実際のGOROOT ($current_goroot) が異なります"
    print_info "この不一致は設定の問題を示している可能性があります"
  fi
else
  print_error "Goコマンドが見つかりません。PATHにGoが含まれていない可能性があります。"
fi

echo ""
print_info "Goバージョンを切り替えるには: ${CYAN}source gomvm switch <version>${NC}"
print_info "新しいGoバージョンをインストールするには: ${CYAN}gomvm install <version>${NC}"
print_info "利用可能なGoバージョン一覧を表示するには: ${CYAN}gomvm list${NC}"
