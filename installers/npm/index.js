#!/usr/bin/env node
/**
 * OpenCode SecOps Blueprint Installer (Node.js)
 * Usage: npx opencode-setup
 */

const { execSync, spawn } = require("child_process");
const fs = require("fs");
const path = require("path");
const os = require("os");

const REPO_URL = "https://github.com/AmidVoshakul/opencode-secops-blueprint.git";
const REPO_NAME = "opencode-secops-blueprint";
const TARGET_DIR = process.cwd();
const OPENCODE_DIR = path.join(TARGET_DIR, ".opencode");

const EXCLUDE_FILES = new Set(["AGENTS.md", "LICENSE", "README.md"]);
const EXCLUDE_DIRS = new Set([".git", "docs"]);

// Colors
const isTTY = process.stdout.isTTY;
const colors = {
  blue: isTTY ? "\x1b[34m" : "",
  green: isTTY ? "\x1b[32m" : "",
  yellow: isTTY ? "\x1b[33m" : "",
  red: isTTY ? "\x1b[31m" : "",
  cyan: isTTY ? "\x1b[36m" : "",
  reset: isTTY ? "\x1b[0m" : "",
};

function info(msg)    { process.stdout.write(`${colors.blue}[INFO]${colors.reset} ${msg}\n`); }
function success(msg) { process.stdout.write(`${colors.green}[OK]${colors.reset} ${msg}\n`); }
function warn(msg)    { process.stdout.write(`${colors.yellow}[WARN]${colors.reset} ${msg}\n`); }
function error(msg)   { process.stdout.write(`${colors.red}[ERROR]${colors.reset} ${msg}\n`); }

function progress(current, total, label) {
  if (!isTTY) return;
  const width = 40;
  const pct = Math.round((current / total) * 100);
  const filled = Math.round((current / total) * width);
  const bar = "█".repeat(filled) + " ".repeat(width - filled);
  process.stdout.write(`\r${colors.cyan}[${bar}]${colors.reset} ${pct}% ${label}`);
  if (current >= total) process.stdout.write("\n");
}

function checkPrerequisites() {
  info("Checking prerequisites...");
  try {
    execSync("git --version", { stdio: "ignore" });
  } catch {
    error("git is not installed. Install git and try again.");
    process.exit(1);
  }
  success("All prerequisites met.");
}

function checkExisting() {
  if (fs.existsSync(OPENCODE_DIR)) {
    process.stdout.write("\n");
    warn(`Directory .opencode/ already exists in ${TARGET_DIR}`);
    const readline = require("readline").createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    return new Promise((resolve) => {
      readline.question("Overwrite? (y/N): ", (choice) => {
        readline.close();
        if (choice.toLowerCase() === "y") {
          info("Backing up existing .opencode/ to .opencode.backup/");
          const backup = path.join(TARGET_DIR, ".opencode.backup");
          if (fs.existsSync(backup)) fs.rmSync(backup, { recursive: true });
          fs.renameSync(OPENCODE_DIR, backup);
        } else {
          info("Aborting installation.");
          process.exit(0);
        }
        resolve();
      });
    });
  }
  return Promise.resolve();
}

function cloneRepo(tmpDir) {
  return new Promise((resolve, reject) => {
    info("Cloning blueprint repository...");
    const dest = path.join(tmpDir, REPO_NAME);

    const git = spawn("git", ["clone", "--depth", "1", REPO_URL, dest], {
      stdio: ["ignore", "pipe", "pipe"],
    });

    git.stderr.on("data", (data) => {
      const line = data.toString();
      if (line.includes("remote:") || line.includes("Receiving") || line.includes("Resolving")) {
        process.stdout.write(`\r${colors.cyan}${line.trim()}${colors.reset}`);
      }
    });

    git.on("close", (code) => {
      process.stdout.write("\n");
      if (code !== 0) {
        error("Failed to clone repository.");
        reject(new Error("git clone failed"));
      } else {
        resolve(dest);
      }
    });
  });
}

