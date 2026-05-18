# OpenCode SecOps Blueprint 🚀

Enterprise-grade Infrastructure-as-Code (IaC) orchestration framework designed exclusively to superpower, discipline, and secure autonomous AI agents inside the **OpenCode** ecosystem. 

This repository serves as a master template/donor blueprint that injects an advanced multi-agent runtime pipeline, automatic capability discovery, and strict security guardrails into any software development workspace.

---

## 🏗️ Architectural Topology

The orchestration matrix is split into three decoupled operational layers:

```text
  [ AGENTS.md ]  <─── System Prompt Hypervisor (Enforces Discipline & Type-Safety)
        │
        ▼
[ opencode.json ] <─── Zero-Trust Security Firewall (Enforces Deny-By-Default)
        │
        ▼
 [ Meta-Scripts ] <─── Cache-driven Multi-Skill Router (<100ms MD5 Auto-Discovery)
```

1. **Global Discipline Layer (`AGENTS.md`):** Deep behavioral compiler. Enforces mandatory `code-index` scanning, context year anchoring (2026), standard *Conventional Commits*, and multi-turn prompt sanitization.
2. **Security Perimeter Firewall (`opencode.json`):** Strict *Deny-by-default* shield. Isolates local `code-index` bin execution paths (`uvx`) and locks all destructive Git interactions behind explicit manual approval (`"ask"` tokens).
3. **Dynamic Orchestration Engine (`agent-orchestrator/`):** Multi-agent lifecycle controller. Loops through physical directory metadata, scores tools applicability, and maps execution paths using complex pipeline topologies.

---

## ⛓️ Unified Slash Commands Loop

This blueprint deploys **8 custom autonomous routines** to your local project scope. Every routine leverages high-density context passing via structural `---CONTEXT-BRIDGE---` handovers:

```text
📥 /init ➔ 📋 /doctor-env ➔ 📥 /onboard ➔ 🛠️ /architect ➔ 🧪 /pro-test ➔ 🧹 /cleaner ➔ 📝 /doc-sync ➔ 🚀 /pr-master
                                                                                └── 🩺 /doctor (On Crash)
```

- **/init** *(Override)* — Auto-detects workspace technology stack and injects a robust, tailored `AGENTS.md` system blueprint.
- **/doctor-env** — Audit control center. Cross-references local JSON parameters against live web schemas, checks for security compliance gaps, and auto-generates clean Git permissions arrays.
- **/onboard** — Launches a deep historical Git archaeology pass, scans user timelines, and executes a multi-page web crawl of competitor GitHub trackers to aggregate closed bug panic data (Post-Mortem mitigation mapping). Auto-generates `ARCHITECTURE.md`.
- **/architect** — Scaffolds empty components, models, interfaces, and test fixtures natively mimicking existing layout design patterns.
- **/pro-test** — Executes advanced language-agnostic mutation testing (intentionally breaks functions to detect and rewrite "fake/empty" mocks) and dynamically scales the Test Pyramid.
- **/cleaner** — Safe automated garbage collector. Purges trailing whitespaces, unreferenced internal module imports, and stale local environment debug strings.
- **/doctor** — Critical runtime error solver. Scrapes StackOverflow threads and community issue logs to compile functional workarounds.
- **/doc-sync** — Synchronizes active architectural parameters into a strict matrix of 7 technical `.md` domain guides inside `docs/`.
- **/pr-master** — Wraps staging changes, migrates code out of protected branches, creates descriptive commit records, and deploys clean GitHub Pull Requests linked to active tickets.

---

## ⚙️ Core Platform Requirements & Tooling Installation

The orchestration pipeline relies heavily on the fast package installer **`uv`** (`uvx`) and native `npx` execution wrappers.

### 1. Install System Prerequisites
Ensure `uv` and Node.js are available on your host system:
```bash
# Install uv package manager (provides uvx binary)
curl -LsSf https://astral.sh | sh

# Verify installation paths
export PATH="$HOME/.local/bin:$PATH"
uvx --version
npx --version
```

### 2. Verified 100% Working MCP Configuration Matrix
Inject this identical block into your `.opencode/opencode.json` file. It maps 13 specialized local Model Context Protocol (MCP) server nodes:

