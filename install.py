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
import shutil
import subprocess
import tempfile
import platform

REPO_URL = "https://github.com/AmidVoshakul/opencode-secops-blueprint.git"
REPO_NAME = "opencode-secops-blueprint"
TARGET_DIR = os.getcwd()
OPENCODE_DIR = os.path.join(TARGET_DIR, ".opencode")

# Files/directories to exclude from copy
EXCLUDE_FILES = {"AGENTS.md", "LICENSE", "README.md"}
EXCLUDE_DIRS = {".git", "docs"}

# Colors (disabled on Windows without colorama)
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

    # Count total files
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

def patch_config():
    config_file = os.path.join(OPENCODE_DIR, "opencode.json")
    if not os.path.isfile(config_file):
        warn("opencode.json not found, skipping path patch.")
        return

    info("Configuring project path...")

    with open(config_file, "r") as f:
        content = f.read()

    content = content.replace(
        "/home/amid/Develop/opencode-secops-blueprint/",
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
    print(f"  1. Set your GitHub token:")
    print(f"     {CYAN}export GITHUB_PERSONAL_ACCESS_TOKEN=\"your-pat-here\"{NC}")
    print()
    print(f"  2. Launch OpenCode in your project:")
    print(f"     {CYAN}opencode{NC}")
    print()
    print(f"  3. Run initialization:")
    print(f"     {CYAN}/init{NC}")
    print()
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
        patch_config()
        print_post_install()
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

if __name__ == "__main__":
    main()
