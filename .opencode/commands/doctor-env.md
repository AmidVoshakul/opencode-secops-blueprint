---
description: Full environment audit: config validation, LSP check, Git permissions
agent: general
subtask: true
---

You are an Elite Systems Auditor and DevSecOps Architect. Your mission is to perform a rigorous compliance check on our OpenCode automation environment, cross-reference local config schemas with official online documentation, audit LSP server readiness, and dynamically generate a bulletproof `.opencode/opencode.json` block enforcing strict Git approval layers and up-to-date skill firewall mappings.

## 🛠️ MANDATORY TOOL-CHAIN PROTOCOLS:
1. **Temporal Anchor Fix:** Before checking logs or packages, you MUST call `time_get_current_time` to lock the active date (it is 2026). NEVER call the raw tool named 'time'.
2. **Deep Web Research Loop (SearXNG & Fetch):** To validate configuration syntax and LSP server setups, you MUST query `searxng_searxng_web_search` and use `fetch_fetch` or `webfetch` to read official documentation pages for opencode.json schemas, LSP server requirements, and latest 2026 updates.
3. **Deep System Reading:** Use filesystem tools to parse `.opencode/opencode.json`, `AGENTS.md`, and the files inside `.opencode/instructions/` and `.opencode/commands/`.

## Phase 1: CLI & Environment Check
1. **OpenCode Version:** Run `opencode --version` to check the active CLI version. Report the version and flag if it appears outdated.
2. **GitHub Token Check (SECURITY-CRITICAL):**

   **A. Check opencode.json for placeholder:**
   ```bash
   if grep -q '__GITHUB_TOKEN__' .opencode/opencode.json 2>/dev/null; then
     echo "opencode.json: Contains __GITHUB_TOKEN__ placeholder (correct)"
   elif grep -qE 'ghp_[A-Za-z0-9]{36}|github_pat_' .opencode/opencode.json 2>/dev/null; then
     echo "opencode.json: WARNING - Real token detected! Replace with __GITHUB_TOKEN__ placeholder"
   else
     echo "opencode.json: No token configuration found"
   fi
   ```

   **B. Validate token via GitHub API:**
   ```bash
   TOKEN=$(python3 -c "
import json
with open('.opencode/opencode.json') as f:
    config = json.load(f)
print(config.get('mcp', {}).get('github', {}).get('environment', {}).get('GITHUB_PERSONAL_ACCESS_TOKEN', ''))
" 2>/dev/null)

   if [ -n "$TOKEN" ] && [ "$TOKEN" != "__GITHUB_TOKEN__" ]; then
     HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $TOKEN" https://api.github.com/user)
     if [ "$HTTP_CODE" = "200" ]; then
       LOGIN=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user | python3 -c "import sys,json; print(json.load(sys.stdin)['login'])" 2>/dev/null)
       echo "GitHub API: Token valid (user: $LOGIN)"
     else
       echo "GitHub API: Token INVALID (HTTP $HTTP_CODE)"
     fi
   elif [ "$TOKEN" = "__GITHUB_TOKEN__" ]; then
     echo "GitHub API: Placeholder detected — run an installer to configure token"
   else
     echo "GitHub API: No token configured"
   fi
   ```
   - **NEVER** print, log, or display the actual token value.
   - If valid, report: "Token valid (user: <login>)"
   - If invalid, flag as **WARNING**: GitHub MCP will fail with "Bad credentials".
   - If placeholder, flag as **INFO**: Run installer or manually replace `__GITHUB_TOKEN__` in opencode.json.
3. **Code-Index Path Validation:** Read the `--project-path` value from `.opencode/opencode.json` under the `code-index` MCP server. Compare it with the current working directory (`pwd`). If they don't match, flag as **WARNING** and suggest the corrected JSON block.

## Phase 2: OpenCode Syntax Alignment & Web Verification
1. Launch the Deep Web Research Loop to gather the latest syntax requirements for `opencode.json` matching the detected version.
2. Cross-reference your local `.opencode/opencode.json` with the retrieved web documentation to identify structural anomalies or deprecated parameters.

