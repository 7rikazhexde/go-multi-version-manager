#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PATH="$SCRIPT_DIR/../../.git/hooks/pre-commit"

create_pre_commit() {
    # Creating pre-commit hooks
    cat > "$HOOK_PATH" << 'EOF'
#!/bin/bash

# Pre-commit hook to run shellcheck on all .sh files in scripts/ubuntu
./scripts/ci/shellcheckfiles.sh "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../scripts/ubuntu"
if [ $? -ne 0 ]; then
    echo "Commit aborted due to shellcheck errors."
    exit 1
fi

# Pre-commit hook to run shellcheck on .sh files in repository root
./scripts/ci/shellcheckfiles.sh "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
if [ $? -ne 0 ]; then
    echo "Commit aborted due to shellcheck errors."
    exit 1
fi

# Check gomvm file in repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
if [ -f "$REPO_ROOT/gomvm" ]; then
    echo "Running shellcheck on $REPO_ROOT/gomvm..."
    shellcheck "$REPO_ROOT/gomvm"
    if [ $? -ne 0 ]; then
        echo "Commit aborted due to shellcheck errors in gomvm."
        exit 1
    fi
    echo "----------------------------------------"
fi
EOF

    # Check existence of files and grant permissions after creation
    if [ -f "$HOOK_PATH" ]; then
        chmod +x "$HOOK_PATH"
        echo "$HOOK_PATH created with execution permission."
    else
        echo "Error: Failed to create $HOOK_PATH."
        exit 1
    fi
}

# Processing when there is an existing hook
if [ -f "$HOOK_PATH" ]; then
    read -r -p "$HOOK_PATH already exists. Overwrite it? (y/N): " choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        create_pre_commit
    else
        echo "Aborted."
        exit 0
    fi
else
    create_pre_commit
fi

exit 0