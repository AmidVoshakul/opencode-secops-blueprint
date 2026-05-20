#!/usr/bin/env bash
# OpenCode SecOps Blueprint Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/AmidVoshakul/opencode-secops-blueprint/main/install.sh | bash
#        or: bash install.sh

set -e

REPO_URL="https://github.com/AmidVoshakul/opencode-secops-blueprint.git"
REPO_NAME="opencode-secops-blueprint"
TARGET_DIR="$(pwd)"
OPENCODE_DIR="$TARGET_DIR/.opencode"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Progress bar
progress_bar() {
    local current=$1 total=$2 label=$3
    local width=40
    local pct=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    local bar=$(printf '%0.s█' $(seq 1 $filled))
    local spaces=$(printf '%0.s ' $(seq 1 $empty))
    printf "\r${CYAN}[%s%s]${NC} %3d%% %s" "$bar" "$spaces" "$pct" "$label"
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    local missing=0

    if ! command -v git &>/dev/null; then
        error "git is not installed. Install git and try again."
        missing=1
    fi

    if [ $missing -eq 1 ]; then
        exit 1
    fi

    success "All prerequisites met."
}

# Check if .opencode already exists
check_existing() {
    if [ -d "$OPENCODE_DIR" ]; then
        echo ""
        warn "Directory .opencode/ already exists in $TARGET_DIR"
        read -p "Overwrite? (y/N): " choice
        case "$choice" in
            y|Y) info "Backing up existing .opencode/ to .opencode.backup/";;
            *)   info "Aborting installation."; exit 0;;
        esac
        rm -rf "$TARGET_DIR/.opencode.backup"
        mv "$OPENCODE_DIR" "$TARGET_DIR/.opencode.backup"
    fi
}

# Clone repository
clone_repo() {
    local tmp_dir=$(mktemp -d)
    info "Cloning blueprint repository..."

    git clone --depth 1 --progress "$REPO_URL" "$tmp_dir/$REPO_NAME" 2>&1 | while IFS= read -r line; do
        if [[ "$line" == *"Receiving objects"* ]] || [[ "$line" == *"remote:"* ]]; then
            echo -ne "\r${CYAN}$line${NC}"
        fi
    done
    echo ""

    echo "$tmp_dir/$REPO_NAME"
}

# Copy files
copy_files() {
    local src=$1
    local total_files=$(find "$src/.opencode" -type f 2>/dev/null | wc -l)
    local copied=0

    info "Copying blueprint files..."
    mkdir -p "$TARGET_DIR/.opencode"

    if [ -d "$src/.opencode" ]; then
        find "$src/.opencode" -type f | while IFS= read -r file; do
            local rel_path="${file#$src/.opencode/}"
            local dest_dir="$TARGET_DIR/.opencode/$(dirname "$rel_path")"
            mkdir -p "$dest_dir"
            cp "$file" "$dest_dir/"
            copied=$((copied + 1))
            progress_bar $copied $total_files "Copying $rel_path"
        done
    fi

    echo ""
    success "Copied $total_files files to .opencode/"

    # Copy .gitignore.template to project root
    if [ -f "$src/.gitignore.template" ]; then
        cp "$src/.gitignore.template" "$TARGET_DIR/.gitignore.template"
        info "Copied .gitignore.template"
    fi
}

# Configure .gitignore
configure_gitignore() {
    local gitignore="$TARGET_DIR/.gitignore"

    if [ ! -f "$gitignore" ]; then
        local template="$TARGET_DIR/.gitignore.template"
        if [ -f "$template" ]; then
            cp "$template" "$gitignore"
            success "Created .gitignore from template"
        fi
    else
        if ! grep -q '^\.opencode/' "$gitignore" 2>/dev/null; then
            echo "" >> "$gitignore"
            echo "# OpenCode local config (contains tokens)" >> "$gitignore"
            echo ".opencode/" >> "$gitignore"
            info "Added .opencode/ to .gitignore"
        fi
    fi
}

