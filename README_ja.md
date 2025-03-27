# go-multi-version-manager

このリポジトリには、複数のGoバージョンを管理、インストール、切り替えるためのスクリプトが含まれています。

[English](README.md) | 日本語

## 目次

- [go-multi-version-manager](#go-multi-version-manager)
  - [目次](#目次)
  - [注意事項](#注意事項)
  - [インストール方法](#インストール方法)
    - [自動インストール](#自動インストール)
    - [手動インストール](#手動インストール)
  - [使用方法](#使用方法)
    - [基本的なコマンド](#基本的なコマンド)
    - [Goバージョンの切り替え](#goバージョンの切り替え)
  - [スクリプト](#スクリプト)
    - [install\_go\_replace\_default.sh](#install_go_replace_defaultsh)
    - [install\_go\_with\_command.sh](#install_go_with_commandsh)
    - [install\_go\_specific.sh](#install_go_specificsh)
    - [switch\_go\_version.sh](#switch_go_versionsh)
    - [list\_go\_versions.sh](#list_go_versionssh)
  - [開発者向けオプション](#開発者向けオプション)
    - [シェルスクリプト用のPre-commitフックの設定](#シェルスクリプト用のpre-commitフックの設定)
    - [Pre-commitフック設定手順](#pre-commitフック設定手順)

## 注意事項

- これらのスクリプトは**Ubuntu**用に設計されています。**Mac**と**Windows**では動作保証していません。
- `install_go_with_command.sh`で管理するGoバージョンについては、`$HOME/go/bin`が`PATH`に含まれていることを確認してください[^1]。
- `go version`を使用してインストールされたバージョンを確認し、正しくセットアップされていることを確認してください。
- 一般的なGoのインストールガイドについては、[公式Goドキュメント](https://go.dev/doc/install)を参照してください。

[^1]: `export PATH=/usr/local/go/bin:$PATH`

## インストール方法

### 自動インストール

go-multi-version-managerを設定する最も簡単な方法は、インストーラースクリプトを使用することです：

```bash
# インストーラースクリプトをダウンロードして実行
curl -sSL https://raw.githubusercontent.com/7rikazhexde/go-multi-version-manager/main/gomvm-install.sh -o gomvm-install.sh
chmod +x gomvm-install.sh
./gomvm-install.sh

# PATH設定を更新
source ~/.bashrc
```

### 手動インストール

あるいは、リポジトリをクローンして手動で設定することもできます：

```bash
# リポジトリをクローン
git clone https://github.com/7rikazhexde/go-multi-version-manager.git
cd go-multi-version-manager

# gomvmをセットアップ
./gomvm setup

# PATH設定を更新
source ~/.bashrc
```

## 使用方法

### 基本的なコマンド

インストール後、以下のコマンドを使用できます：

```bash
# 利用可能なGoバージョンをリスト表示
gomvm list

# 特定のGoバージョンをインストール
gomvm install 1.24.1

# インストール済みのGoバージョンをリスト表示
gomvm installed

# 特定のGoバージョンをアンインストール
gomvm uninstall 1.24.1
```

### Goバージョンの切り替え

インストール済みのGoバージョン間を切り替えるには、`source`コマンドと`gomvm switch`を使用します：

```bash
# Go 1.24.1に切り替え
source gomvm switch 1.24.1
```

> [!IMPORTANT]
> 変更を現在のシェルに反映させるために、常に`switch`コマンドで`source`コマンドを使用してください。

## スクリプト

以下のスクリプトは`gomvm`コマンドによって内部的に使用されますが、必要に応じて直接使用することもできます：

### install_go_replace_default.sh

`/usr/local/go`に既存のバージョンを置き換えて、デフォルトバージョンのGoをインストールします。

使用方法

```bash
./install_go_replace_default.sh <goバージョン>
```

- 例: `./install_go_replace_default.sh 1.23.2`

このスクリプトは、`/usr/local/go`が既に存在する場合は削除の確認を求め、指定されたバージョンをインストールします。

---

### install_go_with_command.sh

`go install`コマンドを使用してGoをインストールし、複数のバージョンを`${HOME}/go/bin`にインストールできます。

使用方法

```bash
./install_go_with_command.sh <goバージョン>
```

- 例: `./install_go_with_command.sh 1.23.1`

このスクリプトは、`go install`を使用して指定されたバージョンをインストールし、`${HOME}/go/bin/go<バージョン>`に配置します。

---

### install_go_specific.sh

特定のバージョンのGoを`/usr/local/go<バージョン>`にインストールします。指定されたバージョンが既にインストールされている場合は、スキップされます。

使用方法

```bash
./install_go_specific.sh <goバージョン>
```

- 例: `./install_go_specific.sh 1.23.0`

このスクリプトでは、複数のバージョンを別々のディレクトリにインストールすることができます。

---

### switch_go_version.sh

指定されたGoバージョンに切り替えます。現在のシェルセッションで指定されたGoバージョンを使用するには、このスクリプトを`source`で実行してください。  
もし、指定されたGoバージョンがインストールされていない場合は、`install_go_with_command.sh`をスクリプト内で実行します。

使用方法

```bash
source ./switch_go_version.sh <goバージョン>
```

- 例: `source ./switch_go_version.sh 1.23.0`

`.bashrc`で設定されたデフォルトバージョンに戻るには、`source ~/.bashrc`を実行してください。

---

### list_go_versions.sh

公式ダウンロードページから利用可能なGoバージョンのリストを取得します。

使用方法

```bash
./list_go_versions.sh
```

このスクリプトは、[Goダウンロードページ](https://go.dev/dl/)から利用可能なすべてのバージョンを取得して表示します。

---

## 開発者向けオプション

### シェルスクリプト用のPre-commitフックの設定

コード品質を維持するのに役立つように、コミットの前にすべてのシェルスクリプトに対して自動的に`shellcheck`を実行する`pre-commit`フックを設定できます。これにより、`shellcheck`が問題を発見した場合にコミットが防止され、エラーのないスクリプトのみがコミットされるようになります。

### Pre-commitフック設定手順

1. `shellcheck`のインストール

   `shellcheck`がシステムにインストールされていることを確認してください。インストールされていない場合は、以下のコマンドでインストールしてください。

   ```bash
   sudo apt install shellcheck
   ```

1. 実行権限の追加

   まず、`create_pre-commit.sh`スクリプトに実行権限があることを確認します。

   ```bash
   chmod +x scripts/ci/create_pre-commit.sh
   ```

1. `create_pre-commit.sh`スクリプトの実行

   プロジェクトのルートディレクトリから、以下のコマンドを実行して`pre-commit`フックを設定します。

   ```bash
   ./scripts/ci/create_pre-commit.sh
   ```

   これにより、`.git/hooks/`に`pre-commit`フックが作成されます。このフックは、コミット時に`scripts/ubuntu`内のすべての`.sh`ファイルに対して自動的に`shellcheck`を実行します。  
   コミット前に手動で`pre-commit`フックを実行したい場合は、`.git/hooks/pre-commit`を実行してください。
