# go-multi-version-manager

このリポジトリには、複数のGoバージョンを管理、インストール、切り替えるためのスクリプトが含まれています。

[English](README.md) | 日本語

## 目次

- [go-multi-version-manager](#go-multi-version-manager)
  - [目次](#目次)
  - [注意事項](#注意事項)
  - [使用方法](#使用方法)
  - [スクリプト](#スクリプト)
    - [install\_go\_replace\_default.sh](#install_go_replace_defaultsh)
    - [install\_go\_with\_command.sh](#install_go_with_commandsh)
    - [install\_go\_specific.sh](#install_go_specificsh)
    - [switch\_go\_version.sh](#switch_go_versionsh)
    - [list\_go\_versions.sh](#list_go_versionssh)
  - [追加情報](#追加情報)

## 注意事項

- これらのスクリプトは**Ubuntu**用に設計されています。**Mac**と**Windows**では動作保証していません。
- `install_go_with_command.sh`で管理するGoバージョンについては、`$HOME/go/bin`が`PATH`に含まれていることを確認してください[^1]。
- `go version`を使用してインストールされたバージョンを確認し、正しくセットアップされていることを確認してください。
- 一般的なGoのインストールガイドについては、[公式Goドキュメント](https://go.dev/doc/install)を参照してください。

[^1]: `export PATH=/usr/local/go/bin:$PATH`

## 使用方法

```bash
git clone https://github.com/7rikazhexde/go-multi-version-manager.git
cd scripts/ubuntu
```

## スクリプト

### install_go_replace_default.sh

`/usr/local/go`に既存のバージョンを置き換えて、デフォルトバージョンのGoをインストールします。[^1]

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

## 追加情報

Goコマンドを介してインストール可能なGoバージョンのリストを取得するには、以下を実行します：

```bash
go install golang.org/dl@latest
go list golang.org/dl/go1.*
```

これにより、`golang.org/dl`を介してインストール可能なバージョンが表示されます。
