# OpenCode SecOps Blueprint

Enterprise-grade configuration framework designed to supercharge, discipline, and secure autonomous AI agents inside the **OpenCode** ecosystem.

This repository serves as a master template that injects an advanced multi-agent runtime pipeline, automatic capability discovery, and strict security guardrails into any software development workspace.

## Installation

Choose your preferred method. All methods perform the same steps:
clone the blueprint, copy `.opencode/` to your project, and configure paths.

Run from your project's root directory. If `.opencode/` already exists, you'll be prompted before overwriting.

### Quick Install

```bash
# Node.js / npm (recommended)
npx opencode-setup

# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/AmidVoshakul/opencode-secops-blueprint/main/install.sh | bash

# Windows PowerShell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/AmidVoshakul/opencode-secops-blueprint/main/install.ps1 | Invoke-Expression

# Python (any OS, no dependencies)
python <(curl -fsSL https://raw.githubusercontent.com/AmidVoshakul/opencode-secops-blueprint/main/install.py)
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

## Quick Start

1. **Set environment variables** before launching OpenCode:
   ```bash
   # Add to ~/.bashrc, ~/.zshrc, or your terminal profile
   export GITHUB_PERSONAL_ACCESS_TOKEN="your-github-pat-here"
   ```
   - Generate a PAT at GitHub Settings → Developer settings → Personal access tokens (classic)
   - Required scopes: `repo`, `read:org`, `workflow`
   - **Never hardcode this token in any file** — the blueprint uses `${GITHUB_PERSONAL_ACCESS_TOKEN}`

2. **Launch OpenCode** in your project:
   ```bash
   opencode
   ```

3. **Run initialization** inside OpenCode:
   ```
   /init
   ```

## Slash Commands

| Command | Description |
|---|---|
| `/init` | Auto-detect tech stack, generate `AGENTS.md` |
| `/doctor-env` | Audit config, verify permissions, sync skills |
| `/onboard` | Git archaeology, competitor analysis, plan sync |
| `/architect` | Scaffold new modules following project patterns |
| `/pro-test` | Mutation testing, coverage audit, test generation |
| `/cleaner` | Remove dead code, unused imports, trailing whitespaces |
| `/doctor` | Debug runtime errors via web research |
| `/doc-sync` | Synchronize documentation with codebase |
| `/git` | Safe commit, branch, and push workflow |
| `/guard` | Adversarial security audit (OWASP Agentic Top 10) |
| `/compare` | Cross-project benchmarking and architecture analysis |
| `/pr-master` | Create PR with professional description |

## Sub-Agents

| Agent | Mode | Purpose |
|---|---|---|
| `@security-auditor` | readonly | Security audit, OWASP Top 10, CVE scanning |
| `@docs-writer` | write+edit | Documentation creation and maintenance |
| `@test-engineer` | bash+write+edit | Test writing, coverage, mutation testing |
| `@code-reviewer` | readonly | Code review, best practices, performance |

## MCP Servers

The blueprint configures 12 MCP servers: `time`, `searxng`, `sequential-thinking`, `filesystem`, `fetch`, `chrome-devtools`, `playwright_mcp`, `context7`, `memory`, `git`, `code-index`, `github`.

All Git operations are protected by `"ask"` permissions — no automatic commits, pushes, or branch switches.

## Security

Hardened against **OWASP Agentic Top 10 2026**:
- Input sanitization on all shell parameters
- Skill firewall (`"*": "deny"` default)
- Isolated Python execution via `uv run`

## License

[MIT License](./LICENSE)
