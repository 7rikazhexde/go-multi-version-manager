#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

create_pre_commit() {
    cat > "$1" << EOF
#!/bin/bash

# Pre-commit hook to run shellcheck on all .sh files in scripts/ubuntu
./scripts/ci/shellcheckfiles.sh "$SCRIPT_DIR/../scripts/ubuntu"
if [ \$? -ne 0 ]; then
    echo "Commit aborted due to shellcheck errors."
    exit 1
fi
EOF

    if [ "$2" == "execute" ]; then
        chmod +x "$1"
        echo "$1 created with execution permission."
    else
        echo "$1 created."
    fi
}

if [ -f "$SCRIPT_DIR/../.git/hooks/pre-commit" ]; then
    read -r -p "$SCRIPT_DIR/../.git/hooks/pre-commit already exists. Do you want to create $SCRIPT_DIR/../.git/hooks/pre-commit.second instead? (y/N): " choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        create_pre_commit "$SCRIPT_DIR/../.git/hooks/pre-commit.second"
        exit 0
    else
        create_pre_commit "$SCRIPT_DIR/../.git/hooks/pre-commit" "execute"
        exit 0
    fi
fi

create_pre_commit "$SCRIPT_DIR/../.git/hooks/pre-commit" "execute"
exit 0