async function copyFiles(srcDir) {
  const srcOpencode = path.join(srcDir, ".opencode");
  if (!fs.existsSync(srcOpencode)) {
    error(".opencode/ directory not found in repository.");
    process.exit(1);
  }

  // Count files
  let totalFiles = 0;
  function countFiles(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (EXCLUDE_DIRS.has(entry.name)) continue;
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) countFiles(fullPath);
      else if (!EXCLUDE_FILES.has(entry.name)) totalFiles++;
    }
  }
  countFiles(srcOpencode);

  info(`Copying ${totalFiles} blueprint files...`);

  let copied = 0;
  function doCopy(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (EXCLUDE_DIRS.has(entry.name)) continue;
      const fullPath = path.join(dir, entry.name);
      const relPath = path.relative(srcOpencode, fullPath);

      if (entry.isDirectory()) {
        doCopy(fullPath);
      } else if (!EXCLUDE_FILES.has(entry.name)) {
        const destFile = path.join(OPENCODE_DIR, relPath);
        fs.mkdirSync(path.dirname(destFile), { recursive: true });
        fs.copyFileSync(fullPath, destFile);
        copied++;
        progress(copied, totalFiles, relPath);
      }
    }
  }

  fs.mkdirSync(OPENCODE_DIR, { recursive: true });
  doCopy(srcOpencode);
  process.stdout.write("\n");
  success(`Copied ${copied} files to .opencode/`);
}

function patchConfig() {
  const configFile = path.join(OPENCODE_DIR, "opencode.json");
  if (!fs.existsSync(configFile)) {
    warn("opencode.json not found, skipping path patch.");
    return;
  }

  info("Configuring project path...");
  let content = fs.readFileSync(configFile, "utf8");
  content = content.replace(
    /\/home\/amid\/Develop\/opencode-secops-blueprint\//g,
    TARGET_DIR + "/"
  );
  fs.writeFileSync(configFile, content);
  success(`Project path set to: ${TARGET_DIR}`);
}

function printPostInstall() {
  process.stdout.write("\n");
  process.stdout.write(`${colors.green}========================================================${colors.reset}\n`);
  process.stdout.write(`${colors.green}  OpenCode SecOps Blueprint installed successfully!${colors.reset}\n`);
  process.stdout.write(`${colors.green}========================================================${colors.reset}\n`);
  process.stdout.write("\n");
  info("Next steps:");
  process.stdout.write("\n");
  process.stdout.write(`  1. Set your GitHub token:\n`);
  process.stdout.write(`     ${colors.cyan}export GITHUB_PERSONAL_ACCESS_TOKEN="your-pat-here"${colors.reset}\n`);
  process.stdout.write("\n");
  process.stdout.write(`  2. Launch OpenCode in your project:\n`);
  process.stdout.write(`     ${colors.cyan}opencode${colors.reset}\n`);
  process.stdout.write("\n");
  process.stdout.write(`  3. Run initialization:\n`);
  process.stdout.write(`     ${colors.cyan}/init${colors.reset}\n`);
  process.stdout.write("\n");
  info("Documentation: https://github.com/AmidVoshakul/opencode-secops-blueprint");
}

async function main() {
  process.stdout.write("\n");
  process.stdout.write(`${colors.green}========================================================${colors.reset}\n`);
  process.stdout.write(`${colors.green}  OpenCode SecOps Blueprint Installer${colors.reset}\n`);
  process.stdout.write(`${colors.green}========================================================${colors.reset}\n`);
  process.stdout.write("\n");

  checkPrerequisites();
  await checkExisting();

  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "opencode-setup-"));
  try {
    const srcDir = await cloneRepo(tmpDir);
    await copyFiles(srcDir);
    patchConfig();
    printPostInstall();
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
}

main().catch((err) => {
  error(err.message);
  process.exit(1);
});
