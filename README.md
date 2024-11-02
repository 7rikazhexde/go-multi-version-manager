# go-multi-version-manager

This repository contains scripts for managing, installing, and switching between multiple Go versions.

English | [日本語](README_ja.md)

## Table of Contents

- [go-multi-version-manager](#go-multi-version-manager)
  - [Table of Contents](#table-of-contents)
  - [Notes](#notes)
  - [Usage](#usage)
  - [Scripts](#scripts)
    - [install\_go\_replace\_default.sh](#install_go_replace_defaultsh)
    - [install\_go\_with\_command.sh](#install_go_with_commandsh)
    - [install\_go\_specific.sh](#install_go_specificsh)
    - [switch\_go\_version.sh](#switch_go_versionsh)
    - [list\_go\_versions.sh](#list_go_versionssh)
  - [Additional Information](#additional-information)

## Notes

- These scripts are designed for **Ubuntu**; they are not guaranteed to work on **Mac** and **Windows**.
- For the Go version managed by `install_go_with_command.sh`, make sure that `$HOME/go/bin` is included in your `PATH`[^1].
- Check the installed version using `go version` and make sure it is set up correctly.
- For a general Go installation guide, see [official Go documentation](https://go.dev/doc/install).

[^1]: `export PATH=/usr/local/go/bin:$PATH`

## Usage

```bash
git clone https://github.com/7rikazhexde/go-multi-version-manager.git
cd scripts/ubuntu
```

## Scripts

### install_go_replace_default.sh

Installs the default version of Go in `/usr/local/go`, replacing any existing version.

Usage

```bash
./install_go_replace_default.sh <go_version>
```

- Example: `./install_go_replace_default.sh 1.23.2`

The script will prompt you to confirm the deletion of `/usr/local/go` if it already exists, and then install the specified version.

---

### install_go_with_command.sh

Installs Go using the `go install` command, allowing multiple versions to be installed in `${HOME}/go/bin`.

Usage

```bash
./install_go_with_command.sh <go_version>
```

- Example: `./install_go_with_command.sh 1.23.1`

The script installs the specified version using `go install` and places it in `${HOME}/go/bin/go<version>`.

---

### install_go_specific.sh

Installs a specific version of Go in `/usr/local/go<version>`. If the specified version is already installed, it will be skipped.

Usage

```bash
./install_go_specific.sh <go_version>
```

- Example: `./install_go_specific.sh 1.23.0`

This script allows for multiple versions to be installed in separate directories.

---

### switch_go_version.sh

Switches to a specified Go version. Run this script with source to use the specified Go version in the current shell session. If the specified Go version is not installed, this script will execute install_go_with_command.sh internally to install it.

Usage

```bash
source ./switch_go_version.sh <go_version>
```

- Example: `source ./switch_go_version.sh 1.23.0`

To return to the default version set in `.bashrc`, run `source ~/.bashrc`.

---

### list_go_versions.sh

Fetches a list of available Go versions from the official download page.

Usage

```bash
./list_go_versions.sh
```

This script retrieves all available versions from the [Go download page](https://go.dev/dl/) and displays them.

---

## Additional Information

To retrieve the list of Go versions available for installation via the Go command, run:

```bash
go install golang.org/dl@latest
go list golang.org/dl/go1.*
```

This will display the versions that can be installed via `golang.org/dl`.
