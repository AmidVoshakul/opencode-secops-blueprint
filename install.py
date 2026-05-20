#!/usr/bin/env python3
"""
OpenCode SecOps Blueprint Installer
Cross-platform installer (Linux/macOS/Windows)
Usage: python install.py
       or: curl -fsSL https://raw.githubusercontent.com/AmidVoshakul/opencode-secops-blueprint/main/install.py | python3
"""

import os
import sys
import json
import re
import shutil
import subprocess
import tempfile
import platform

REPO_URL = "https://github.com/AmidVoshakul/opencode-secops-blueprint.git"
REPO_NAME = "opencode-secops-blueprint"
TARGET_DIR = os.getcwd()
OPENCODE_DIR = os.path.join(TARGET_DIR, ".opencode")

EXCLUDE_FILES = {"AGENTS.md", "LICENSE", "README.md"}
EXCLUDE_DIRS = {".git", "docs"}

USE_COLORS = platform.system() != "Windows"
if USE_COLORS:
    RED, GREEN, YELLOW, BLUE, CYAN, NC = "\033[0;31m", "\033[0;32m", "\033[1;33m", "\033[0;34m", "\033[0;36m", "\033[0m"
else:
    RED = GREEN = YELLOW = BLUE = CYAN = NC = ""

def info(msg):    print(f"{BLUE}[INFO]{NC} {msg}")
def success(msg): print(f"{GREEN}[OK]{NC} {msg}")
def warn(msg):    print(f"{YELLOW}[WARN]{NC} {msg}")
def error(msg):   print(f"{RED}[ERROR]{NC} {msg}")

def progress_bar(current, total, label=""):
    width = 40
    pct = int(current * 100 / total) if total > 0 else 100
    filled = int(current * width / total) if total > 0 else width
    bar = "█" * filled + " " * (width - filled)
    sys.stdout.write(f"\r{CYAN}[{bar}]{NC} {pct:3d}% {label}")
    sys.stdout.flush()
    if current >= total:
        print()

def check_prerequisites():
    info("Checking prerequisites...")
    if not shutil.which("git"):
        error("git is not installed. Install git and try again.")
        sys.exit(1)
    success("All prerequisites met.")