```json
  "mcp": {
    "time": {
      "type": "local",
      "enabled": true,
      "command": ["/home/amid/.local/bin/uvx", "mcp-server-time"]
    },
    "duckduckgo": {
      "type": "local",
      "enabled": false,
      "command": ["/home/amid/.local/bin/uvx", "duckduckgo-mcp-server"]
    },
    "searxng": {
      "type": "local",
      "enabled": true,
      "command": ["npx", "-y", "mcp-searxng"],
      "environment": {
        "SEARXNG_URL": "http://localhost:8081"
      }
    },
    "sequential-thinking": {
      "type": "local",
      "enabled": true,
      "command": ["/home/amid/.local/bin/uvx", "sequential-thinking-mcp"]
    },
    "filesystem": {
      "type": "local",
      "enabled": true,
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/home/amid/Develop/"]
    },
    "fetch": {
      "type": "local",
      "enabled": true,
      "command": ["uvx", "mcp-server-fetch"]
    },
    "chrome-devtools": {
      "type": "local",
      "enabled": true,
      "command": ["npx", "-y", "chrome-devtools-mcp@latest"]
    },
    "playwright_mcp": {
      "type": "local",
      "enabled": true,
      "command": ["npx", "-y", "@playwright/mcp@latest"]
    },
    "context7": {
      "type": "local",
      "enabled": true,
      "command": ["npx", "-y", "@upstash/context7-mcp@latest"]
    },
    "memory": {
      "type": "local",
      "enabled": true,
      "command": ["npx", "-y", "@modelcontextprotocol/server-memory"]
    },
    "git": {
      "type": "local",
      "enabled": true,
      "command": ["/home/amid/.local/bin/uvx", "mcp-server-git"]
    },
    "code-index": {
      "type": "local",
      "enabled": true,
      "command": [
        "/home/amid/.local/bin/uvx",
        "code-index-mcp",
        "--project-path",
        "/home/amid/Develop/<project>/"
      ]
    },
    "github": {
      "type": "local",
      "enabled": true,
      "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
      "environment": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_PERSONAL_ACCESS_TOKEN_HERE"
      }
    }
  }
```

### ⚠️ Mandatory Workspace Customization Notes
Before launching agent routines, you MUST configure your distinct project target parameters:
1. **`code-index` Project Path:** Modify the `--project-path` parameter inside the JSON block above to point directly to your active repository target (e.g., change `/home/amid/Develop/chatorai/` to your target directory `/home/amid/Develop/nest/`). This guarantees that deep symbol lookups parse the correct files.
2. **`github` Auth Token:** Inject your GitHub Personal Access Token (PAT) directly into the `GITHUB_PERSONAL_ACCESS_TOKEN` environment variable slot. This token must possess comprehensive `repo` and `pull_requests` scope definitions to authorize the `/pr-master` engine.

### 🔍 Verification Command
To verify that all 13 servers are properly bound, compiled, and online, run the native OpenCode validation tool:
```bash
opencode mcp list
```
*Ensure all targets display operational bounds and exposed tool schemas without exceptions before proceeding.*

---

## 🚀 Rapid Deployment (Installation)

To spin up this advanced SecOps engine inside a clean or legacy development workspace, clone the repository layout manually:

```bash
# 1. Clone the master donor footprint into your project path
git clone https://github.com .tmp_blueprint

# 2. Merge infrastructure folders
mkdir -p .opencode/commands .opencode/instructions .opencode/skills
cp -r .tmp_blueprint/.opencode/commands/* .opencode/commands/
cp -r .tmp_blueprint/.opencode/instructions/* .opencode/instructions/
cp -r .tmp_blueprint/.opencode/skills/* .opencode/skills/
cp .tmp_blueprint/.opencode/opencode.json .opencode/

# 3. Clean up installation artifacts
rm -rf .tmp_blueprint
```

---

## 🛡️ SecOps Guardrails & Vulnerability Mitigation

This architecture is hardened against the **OWASP Agentic Top 10 2026** specifications:

- **Anti-ASI01/ASI05 (Goal Hijacking & Command Injection):** All string variables passed into active terminal processes are pre-filtered via robust input encapsulation loops inside Python execution nodes. Bypasses raw terminal evaluation completely.
- **Anti-ASI04 (Ecosystem Skill Poisoning):** Evaluates local skill registries through an immutable point-allocation scoring algorithm. Any unverified community skill tool is instantly dropped by the global `"*" : "deny"` kernel firewall rules.
- **Environment Isolation:** Python execution sequences bypass the system-wide shell constraint using isolated, lightning-fast ephemeral caching maps:
```bash
uv run --with "pyyaml>=6.0" python .opencode/skills/...
```

---

## 📊 Compliance Diagnostics

Run the integrated environment auditor to verify data synchronization bounds and pipeline status layouts:

```bash
uv run --with "pyyaml>=6.0" python .opencode/skills/agent-orchestrator/scripts/scan_registry.py --status
```

## 📜 License
This project-local optimization framework is distributed under the strict terms of the MIT License. Continuous automated audits enforced.
