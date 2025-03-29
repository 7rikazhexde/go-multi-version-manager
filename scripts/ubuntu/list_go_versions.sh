#!/bin/bash

# 色の定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# メッセージ表示のヘルパー関数
print_info() {
  echo -e "${BLUE}ℹ️ $1${NC}"
}

print_header() {
  echo -e "${BOLD}${PURPLE}$1${NC}"
}

# バージョン表示用の関数
print_version() {
  local version=$1
  echo -e "${GREEN}$version${NC}"
}

print_info "https://go.dev/dl/ から利用可能な Go バージョンを取得しています..."
echo ""

# Extract version information from the download page
VERSIONS=$(wget -qO- https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+' | sort -u)

if [ -z "$VERSIONS" ]; then
  echo -e "${YELLOW}⚠️ バージョン情報の取得に失敗しました。インターネット接続を確認してください。${NC}"
  exit 1
fi

# Find the latest version
LATEST_VERSION=$(echo "$VERSIONS" | sort -V | tail -n 1)

print_header "📋 利用可能な Go バージョン一覧:"
echo ""

# Display versions in a nicely formatted way
# Group by major.minor version
PREV_MINOR=""
VERSION_COUNT=0

for version in $(echo "$VERSIONS" | sort -rV); do
  # Extract major.minor part
  MINOR_VER=$(echo "$version" | grep -oP 'go[0-9]+\.[0-9]+')
  
  # If we're starting a new minor version group, print a header
  if [ "$MINOR_VER" != "$PREV_MINOR" ]; then
    if [ -n "$PREV_MINOR" ]; then
      echo "" # Add a newline between groups
    fi
    echo -e "${CYAN}$MINOR_VER:${NC}"
    PREV_MINOR=$MINOR_VER
  fi
  
  # Highlight the latest version
  if [ "$version" = "$LATEST_VERSION" ]; then
    echo -e "  ${YELLOW}★ $version${NC} (最新)"
  else
    echo -e "  ${GREEN}$version${NC}"
  fi
  
  ((VERSION_COUNT++))
done

echo ""
print_info "合計 $VERSION_COUNT バージョンが利用可能です"
print_info "最新バージョン: ${YELLOW}$LATEST_VERSION${NC}"
print_info "特定のバージョンをインストールするには: ${CYAN}gomvm install <バージョン番号>${NC}"
echo -e "例: ${CYAN}gomvm install ${LATEST_VERSION#go}${NC}"
