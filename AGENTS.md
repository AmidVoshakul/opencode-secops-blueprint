# AGENTS.md - Automated Project System Environment

---

## Architecture
- **Primary Language**: Rust (detected via LSP configuration and cargofmt formatter)
- **Project Type**: Security Operations Blueprint (repository name: opencode-secops-blueprint)
- **Core Configuration**: 
  - .opencode/opencode.json - Main OpenCode configuration
  - .opencode/instructions/*.md - Domain-specific instructions (rust.md, security.md)
  - .opencode/commands/ - Custom slash commands (/onboard, /architect, /pro-test, etc.)
  - .opencode/plans/ - Strategic plans
  - .opencode/skills/ - Skill definitions
- **Entry Points**: 
  - OpenCode initialization via .opencode directory
  - Development workflow guided by instructions and commands
- **External Integrations**: 
  - GitHub MCP server configured
  - SearXNG for web search
  - Context7 for documentation
  - Sequential thinking for reasoning
  - Code-index for symbol navigation
  - Filesystem, fetch, chrome-devtools, playwright_mcp, memory

---

## Critical Commands
- **Code Index**: 
  - Build: `code-index_build_deep_index`
  - Refresh: `code-index_refresh_index`
  - Search: `code-index_search_code_advanced`
- **Development Workflow**:
  - Onboarding: `/onboard` command
  - Architecture: `/architect` command
  - Testing: `/pro-test` command
  - Cleaning: `/cleaner` command
  - Security: `/guard` command
  - Documentation: `/doc-sync` command
  - Git operations: `/git` command

---

## Development Workflow
1. Security is absolute #1 priority - no implicit permissions ever.
2. Follow existing patterns, do not reinvent working solutions.
3. All new code must compile 100% cleanly before moving on.
4. Never add dependencies without justification.
5. ALWAYS USE ALL MCP TOOLS: read file .opencode/opencode.json

---

## Language & Output Rules
1. **Communication Language:** ALWAYS respond, explain, and converse with the user exclusively in **Russian**. Keep the tone professional, direct, and pragmatic.
2. **Code & Engineering:** All source code, variable names, architecture blueprints, compiler logs, and console output must remain strictly in **English**.
3. **Commit Standard:** Every commit message generated automatically or manually must be in English and follow the strict **Conventional Commits** format specified in your commands.

---

## Temporal & Tooling Context (2026 Ecosystem)
1. **Current Year:** The current year is **2026**. Evaluate all dependencies, deprecated features, and external documentation fetched via `searxng` through this 2026 temporal anchor.
2. **Slash Commands Awareness:** You have custom professional routines available via `.opencode/commands/`. Prefer recommending or utilizing them for workflows:
   - Use **`/onboard`** for initial architecture mapping, plan syncing, and competitor flaw research.
   - Use **`/architect`** for scaffolding new files or modules.
   - Use **`/pro-test`** for mutation testing and pyramid QA audits.
   - Use **`/cleaner`** for removing dead code, unused imports, or trailing whitespaces.
   - Use **`/guard`** for adversarial security red-teaming and exploit analysis.
   - Use **`/doc-sync`** for maintaining `ARCHITECTURE.md` and `docs/`.
   - Use **`/git`** for committing changes through the MCP Git tool.
3. **Mandatory Deep Indexing:** You MUST proactively build and refresh the project index using `code-index_build_deep_index` at the beginning of any analytical task. Do NOT rely on surface text searches or basic file reading. Always trace symbol bodies, definitions, and dependencies exclusively through `code-index_search_code_advanced` to ensure your architectural reasoning is precise and completely up to date.

---

## General Project Rules
1. **Zero Warnings:** Code is not considered done until lint and type checks run with absolute zero warnings.
2. **Unification & DRY:** Strictly avoid code duplication across different scopes. Centralize helper logic.
3. **Whitespace Enforcement:** If trailing whitespaces are detected, proactively apply the cleanup command: `sed -i 's/[ \t]\+$//' <file>`.