# Get filesystem path
get_filesystem_path() {
    local fs_path=""

    if [ -n "$FILESYSTEM_PATH" ]; then
        fs_path="$FILESYSTEM_PATH"
        info "Using path from \$FILESYSTEM_PATH environment variable."
    else
        echo ""
        echo -n "${CYAN}Enter filesystem root path for MCP access (or set \$FILESYSTEM_PATH): ${NC}"
        read -r fs_path
        if [ -z "$fs_path" ]; then
            warn "No path provided. You can configure it later in .opencode/opencode.json"
            return
        fi
    fi

    # Validate path exists
    if [ ! -d "$fs_path" ]; then
        warn "Directory '$fs_path' does not exist. You can fix it later in .opencode/opencode.json"
        return
    fi

    success "Filesystem path set to: $fs_path"

    # Replace placeholder in opencode.json
    local config_file="$TARGET_DIR/.opencode/opencode.json"
    if [ -f "$config_file" ]; then
        python3 -c "
import sys, os

config_path = '$config_file'
fs_path = '$fs_path'

with open(config_path, 'r') as f:
    content = f.read()

content = content.replace('__FILESYSTEM_PATH__', fs_path)

with open(config_path, 'w') as f:
    f.write(content)
" 2>/dev/null || python -c "
import sys, os

config_path = '$config_file'
fs_path = '$fs_path'

with open(config_path, 'r') as f:
    content = f.read()

content = content.replace('__FILESYSTEM_PATH__', fs_path)

with open(config_path, 'w') as f:
    f.write(content)
" 2>/dev/null || warn "Failed to patch filesystem path. Please update manually in opencode.json"
    fi
}

# Get GitHub token
get_github_token() {
    local token=""

    if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
        token="$GITHUB_PERSONAL_ACCESS_TOKEN"
        info "Using token from \$GITHUB_PERSONAL_ACCESS_TOKEN environment variable."
    else
        echo ""
        echo -n "${CYAN}Enter GitHub Personal Access Token (or set \$GITHUB_PERSONAL_ACCESS_TOKEN): ${NC}"
        read -r token
        if [ -z "$token" ]; then
            warn "No token provided. You can configure it later in .opencode/opencode.json"
            return
        fi
    fi

    # Validate token via GitHub API
    info "Validating GitHub token..."
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $token" https://api.github.com/user)

    if [ "$response" = "200" ]; then
        local login
        login=$(curl -s -H "Authorization: token $token" https://api.github.com/user | python3 -c "import sys,json; print(json.load(sys.stdin)['login'])" 2>/dev/null || echo "unknown")
        success "Token valid (user: $login)"

        # Replace placeholder in opencode.json
        local config_file="$TARGET_DIR/.opencode/opencode.json"
        if [ -f "$config_file" ]; then
            sed -i "s/__GITHUB_TOKEN__/$token/g" "$config_file"
            success "GitHub token configured in opencode.json"
        fi
    else
        warn "Token validation failed (HTTP $response). You can fix it later in .opencode/opencode.json"
    fi
}

# Patch config (project path)
patch_config() {
    local config_file="$TARGET_DIR/.opencode/opencode.json"

    if [ ! -f "$config_file" ]; then
        warn "opencode.json not found, skipping configuration."
        return
    fi

    info "Configuring project path..."

    if command -v python3 &>/dev/null; then
        python3 -c "
import json, sys, os

config_path = '$config_file'
project_path = '$TARGET_DIR'

with open(config_path, 'r') as f:
    content = f.read()

content = content.replace('__PROJECT_PATH__', project_path + '/')

with open(config_path, 'w') as f:
    f.write(content)

print('Project path set to: ' + project_path)
"
    elif command -v python &>/dev/null; then
        python -c "
import json, sys, os

config_path = '$config_file'
project_path = '$TARGET_DIR'

with open(config_path, 'r') as f:
    content = f.read()

content = content.replace('__PROJECT_PATH__', project_path + '/')

with open(config_path, 'w') as f:
    f.write(content)

print('Project path set to: ' + project_path)
"
    else
        warn "Python not found. Please manually update --project-path in .opencode/opencode.json"
    fi
}

# Print post-install instructions
print_post_install() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${GREEN}OpenCode SecOps Blueprint installed successfully!${NC}        ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    info "Next steps:"
    echo ""
    echo "  1. Launch OpenCode in your project:"
    echo -e "     ${CYAN}opencode${NC}"
    echo ""
    echo "  2. Run initialization:"
    echo -e "     ${CYAN}/init${NC}"
    echo ""
    info "Install skills: npx antigravity-awesome-skills --path .opencode/skills"
    info "Documentation: https://github.com/AmidVoshakul/opencode-secops-blueprint"
}

# Cleanup
cleanup() {
    if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}

trap cleanup EXIT

# Main
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${GREEN}OpenCode SecOps Blueprint Installer${NC}                    ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

check_prerequisites
check_existing

TMP_DIR=$(mktemp -d)
clone_repo_result=$(clone_repo)
SRC_DIR=$(echo "$clone_repo_result" | tail -1)

copy_files "$SRC_DIR"
configure_gitignore
patch_config
get_filesystem_path
get_github_token
print_post_install
