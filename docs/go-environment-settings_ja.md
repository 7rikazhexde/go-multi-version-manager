# 🛠️ Go環境変数とPATH設定ガイド

このドキュメントでは、gomvmを効果的に使用するためのGo環境のPATH設定と環境変数について詳しく説明します。

## 📝 Goの環境設定とgomvmでのPATH構成

公式のGoインストール手順では通常以下のようにシステムのGoバイナリのみをPATHに追加します：

```bash
# 公式インストール手順による設定
export PATH=$PATH:/usr/local/go/bin
```

一方、gomvmでは以下のようにPATH設定を行います：

```bash
# Goのシステムバイナリを先頭に追加（バージョン切り替えのため）
export PATH="/usr/local/go/bin:$PATH"

# ユーザーレベルのGoツールへのパスも追加（go installコマンドで導入されるツール用）
export PATH="$HOME/go/bin:$PATH"
```

gomvmがこの設定方法を採用しているのは、複数バージョンの切り替えを効率的に行うためと、`go install`コマンドでインストールされるバージョン固有のツールを利用可能にするためです。

## 🔍 各設定の役割と順序

1. **`/usr/local/go/bin`** (システムレベルのGo)
   - デフォルトのGoインストール場所
   - すべてのユーザーが共有するGoバイナリ
   - `install_go_replace_default.sh`で更新されるGo

2. **`$HOME/go/bin`** (ユーザーレベルのGo)
   - `go install`コマンドでインストールされるツールの場所
   - `install_go_with_command.sh`でインストールされるバージョン固有のGoバイナリ（例：`go1.24.0`）
   - ユーザー固有のGoツール

## ⚙️ PATH設定の順序と優先度

最終的なPATHの検索順序はgomvmの設定と実行環境によって決まります：

### gomvmをインストールした場合の`.bashrc`設定

```bash
if command -v gomvm &> /dev/null || [ -f "$HOME/.config/gomvm/config" ]; then
  # gomvmの処理（バージョン選択を確認して適用）
  ...
else
  # gomvmがない場合は標準的なGo設定のみを適用
  export PATH="/usr/local/go/bin:$PATH"
  export PATH="$HOME/go/bin:$PATH"
fi
```

これにより環境によって異なるPATH設定が適用されます：

### gomvmなしの環境

通常の順序で適用されます：

```bash
/usr/local/go/bin:$HOME/go/bin:その他のシステムパス
```

### gomvmありで切り替えを行った環境

`switch`コマンドによって特定バージョンのパスが優先されます：

```bash
$GOROOT/bin:$HOME/go/bin:/usr/local/go/bin:その他のシステムパス
```

この設計により：

- gomvmで選択したバージョンが最優先される
- バージョン固有のバイナリがない場合は、システムデフォルトのGoが使用される
- システムの他のコマンドは通常通り利用可能

## 🔄 GOROOTとバージョン切り替えのメカニズム

### GOROOTとは

GOROOTはGoのインストールディレクトリを指す環境変数です。このディレクトリには標準ライブラリ、コンパイラ、ツール群など、Goの実行に必要なすべてのファイルが含まれています。

### `go<version> env GOROOT`コマンド

特定のGoバージョンのインストールディレクトリを確認するためのコマンドです：

```bash
$ go1.24.0 env GOROOT
/home/user/sdk/go1.24.0
```

このコマンドは、指定したバージョンのGoがインストールされている正確なディレクトリパスを返します。任意のバージョン（例：`go1.23.0`、`go1.22.1`など）に対して実行でき、そのバージョン固有のGOROOTを取得できます。

### gomvmでの使用方法

gomvmの`switch_go_version.sh`では以下のように使用されています：

```bash
# バージョン固有のGOROOTを取得
GOROOT=$(go${GO_VERSION} env GOROOT)

# 環境変数を設定
export GOROOT="$GOROOT"
export PATH="$GOROOT/bin:$PATH"
```

この処理により：

- 特定バージョンのGoのインストールディレクトリを正確に特定
- そのバージョンの実行バイナリを最優先で使用
- 標準ライブラリなどの依存関係も同じバージョンのものを使用

## 🔑 gomvmとGoのPATH設定の重要ポイント

### 公式設定とgomvmの違い

公式Goドキュメントでは `/usr/local/go/bin` をPATHに追加することを説明しています。これはシステムにインストールされたGoバージョンが使用可能です。gomvmではマルチバージョン管理を実現するために、パスを `export PATH="/usr/local/go/bin:$PATH"` のようにPATHの先頭に追加しています。

### 実行環境による違い

- **gomvmをインストールしていない場合**: 公式の設定通り、システムにインストールされたGoバージョンが使用可能です。（`go install`および、`go<version> env GOROOT`していない場合)
- **gomvmをインストールしているが切り替えていない場合**: システムのデフォルトGo（`/usr/local/go/bin/go`）が使用されます
- **gomvmのswitchで切り替え済み**: `$HOME/go/bin`にインストールされたバージョン固有のバイナリ（例: `go1.24.0`）から適切なGOROOTが特定され、そのバージョンが優先的に使用されます

この設計により、システムのデフォルトGoを維持しながら、プロジェクトごとに必要なGoバージョンを簡単に切り替えることができます。

### `$HOME/go/bin`の重要性

このディレクトリには、`go install`コマンドでインストールしたツールやバージョン固有のGoバイナリが格納されます。PATHに追加しないと、これらのツールやバイナリを直接呼び出せません。

## 🛠️ トラブルシューティング

### 問題: バージョンが切り替わらない

確認ポイント:

- `$HOME/go/bin` がPATHに含まれているか
- 選択したバージョンのバイナリが存在するか（`ls -la $HOME/go/bin/go*`）
- `source` コマンドを使ってスクリプトを実行しているか

### 問題: `command not found` エラー

確認ポイント:

- PATHの設定が正しいか
- `.bashrc` の変更が反映されているか（`source ~/.bashrc`）
- `gomvm` コマンドが `/usr/local/bin` や `$HOME/.local/bin` にあるか

## 🔗 関連リソース

- [Go公式ドキュメント - インストール手順](https://go.dev/doc/install)
- [Go環境変数の詳細](https://pkg.go.dev/cmd/go#hdr-Environment_variables)
