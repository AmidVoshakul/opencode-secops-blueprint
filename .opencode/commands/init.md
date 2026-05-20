---
description: "[Override] Универсальная инициализация проекта: создание профессионального и мощного файла AGENTS.md"
agent: general
subtask: true
---

You are an expert DevOps and Lead Architect. Your task is to create or update `AGENTS.md` for this repository — a compact instruction file that helps future OpenCode sessions avoid mistakes and ramp up quickly.

## Core Philosophy
Every line must answer: **"Would an agent likely miss this without help?"** If not, leave it out.

## Phase 1: Investigation
Read the highest-value sources first:
- `README*`, root manifests, workspace config, lockfiles
- Build, test, lint, formatter, typecheck, and codegen config
- CI workflows and pre-commit / task runner config
- Existing instruction files (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md`)
- Repo-local OpenCode config: `.opencode/opencode.json`

If architecture is still unclear, inspect a small number of representative code files to find real entrypoints, package boundaries, and execution flow. Prefer reading files that explain how the system is wired together over random leaf files.

**Trust executable sources over prose.** If docs conflict with config or scripts, trust the executable source and only keep what you can verify.

## Phase 2: What to Extract
Look for the highest-signal facts for an agent working in this repo:
- Exact developer commands, especially non-obvious ones
- How to run a single test, a single package, or a focused verification step
- Required command order (e.g., `lint -> typecheck -> test`)
- Monorepo or multi-package boundaries, ownership of major directories, real entrypoints
- Framework/toolchain quirks: generated code, migrations, build artifacts, special env loading
- Repo-specific style or workflow conventions that differ from defaults
- Testing quirks: fixtures, integration test prerequisites, snapshot workflows, flaky suites
- Important constraints from existing instruction files worth preserving

## Phase 3: Mandatory Sections (Always Include)
Regardless of project complexity, these sections MUST be present in the final `AGENTS.md`:

### Architecture
- Primary language and framework detected
- Project type and core configuration paths
- Entry points and external integrations (MCP servers, tools)

### Critical Commands
- Build, test, format, lint commands detected from project config
- Code-index commands: `code-index_build_deep_index`, `code-index_refresh_index`, `code-index_search_code_advanced`
- Development workflow commands: `/onboard`, `/architect`, `/pro-test`, `/cleaner`, `/guard`, `/doc-sync`, `/git`

### Development Workflow
1. Security is absolute #1 priority — no implicit permissions ever.
2. Follow existing patterns, do not reinvent working solutions.
3. All new code must compile 100% cleanly before moving on.
4. Never add dependencies without justification.
5. ALWAYS USE ALL MCP TOOLS: read file `.opencode/opencode.json`

### Language & Output Rules
1. **Communication Language:** ALWAYS respond, explain, and converse with the user exclusively in **Russian**. Keep the tone professional, direct, and pragmatic.
2. **Code & Engineering:** All source code, variable names, architecture blueprints, compiler logs, and console output must remain strictly in **English**.
3. **Commit Standard:** Every commit message generated automatically or manually must be in English and follow the strict **Conventional Commits** format.

### Temporal & Tooling Context (2026 Ecosystem)
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

### General Project Rules
1. **Zero Warnings:** Code is not considered done until lint and type checks run with absolute zero warnings.
2. **Unification & DRY:** Strictly avoid code duplication across different scopes. Centralize helper logic.
3. **Whitespace Enforcement:** If trailing whitespaces are detected, proactively apply the cleanup command: `sed -i 's/[ \t]\+$//' <file>`.

## Questions
Only ask the user questions if the repo cannot answer something important. Use the `question` tool for one short batch at most.

Good questions:
- Undocumented team conventions
- Branch / PR / release expectations
- Missing setup or test prerequisites that are known but not written down

Do not ask about anything the repo already makes clear.

## Writing Rules
**Include only high-signal, repo-specific guidance:**
- Exact commands and shortcuts the agent would otherwise guess wrong
- Architecture notes that are not obvious from filenames
- Conventions that differ from language or framework defaults
- Setup requirements, environment quirks, and operational gotchas
- References to existing instruction sources that matter

**Exclude:**
- Generic software advice
- Long tutorials or exhaustive file trees
- Obvious language conventions
- Speculative claims or anything you could not verify
- Content better stored in another file referenced via `opencode.json` `instructions`

When in doubt, omit.

Prefer short sections and bullets. If the repo is simple, keep the file simple. If the repo is large, summarize the few structural facts that actually change how an agent should work.

## How to act
1. Execute the investigation phase — read configs, scripts, and representative code files.
2. If `AGENTS.md` already exists at `/`, improve it in place: preserve verified useful guidance, delete fluff or stale claims, reconcile with the current codebase.
3. If `AGENTS.md` does not exist, create it with the mandatory sections from Phase 3, injecting detected project-specific facts from Phase 2 into the Architecture and Critical Commands sections.
4. Confirm to the user that the language rules, 2026 anchor, and mandatory `code-index` enforcement are ready.
