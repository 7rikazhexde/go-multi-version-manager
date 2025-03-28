#!/bin/bash

# List installed Go versions in $HOME/go/bin directory
echo "Installed Go versions in \$HOME/go/bin:"
has_versions=false
for go_version in "${HOME}/go/bin/go"*; do
  if [[ -x "$go_version" && $(basename "$go_version") =~ ^go[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Extract and display the version number
    version_name=$(basename "$go_version")
    echo "$version_name"
    has_versions=true
  fi
done

if [ "$has_versions" = false ]; then
  echo "  該当するGoバージョンがありません"
fi

# Check for Go installations in standard locations
echo -e "\nシステムの主要な場所にインストールされたGoバージョン:"

# /usr/local/go (標準的なインストール場所)
if [ -x "/usr/local/go/bin/go" ]; then
  ver=$(/usr/local/go/bin/go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
  echo "- /usr/local/go/bin/go: $ver"
fi

# /usr/bin/go (パッケージマネージャからインストールされた場合)
if [ -x "/usr/bin/go" ]; then
  ver=$(/usr/bin/go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
  echo "- /usr/bin/go: $ver"
fi

# カスタムインストールパスを探す (sdk など)
if [ -d "$HOME/sdk" ]; then
  for sdk_dir in "$HOME/sdk/go"*; do
    if [ -x "$sdk_dir/bin/go" ]; then
      ver=$("$sdk_dir/bin/go" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
      echo "- $sdk_dir/bin/go: $ver"
    fi
  done
fi

# GOROOT環境変数が設定されている場合
if [ -n "$GOROOT" ] && [ -x "$GOROOT/bin/go" ]; then
  ver=$("$GOROOT/bin/go" version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
  echo "- \$GOROOT/bin/go ($GOROOT/bin/go): $ver"
fi

# Display the currently active Go version
echo -e "\n現在のPATHで使用されているGoバージョン:"
if command -v go &> /dev/null; then
  current_version=$(go version)
  current_path=$(which go)
  echo "$current_version"
  echo "バイナリの場所: $current_path"
else
  echo "Goコマンドが見つかりません。PATHにGoが含まれていない可能性があります。"
fi