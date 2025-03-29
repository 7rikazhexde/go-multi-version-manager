# go-multi-version-manager

このリポジトリは、複数のGoバージョンを管理、インストール、切り替えるためのスクリプト集です。

[English](README.md) | 日本語

## 目次

- [go-multi-version-manager](#go-multi-version-manager)
  - [目次](#目次)
  - [注意事項](#注意事項)
  - [前提条件](#前提条件)
  - [インストール方法](#インストール方法)
    - [自動インストール](#自動インストール)
    - [手動インストール](#手動インストール)
    - [自動アンインストール](#自動アンインストール)
  - [設定](#設定)
    - [.bashrcへの手動設定](#bashrcへの手動設定)
    - [設定の理解](#設定の理解)
  - [使用方法](#使用方法)
    - [基本コマンド](#基本コマンド)
    - [Goバージョンの切り替え](#goバージョンの切り替え)
    - [最新バージョンチェックの有効化](#最新バージョンチェックの有効化)
  - [スクリプト詳細](#スクリプト詳細)
    - [install\_go\_replace\_default.sh](#install_go_replace_defaultsh)
    - [install\_go\_with\_command.sh](#install_go_with_commandsh)
    - [install\_go\_specific.sh](#install_go_specificsh)
    - [switch\_go\_version.sh](#switch_go_versionsh)
    - [list\_go\_versions.sh](#list_go_versionssh)
  - [開発者向けオプション](#開発者向けオプション)
    - [シェルスクリプト用のPre-commitフックの設定](#シェルスクリプト用のpre-commitフックの設定)
    - [Pre-commitフック設定手順](#pre-commitフック設定手順)

## 注意事項

- スクリプトは**Ubuntu**向けに設計されており、**Mac**と**Windows**ではサポートしていません
- `install_go_with_command.sh`で管理するGoバージョンについては、`$HOME/go/bin`が`PATH`に含まれていることを確認してください
- インストール後は`go version`を使用して、正しくセットアップされたことを確認してください
- `gomvm switch`を使用してGoバージョンを切り替えると、選択したバージョンはシェルセッション間や`.bashrc`の再読み込み後も保持されます
- 一般的なGoのインストール方法については、[公式Goドキュメント](https://go.dev/doc/install)を参照してください

## 前提条件

`~/.bashrc`にGoのパス設定が必要です。基本的な設定は以下のようになります：

```bash
# Go
# Goのデフォルト設定（例: /usr/local/go/bin）
export PATH=/usr/local/go/bin:$PATH
# Goツール用のパス設定
export PATH=$HOME/go/bin:$PATH
```

## インストール方法

### 自動インストール

```bash
# インストーラースクリプトをダウンロード・実行
curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh | bash

# PATH設定を更新
source ~/.bashrc
```

### 手動インストール

リポジトリを直接クローンする方法

```bash
# リポジトリをクローン
git clone https://github.com/7rikazhexde/go-multi-version-manager.git
cd go-multi-version-manager

# gomvmをセットアップ
./gomvm setup

# PATH設定を更新
source ~/.bashrc
```

### 自動アンインストール

gomvmをシステムから完全に削除するには：

```bash
curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-uninstall.sh | bash
```

このアンインストールスクリプトは以下の処理を行います。

- システムからgomvmリポジトリディレクトリを削除
- 設定ディレクトリ（`~/.config/gomvm`）を削除
- `~/.local/bin`からgomvmバイナリを削除

> [!WARNING]
> アンインストール処理では以下は削除されません。
>
> - `$HOME/go/bin`にインストールされたGoバージョン（`gomvm install`でインストールしたもの）
> - システムディレクトリ（例: `/usr/local/go`）にインストールされたGoバージョン
>
> すべてを完全に削除したい場合は、手動で以下を削除できます
>
> 1. `$HOME/go/bin/`内のGoバージョン
> 2. `/usr/local/go`のデフォルトGoインストール

## 設定

### .bashrcへの手動設定

gomvmをインストールした後、バージョン永続化やその他の高度な機能を有効にするために、以下の設定を`~/.bashrc`ファイルに追加する必要があります。`.bashrc`ファイルを開いて、次のコードを追加してください：

```bash
# Go環境設定 - gomvmの有無で分岐
if command -v gomvm &> /dev/null || [ -f "$HOME/.config/gomvm/config" ]; then
  # gomvmが存在する場合の処理
  
  # バージョン永続化ファイルのチェック
  GO_SELECTED_VERSION_FILE="$HOME/.go_selected_version"
  if [ -f "$GO_SELECTED_VERSION_FILE" ] && [ -s "$GO_SELECTED_VERSION_FILE" ]; then
    GO_VERSION=$(cat "$GO_SELECTED_VERSION_FILE")
    if [ -x "$HOME/go/bin/go$GO_VERSION" ]; then
      # 選択されたバージョンのGOROOTを設定
      export GOROOT=$("$HOME/go/bin/go$GO_VERSION" env GOROOT)
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
  
  # 最新バージョンチェック（デフォルトでは無効）
  # 自動バージョンチェックを有効にするには、下記のsourceの行のコメントを解除してください
  if [ -f "$HOME/.config/gomvm/config" ]; then
    source "$HOME/.config/gomvm/config"
    if [ -n "$GOMVM_SCRIPTS_DIR" ]; then
      INSTALL_DIR=$(dirname "$(dirname "$GOMVM_SCRIPTS_DIR")")
      SCRIPT_PATH="$INSTALL_DIR/check_latest_go.sh"
      if [ -f "$SCRIPT_PATH" ]; then
        # source "$SCRIPT_PATH"  # この行のコメントを解除すると自動バージョンチェックが有効になります
        :  # 何もしない（プレースホルダー）
      fi
    fi
  fi
else
  # gomvmがない場合は標準的なGo設定のみを適用
  export PATH="/usr/local/go/bin:$PATH"
  export PATH="$HOME/go/bin:$PATH"
fi
```

この設定を追加した後、`.bashrc`を再読み込みしてください。

```bash
source ~/.bashrc
```

### 設定の理解

追加した設定は、以下の重要な機能を提供します：

1. **条件付き実行**：gomvmがインストールされている場合のみ高度な機能を有効にします
2. **バージョン永続化**：以前に選択したGoバージョンをファイルから読み取り、アクティブなバージョンとして設定します
3. **フォールバックメカニズム**：選択したバージョンが利用できない場合、システムのデフォルトGoを使用します
4. **任意の最新バージョンチェック**：新しいGoバージョンを自動的にチェックするよう設定できます（デフォルトではコメントアウト）

gomvmがインストールされていない場合、この設定は単に標準的なGoパス設定を適用します。

## 使用方法

### 基本コマンド

インストール後に利用可能な主要コマンド：

```bash
# 利用可能なGoバージョン一覧表示
gomvm list

# 特定のGoバージョンをインストール
gomvm install 1.24.1

# インストール済みのGoバージョン表示
gomvm installed

# 特定のGoバージョンをアンインストール
gomvm uninstall 1.24.1
```

### Goバージョンの切り替え

複数バージョン間を素早く切り替えるには：

```bash
# Go 1.24.1に切り替え
source gomvm switch 1.24.1
```

`switch`コマンドは以下の処理を行います。

1. 現在のシェルセッションのGoバージョンを変更します
2. バージョン設定をシェルセッション間で保持するために保存します
3. `.bashrc`を再読み込みした後も選択したバージョンが有効なままであることを保証します

> [!IMPORTANT]
> 変更を現在のシェルに反映させるために、必ず`source`コマンドを使用してください。

システムのデフォルトGoバージョンに戻したい場合は、以下のいずれかを実行できます。

- 保存された設定を削除：`rm $HOME/.go_selected_version`
- その後シェルを再読み込み：`source ~/.bashrc`

### 最新バージョンチェックの有効化

最新バージョンチェック機能は、不要なネットワークリクエストを避けるためにデフォルトでは無効になっています。有効にするには：

1. `~/.bashrc`ファイルを編集します。
2. gomvm設定セクションで`# source "$SCRIPT_PATH"`の行を見つけます。
3. `#`文字を削除してコメントを解除します。
4. ファイルを保存し、`.bashrc`を再読み込みします。

   ```bash
   source ~/.bashrc
   ```

有効にすると、この機能は以下のことを行います。

- ログイン時に最新のGoバージョンを確認します
- 24時間に1回だけチェックし、過度なネットワークリクエストを防止します
- 最新バージョンがインストールされていない場合、インストールを提案します
- `--force`オプションで24時間ルールを無視して強制的にチェックできます

手動で最新バージョンをチェックする場合は以下を実行してください。

```bash
source ~/path/to/go-multi-version-manager/check_latest_go.sh --force
```

## スクリプト詳細

### install_go_replace_default.sh

`/usr/local/go`にデフォルトバージョンのGoをインストールします。既存のバージョンがあれば置き換えます。

使用方法

```bash
./install_go_replace_default.sh <goバージョン>
```

例: `./install_go_replace_default.sh 1.23.2`

このスクリプトは、`/usr/local/go`が既に存在する場合は削除の確認を求め、指定されたバージョンをインストールします。

### install_go_with_command.sh

`go install`コマンドを使用してGoをインストールし、複数のバージョンを`${HOME}/go/bin`に並行してインストールできます。

使用方法

```bash
./install_go_with_command.sh <goバージョン>
```

例: `./install_go_with_command.sh 1.23.1`

このスクリプトは、指定されたバージョンを`${HOME}/go/bin/go<バージョン>`としてインストールします。

### install_go_specific.sh

特定のバージョンのGoを`/usr/local/go<バージョン>`にインストールします。既にインストールされている場合はスキップします。

使用方法

```bash
./install_go_specific.sh <goバージョン>
```

例: `./install_go_specific.sh 1.23.0`

このスクリプトでは、複数のバージョンを別々のディレクトリにインストールできます。

### switch_go_version.sh

指定されたGoバージョンに切り替えます。このスクリプトを`source`と共に実行することで、現在のシェルセッションでこのバージョンを使用し、将来のセッション用にデフォルトとして保存します。
指定バージョンがインストールされていない場合は、自動的にインストールします。

使用方法

```bash
source ./switch_go_version.sh <goバージョン>
```

例: `source ./switch_go_version.sh 1.23.0`

このスクリプトは選択したバージョンを保存するようになったため、新しいシェルを開始したり`.bashrc`を再読み込みするたびに切り替える必要がなくなりました。

### list_go_versions.sh

公式ダウンロードページから利用可能なGoバージョンの一覧を取得します。

使用方法

```bash
./list_go_versions.sh
```

このスクリプトは、[Goダウンロードページ](https://go.dev/dl/)から最新の情報を取得して表示します。

## 開発者向けオプション

### シェルスクリプト用のPre-commitフックの設定

コード品質維持のため、コミット前に自動的に`shellcheck`を実行する`pre-commit`フックを設定できます。

### Pre-commitフック設定手順

1. `shellcheck`のインストール

   ```bash
   sudo apt install shellcheck
   ```

2. 実行権限の追加

   ```bash
   chmod +x scripts/ci/create_pre-commit.sh
   ```

3. フック作成スクリプトの実行

   ```bash
   ./scripts/ci/create_pre-commit.sh
   ```

これにより、`.git/hooks/pre-commit`フックが作成され、コミット時に`scripts/ubuntu`内のすべての`.sh`ファイルに対して`shellcheck`が自動実行されます。
手動でフックを実行するには、`.git/hooks/pre-commit`を実行してください。
