# OpenCode SecOps Blueprint

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
  <img src="https://img.shields.io/badge/Version-1.0.0-green.svg" alt="Version" />
  <img src="https://img.shields.io/badge/OpenCode-✓-purple.svg" alt="OpenCode Compatible" />
  <img src="https://img.shields.io/badge/Security-OWASP_Agentic_Top_10-red.svg" alt="Security" />
</p>

<p align="center">
  <strong>Enterprise-grade configuration framework to supercharge, discipline, and secure autonomous AI agents inside the OpenCode ecosystem.</strong>
</p>

<p align="center">
  Drop-in <code>.opencode/</code> directory that injects multi-agent pipelines, automatic capability discovery, and strict security guardrails into any development workspace.
</p>

---

## 🚀 Installation

Choose your preferred method. All methods clone the blueprint, copy `.opencode/` to your project, and auto-configure paths.

Run from your project's root directory. If `.opencode/` already exists, you'll be prompted before overwriting.

### Quick Install

```bash
# Node.js / npm (any OS)
npx opencode-setup

# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/AmidVoshakul/opencode-secops-blueprint/main/install.sh | bash

# Windows PowerShell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/AmidVoshakul/opencode-secops-blueprint/main/install.ps1 | Invoke-Expression
```

### Fallback (Python)

Download `install.py` from the repository and run:
```bash
python install.py
```

### Manual Install

```bash
git clone https://github.com/AmidVoshakul/opencode-secops-blueprint.git
cd opencode-secops-blueprint
mkdir -p ../.opencode
cp -r .opencode/* ../.opencode/
cd .. && rm -rf opencode-secops-blueprint
```

Then update `--project-path` in `.opencode/opencode.json` to your project directory.

---

## ⚡ Quick Start

1. **Set environment variables** before launching OpenCode:
   ```bash
   # Add to ~/.bashrc, ~/.zshrc, or your terminal profile
   export GITHUB_PERSONAL_ACCESS_TOKEN="your-github-pat-here"
   ```
   - Generate a PAT at [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
   - Required scopes: `repo`, `read:org`, `workflow`
   - **Never hardcode this token** — the blueprint uses `${GITHUB_PERSONAL_ACCESS_TOKEN}`

2. **Launch OpenCode** in your project:
   ```bash
   opencode
   ```

3. **Run initialization**:
   ```
   /init
   ```

---

## 🔧 Slash Commands

| Command | Description |
|---|---|
| `/init` | Auto-detect tech stack, generate `AGENTS.md` |
| `/doctor-env` | Full environment audit: config, LSP, Git permissions |
| `/onboard` | Deep project reconnaissance: git history, plans, competitors |
| `/architect` | Scaffold new modules following project patterns |
| `/pro-test` | Mutation testing, coverage audit, test generation |
| `/cleaner` | Remove dead code, unused imports, trailing whitespaces |
| `/doctor` | Debug runtime errors via GitHub Issues and web research |
| `/doc-sync` | Synchronize documentation with codebase changes |
| `/git` | Safe atomic commits with secret detection |
| `/review` | Code review focused on bugs, security, performance |
| `/guard` | Adversarial security audit (OWASP Agentic Top 10) |
| `/compare` | Cross-project benchmarking and competitor analysis |
| `/pr-master` | Create feature branch, push to GitHub, open PR |

---

## 🤖 Sub-Agents

Specialized agents run in isolated context windows — they don't pollute your main conversation.

| Agent | Tools | Purpose |
|---|---|---|
| `@security-auditor` | 🔍 readonly | Security audit, OWASP Top 10, CVE scanning |
| `@docs-writer` | ✏️ write+edit | Documentation creation and maintenance |
| `@test-engineer` | 🧪 bash+write+edit | Test writing, coverage, mutation testing |
| `@code-reviewer` | 🔎 readonly | Code review, best practices, performance |

Invoke agents directly with `@agent-name` or through their dedicated commands.

---

## 🔌 MCP Servers

The blueprint configures **12 MCP servers** out of the box:

| Server | Purpose |
|---|---|
| `time` | Temporal context (2026 anchor) |
| `searxng` | Private web search |
| `sequential-thinking` | Complex reasoning |
| `filesystem` | File operations |
| `fetch` | URL content retrieval |
| `chrome-devtools` | Browser automation |
| `playwright_mcp` | E2E testing automation |
| `context7` | Library documentation lookup |
| `memory` | Session knowledge graph |
| `git` | Version control via MCP |
| `code-index` | Deep symbol indexing |
| `github` | PR, issues, repo operations |

All Git operations are protected by `"ask"` permissions — no automatic commits, pushes, or branch switches.

---

## 🛡️ Security

Hardened against **OWASP Agentic Top 10 2026**:

- **Pre-commit secret detection** — scans for hardcoded tokens (GitHub PAT, OpenAI keys, AWS keys, JWT, private keys) before every commit
- **Input sanitization** — all shell parameters validated via `if/fi` guards
- **Skill firewall** — `"*": "deny"` default, explicit allowlist only
- **Isolated execution** — Python runs via `uv run` in ephemeral environments
- **Zero-trust Git** — all 8 Git operations require explicit user approval

---

## 📄 License

[MIT License](./LICENSE)