def check_existing():
    if os.path.isdir(OPENCODE_DIR):
        print()
        warn(f"Directory .opencode/ already exists in {TARGET_DIR}")
        try:
            choice = input("Overwrite? (y/N): ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            choice = "n"
        if choice in ("y", "yes"):
            info("Backing up existing .opencode/ to .opencode.backup/")
            backup = os.path.join(TARGET_DIR, ".opencode.backup")
            if os.path.exists(backup):
                shutil.rmtree(backup)
            shutil.move(OPENCODE_DIR, backup)
        else:
            info("Aborting installation.")
            sys.exit(0)

def clone_repo(tmp_dir):
    info("Cloning blueprint repository...")
    dest = os.path.join(tmp_dir, REPO_NAME)

    process = subprocess.Popen(
        ["git", "clone", "--depth", "1", REPO_URL, dest],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, bufsize=1
    )

    for line in process.stdout:
        if "remote:" in line or "Receiving" in line or "Resolving" in line:
            sys.stdout.write(f"\r{CYAN}{line.strip()}{NC}")
            sys.stdout.flush()

    process.wait()
    print()

    if process.returncode != 0:
        error("Failed to clone repository.")
        sys.exit(1)

    return dest

def copy_files(src_dir):
    src_opencode = os.path.join(src_dir, ".opencode")
    if not os.path.isdir(src_opencode):
        error(".opencode/ directory not found in repository.")
        sys.exit(1)

    total_files = 0
    for root, dirs, files in os.walk(src_opencode):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        total_files += len(files)

    info(f"Copying {total_files} blueprint files...")

    copied = 0
    for root, dirs, files in os.walk(src_opencode):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

        for fname in files:
            if fname in EXCLUDE_FILES:
                continue

            src_file = os.path.join(root, fname)
            rel_path = os.path.relpath(src_file, src_opencode)
            dest_file = os.path.join(OPENCODE_DIR, rel_path)

            os.makedirs(os.path.dirname(dest_file), exist_ok=True)
            shutil.copy2(src_file, dest_file)

            copied += 1
            progress_bar(copied, total_files, rel_path)

    print()
    success(f"Copied {copied} files to .opencode/")

    # Copy .gitignore.template to project root
    template_src = os.path.join(src_dir, ".gitignore.template")
    template_dest = os.path.join(TARGET_DIR, ".gitignore.template")
    if os.path.isfile(template_src):
        shutil.copy2(template_src, template_dest)
        info("Copied .gitignore.template")

def configure_gitignore():
    gitignore = os.path.join(TARGET_DIR, ".gitignore")

    if not os.path.isfile(gitignore):
        template = os.path.join(TARGET_DIR, ".gitignore.template")
        if os.path.isfile(template):
            shutil.copy2(template, gitignore)
            success("Created .gitignore from template")
    else:
        with open(gitignore, "r") as f:
            content = f.read()
        if not re.search(r'^\.opencode/', content, re.MULTILINE):
            if content and not content.endswith('\n'):
                f = open(gitignore, "a")
                f.write("\n")
                f.close()
            with open(gitignore, "a") as f:
                f.write("# OpenCode local config (contains tokens)\n.opencode/\n")
            info("Added .opencode/ to .gitignore")

def get_filesystem_path():
    """Get filesystem root path for MCP, replace placeholder in opencode.json."""
    fs_path = os.environ.get("FILESYSTEM_PATH", "")

    if fs_path:
        info("Using path from $FILESYSTEM_PATH environment variable.")
    else:
        print()
        try:
            fs_path = input("Enter filesystem root path for MCP access (or set $FILESYSTEM_PATH): ").strip()
        except (EOFError, KeyboardInterrupt):
            fs_path = ""
        if not fs_path:
            warn("No path provided. You can configure it later in .opencode/opencode.json")
            return

    if not os.path.isdir(fs_path):
        warn(f"Directory '{fs_path}' does not exist. You can fix it later in .opencode/opencode.json")
        return

    success(f"Filesystem path set to: {fs_path}")

    config_file = os.path.join(OPENCODE_DIR, "opencode.json")
    if os.path.isfile(config_file):
        with open(config_file, "r") as f:
            content = f.read()
        content = content.replace("__FILESYSTEM_PATH__", fs_path)
        with open(config_file, "w") as f:
            f.write(content)
        success("Filesystem path configured in opencode.json")

def get_github_token():
    """Get and validate GitHub token, replace placeholder in opencode.json."""
    token = os.environ.get("GITHUB_PERSONAL_ACCESS_TOKEN", "")

    if token:
        info("Using token from $GITHUB_PERSONAL_ACCESS_TOKEN environment variable.")
    else:
        print()
        try:
            token = input("Enter GitHub Personal Access Token (or set $GITHUB_PERSONAL_ACCESS_TOKEN): ").strip()
        except (EOFError, KeyboardInterrupt):
            token = ""
        if not token:
            warn("No token provided. You can configure it later in .opencode/opencode.json")
            return

    info("Validating GitHub token...")
    try:
        import urllib.request
        req = urllib.request.Request(
            "https://api.github.com/user",
            headers={"Authorization": f"token {token}"}
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            if resp.status == 200:
                import json
                user = json.loads(resp.read())
                login = user.get("login", "unknown")
                success(f"Token valid (user: {login})")

                config_file = os.path.join(OPENCODE_DIR, "opencode.json")
                if os.path.isfile(config_file):
                    with open(config_file, "r") as f:
                        content = f.read()
                    content = content.replace("__GITHUB_TOKEN__", token)
                    with open(config_file, "w") as f:
                        f.write(content)
                    success("GitHub token configured in opencode.json")
            else:
                warn(f"Token validation failed (HTTP {resp.status}). You can fix it later in .opencode/opencode.json")
    except Exception as e:
        warn(f"Token validation failed: {e}. You can fix it later in .opencode/opencode.json")

def patch_config():
    config_file = os.path.join(OPENCODE_DIR, "opencode.json")
    if not os.path.isfile(config_file):
        warn("opencode.json not found, skipping configuration.")
        return

    info("Configuring project path...")

    with open(config_file, "r") as f:
        content = f.read()

    content = content.replace(
        "__PROJECT_PATH__",
        TARGET_DIR + "/"
    )

    with open(config_file, "w") as f:
        f.write(content)

    success(f"Project path set to: {TARGET_DIR}")

def print_post_install():
    print()
    print(f"{GREEN}{'=' * 56}{NC}")
    print(f"{GREEN}  OpenCode SecOps Blueprint installed successfully!{NC}")
    print(f"{GREEN}{'=' * 56}{NC}")
    print()
    info("Next steps:")
    print()
    print(f"  1. Launch OpenCode in your project:")
    print(f"     {CYAN}opencode{NC}")
    print()
    print(f"  2. Run initialization:")
    print(f"     {CYAN}/init{NC}")
    print()
    info("Install skills: npx antigravity-awesome-skills --path .opencode/skills")
    info("Documentation: https://github.com/AmidVoshakul/opencode-secops-blueprint")

def main():
    print()
    print(f"{GREEN}{'=' * 56}{NC}")
    print(f"{GREEN}  OpenCode SecOps Blueprint Installer{NC}")
    print(f"{GREEN}{'=' * 56}{NC}")
    print()

    check_prerequisites()
    check_existing()

    tmp_dir = tempfile.mkdtemp()
    try:
        src_dir = clone_repo(tmp_dir)
        copy_files(src_dir)
        configure_gitignore()
        patch_config()
        get_filesystem_path()
        get_github_token()
        print_post_install()
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

if __name__ == "__main__":
    main()
