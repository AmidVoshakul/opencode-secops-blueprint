# OpenCode SecOps Blueprint

Enterprise-grade configuration framework designed to supercharge, discipline, and secure autonomous AI agents inside the **OpenCode** ecosystem.

This repository serves as a master template that injects an advanced multi-agent runtime pipeline, automatic capability discovery, and strict security guardrails into any software development workspace.

## Quick Start

1. **Clone the blueprint** into your project:
   ```bash
   git clone https://github.com/AmidVoshakul/opencode-secops-blueprint.git
   ```

2. **Merge infrastructure** into your target project:
   ```bash
   mkdir -p .opencode/commands .opencode/instructions .opencode/agents
   cp -r opencode-secops-blueprint/.opencode/commands/* .opencode/commands/
   cp -r opencode-secops-blueprint/.opencode/instructions/* .opencode/instructions/
   cp -r opencode-secops-blueprint/.opencode/agents/* .opencode/agents/
   cp opencode-secops-blueprint/.opencode/opencode.json .opencode/
   rm -rf opencode-secops-blueprint
   ```

3. **Set environment variables** before launching OpenCode:
   ```bash
   # Add to ~/.bashrc, ~/.zshrc, or your terminal profile
   export GITHUB_PERSONAL_ACCESS_TOKEN="your-github-pat-here"
   ```
   - Generate a PAT at GitHub Settings → Developer settings → Personal access tokens (classic)
   - Required scopes: `repo`, `read:org`, `workflow`
   - **Never hardcode this token in any file** — the blueprint uses `${GITHUB_PERSONAL_ACCESS_TOKEN}`

4. **Configure workspace parameters** in `.opencode/opencode.json`:
   - Set `--project-path` in the `code-index` MCP server to your project directory
   - Verify MCP servers: `opencode mcp list`

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