## Phase 3: LSP Server Audit & Recommendations
1. **Detect Project Languages:** Scan the project directory for file extensions to identify the primary programming languages used (e.g., `.rs` → Rust, `.py` → Python, `.ts/.tsx` → TypeScript, `.dart` → Dart, `.go` → Go, `.java` → Java, `.cs` → C#, `.rb` → Ruby, etc.).
2. **Check Built-in LSP Availability:** For each detected language, verify the corresponding LSP server is available per the official OpenCode documentation (https://opencode.ai/docs/ru/lsp/):

   | Language | LSP Server | Requirement |
   |---|---|---|
   | Rust | `rust-analyzer` | `rust-analyzer` command available |
   | Python | `pyright` | `pyright` dependency installed |
   | TypeScript/JS | `typescript` | `typescript` dependency in project |
   | Dart | `dart` | `dart` command available |
   | Go | `gopls` | `go` command available |
   | C/C++ | `clangd` | Auto-installed for C/C++ projects |
   | Java | `jdtls` | Java SDK 21+ installed |
   | C# | `csharp` | .NET SDK installed |
   | Ruby | `ruby-lsp` | `ruby` and `gem` commands available |
   | PHP | `php intelephense` | Auto-installed for PHP projects |
   | Vue | `vue` | Auto-installed for Vue projects |
   | Svelte | `svelte` | Auto-installed for Svelte projects |
   | Astro | `astro` | Auto-installed for Astro projects |
   | Lua | `lua-ls` | Auto-installed for Lua projects |
   | Kotlin | `kotlin-ls` | Auto-installed for Kotlin projects |
   | Zig | `zls` | `zig` command available |
   | Swift | `sourcekit-lsp` | `swift` installed |
   | Terraform | `terraform` | Auto-installed from GitHub releases |

3. **Check LSP Configuration:** Read the `lsp` block in `.opencode/opencode.json`. If LSP servers are commented out (e.g., `// "lsp": { "rust": ... }`), flag as **INFO** and suggest uncommenting.
4. **Custom LSP Research:** For languages not in the built-in list, use `searxng_searxng_web_search` to find the latest LSP server recommendations for 2026.
5. **Generate LSP Configuration Block:** For each detected language with a missing or misconfigured LSP, generate a ready-to-copy `lsp` block for `opencode.json` with the correct command, extensions, and any required environment variables.

## Phase 4: Instruction & Prompt Integrity Matrix
1. **Validate `AGENTS.md`:** Ensure that vital runtime constraints are present: Language Rules (Russian for talk, English for code), 2026 Year Anchor, and Mandatory Deep Indexing instructions.
2. **Validate Instructions Directory:** Verify that all available instruction files matching `.opencode/instructions/*.md` are fully legible, integrated, and uncorrupted.

## Phase 5: Skill Firewall, Registry Sync & Mandatory Git Permissions
1. Check if the orchestrator registry exists, then read it:
   ```bash
   if [ -f ".opencode/skills/agent-orchestrator/data/registry.json" ]; then
     cat .opencode/skills/agent-orchestrator/data/registry.json
   else
     echo "registry.json not found, skipping skill sync"
   fi
   ```
   Extract the names of all physical skills discovered on disk.
2. **Skill Sync Check:** Read the `"permission.skill"` block inside your active `.opencode/opencode.json`. Detect any additions or deletions compared to the physical map, and isolate which skills should be whitelisted.
3. **Mandatory Git Protection Audit:** Inspect the main `"permission"` object of `.opencode/opencode.json`. You MUST explicitly verify that the following 8 operations are mapped strictly to the `"ask"` value:
   - `git_git_commit`, `git_git_add`, `git_git_push`, `git_git_merge`
   - `git_git_pull`, `git_git_create_branch`, `git_git_checkout`, `git_git_reset`
   If any of these keys are missing, set to `"allow"`, or misconfigured, flag it as a **CRITICAL COMPLIANCE VIOLATION**.

## How to act (Prescriptive Flow):
1. Execute `time_get_current_time` and notify the user that the Verified Configuration Compliance Audit has initiated.
2. Run `opencode --version`, check `GITHUB_PERSONAL_ACCESS_TOKEN` (without revealing its value), and validate `code-index` project path.
3. Execute the LSP server audit: detect languages, check built-in LSP readiness, research custom LSP options, and generate configuration recommendations.
4. Execute the multi-turn web search loop to read official open-code configuration guidelines.
5. Compare local JSON schemas and skill lists against the retrieved web data and registry maps.
6. **Generate the Actionable Hardening Checklist:** If there are any skill mismatches, missing Git permissions, or LSP misconfigurations, you MUST compile complete, copy-pasteable JSON blocks for each issue.
7. Output the comprehensive "Verified Automation Platform Compliance Report" divided strictly into:
   - **CLI & Environment Diagnostics:** OpenCode version, GitHub token status (presence only, never value), code-index path validation.
   - **LSP Server Audit:** Detected languages, LSP availability status, and ready-to-copy `lsp` configuration blocks for `opencode.json`.
   - **CLI Tooling & Schema Diagnostics:** Version status and schema validation of `opencode.json` verified against live web documentation.
   - **Instruction Prompt Integrity:** Verification score of `AGENTS.md` and active `.opencode/instructions/*.md` files.
   - **Skill Firewall & Git Mapping Intelligence:** Discrepancy report matching the physical assets against `opencode.json`, explicitly flagging missing or corrupted Git `"ask"` parameters.
   - **Actionable Hardening Checklist:** Complete ready-to-copy corrected JSON configuration blocks for easy synchronization.
