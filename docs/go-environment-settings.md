# 🛠️ Go Environment Variables and PATH Configuration Guide

This document explains the PATH settings and environment variables for effectively using gomvm.

## 📝 Go Environment Configuration and PATH Structure in gomvm

The official Go installation instructions typically add only the system Go binary to the PATH as follows:

```bash
# Configuration based on official installation instructions
export PATH=$PATH:/usr/local/go/bin
```

In contrast, gomvm uses the following PATH configuration:

```bash
# Add the system Go binary to the beginning of PATH (for version switching)
export PATH="/usr/local/go/bin:$PATH"

# Also add the user-level Go tools path (for tools installed via go install command)
export PATH="$HOME/go/bin:$PATH"
```

gomvm adopts this configuration method to efficiently switch between multiple versions and make version-specific tools installed with the `go install` command available.

## 🔍 The Role and Order of Each Setting

1. **`/usr/local/go/bin`** (System-level Go)
   - Default Go installation location
   - Go binary shared by all users
   - Go updated by `install_go_replace_default.sh`

2. **`$HOME/go/bin`** (User-level Go)
   - Location for tools installed with the `go install` command
   - Location for version-specific Go binaries installed by `install_go_with_command.sh` (e.g., `go1.24.0`)
   - User-specific Go tools

## ⚙️ PATH Setting Order and Priority

The final search order of the PATH is determined by the gomvm configuration and execution environment:

### `.bashrc` Configuration When gomvm is Installed

```bash
if command -v gomvm &> /dev/null || [ -f "$HOME/.config/gomvm/config" ]; then
  # gomvm processing (checking and applying version selection)
  ...
else
  # Apply only standard Go settings if gomvm is not present
  export PATH="/usr/local/go/bin:$PATH"
  export PATH="$HOME/go/bin:$PATH"
fi
```

This applies different PATH settings depending on the environment:

### Environment Without gomvm

Applied in the normal order:

```bash
/usr/local/go/bin:$HOME/go/bin:other system paths
```

### Environment With gomvm After Switching

The specific version path is prioritized by the `switch` command:

```bash
$GOROOT/bin:$HOME/go/bin:/usr/local/go/bin:other system paths
```

This design ensures that:

- The version selected by gomvm takes highest priority
- The system default Go is used if no version-specific binary is available
- Other system commands remain available as usual

## 🔄 GOROOT and Version Switching Mechanism

### What is GOROOT

GOROOT is an environment variable that points to the Go installation directory. This directory contains the standard library, compiler, tools, and all files necessary for Go execution.

### The `go<version> env GOROOT` Command

A command to check the installation directory of a specific Go version:

```bash
$ go1.24.0 env GOROOT
/home/user/sdk/go1.24.0
```

This command returns the exact directory path where the specified Go version is installed. It can be executed for any version (e.g., `go1.23.0`, `go1.22.1`, etc.) to obtain the GOROOT specific to that version.

### Usage in gomvm

In gomvm's `switch_go_version.sh`, it is used as follows:

```bash
# Get the version-specific GOROOT
GOROOT=$(go${GO_VERSION} env GOROOT)

# Set environment variables
export GOROOT="$GOROOT"
export PATH="$GOROOT/bin:$PATH"
```

This process:

- Accurately identifies the installation directory of a specific Go version
- Prioritizes that version's executable binary
- Uses dependencies like the standard library from the same version

## 🔑 Key Points of gomvm and Go PATH Configuration

### Differences Between Official Configuration and gomvm

The official Go documentation explains adding `/usr/local/go/bin` to the PATH, which makes the Go version installed on the system available. To achieve multi-version management, gomvm adds the path to the beginning of PATH like `export PATH="/usr/local/go/bin:$PATH"`.

### Differences Based on Execution Environment

- **When gomvm is not installed**: Following the official setup, the Go version installed on the system is available (when not using `go install` and `go<version> env GOROOT`)
- **When gomvm is installed but not switched**: The system default Go (`/usr/local/go/bin/go`) is used
- **When switched with gomvm's switch**: The appropriate GOROOT is identified from the version-specific binary installed in `$HOME/go/bin` (e.g., `go1.24.0`), and that version is used preferentially

This design allows you to maintain the system's default Go while easily switching to different versions for specific projects.

### The Importance of `$HOME/go/bin`

This directory stores tools installed with the `go install` command and version-specific Go binaries. Without adding it to the PATH, you cannot directly call these tools or binaries.

## 🛠️ Troubleshooting

### Problem: Version Is Not Switching

Check points:

- Is `$HOME/go/bin` included in your PATH?
- Does the selected version binary exist? (`ls -la $HOME/go/bin/go*`)
- Are you running the script with the `source` command?

### Problem: `command not found` Error

Check points:

- Is the PATH configuration correct?
- Are changes to `.bashrc` reflected? (`source ~/.bashrc`)
- Is the `gomvm` command in `/usr/local/bin` or `$HOME/.local/bin`?

## 🔗 Related Resources

- [Go Official Documentation - Installation Instructions](https://go.dev/doc/install)
- [Go Environment Variables Details](https://pkg.go.dev/cmd/go#hdr-Environment_variables)
