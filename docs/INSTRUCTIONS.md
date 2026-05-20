# Blueprint Usage Guide

This document explains how to effectively use the SecOps Blueprint commands and agents in your OpenCode workflow.

## Quick Start

1. Copy `.opencode/` from this blueprint into your project root
2. Configure `opencode.json`: set `--project-path` and `GITHUB_PERSONAL_ACCESS_TOKEN`
3. Run `/init` to generate `AGENTS.md` for your project
4. Start working with the commands below

## Commands

Commands are invoked with `/` in the OpenCode TUI. Each command runs as an isolated subtask, so it won't pollute your main conversation context.

### `/init` — Project Initialization
**When:** First time setting up a new project or after major structural changes.
**What:** Auto-detects your tech stack (language, framework, build tools) and generates a tailored `AGENTS.md` with project-specific commands, rules, and tool references.
**Agent:** `general`

### `/doctor-env` — Environment Audit
**When:** After updating OpenCode, changing MCP servers, or suspecting configuration drift.
**What:** Validates `opencode.json` syntax against latest documentation, checks instruction files integrity, verifies Git permission guards, and syncs skill whitelist.
**Agent:** `general`

### `/onboard` — Deep Project Reconnaissance
**When:** Starting work on an existing project, or after a major refactoring sprint.
**What:** Analyzes git history, syncs `.opencode/plans/` with actual code, scans for competitor flaws, detects architectural drift, and generates/updates `ARCHITECTURE.md`.
**Agent:** `general`

### `/architect` — Scaffold New Module
**When:** You need to add a new feature, service, or component.
**What:** Analyzes existing patterns and creates a complete directory tree with boilerplate files (models, interfaces, services, test stubs) matching your project conventions.
**Agent:** `general`

### `/pro-test` — Test Audit & Generation
**When:** After writing new code, before committing, or during QA cycles.
**What:** Runs mutation testing to detect "fake" tests, measures coverage gaps, and generates precise test blueprints for the primary agent to implement.
**Agent:** `test-engineer` (specialized — isolated context, focused on testing)

### `/cleaner` — Code Cleanup
**When:** Before committing, or periodically to maintain code hygiene.
**What:** Finds dead code, unused dependencies, trailing whitespaces, and debug leftovers. Proposes deletions and formatting fixes.
**Agent:** `general`

### `/doctor` — Debug Errors
**When:** A build fails, tests crash, or you hit a runtime error you can't solve.
**What:** Extracts error signatures, searches GitHub Issues/StackOverflow, finds workarounds, and proposes fixes (with your approval).
**Agent:** `general`

### `/doc-sync` — Documentation Sync
**When:** After structural changes, new APIs, or before a release.
**What:** Audits codebase vs documentation, updates `README.md`, `ARCHITECTURE.md`, and `CONTRIBUTING.md` to reflect current state.
**Agent:** `docs-writer` (specialized — isolated context, focused on documentation)

### `/git` — Safe Atomic Commit
**When:** You have changes ready to commit.
**What:** Runs formatter, executes tests, self-heals trivial errors, groups changes atomically, and creates a Conventional Commit message. All Git operations go through MCP (never raw bash).
**Agent:** `general`

### `/review` — Code Review
**When:** Before committing, or after a feature is complete.
**What:** Reads unstaged/staged diffs, analyzes changes against quality/security/performance checklist, and outputs structured feedback. Does NOT modify files.
**Agent:** `code-reviewer` (specialized — readonly, focused on review)

### `/guard` — Security Audit
**When:** Before a release, after adding user input handling, or periodically.
**What:** Scans for injection vulnerabilities, permission flaws, credential leaks, and OWASP Agentic Top 10 2026 violations. Outputs CVSS-scored vulnerability report.
**Agent:** `security-auditor` (specialized — readonly, focused on security)

### `/compare` — Competitor Benchmarking
**When:** Evaluating architecture decisions, or researching alternatives.
**What:** Compares your project against 1-3 competitor codebases (local paths or GitHub repos), extracts superior patterns, and generates `COMPARE.md`.
**Agent:** `explore` (readonly, focused on analysis)

### `/pr-master` — Create Pull Request
**When:** Feature is complete, tested, and committed locally.
**What:** Creates a feature branch, pushes to GitHub, and opens a professional PR with description, testing status, and linked issues.
**Agent:** `general`

## Sub-Agents

Agents are invoked with `@` in the OpenCode TUI. They run in isolated context windows, so their work doesn't pollute your main conversation.

| Agent | Mode | Write | Bash | Use Case |
|---|---|---|---|---|
| `@security-auditor` | subagent | ❌ | ✅ | Security audit, CVE scanning, OWASP compliance |
| `@docs-writer` | subagent | ✅ | ❌ | Write/update documentation, sync docs with code |
| `@test-engineer` | subagent | ✅ | ✅ | Write tests, run coverage, mutation testing |
| `@code-reviewer` | subagent | ❌ | ✅ | Review code, suggest improvements, check best practices |

### When to use agents directly vs commands

- **Use commands** (`/review`, `/guard`, `/pro-test`, `/doc-sync`) when you want a structured, repeatable workflow with predefined steps.
- **Use agents directly** (`@security-auditor check auth module`) when you need a quick, targeted analysis that doesn't fit a predefined command flow.

## Recommended Workflow

```
/init → /doctor-env → /onboard → [development cycle] → /pr-master

Development cycle (repeat):
  /architect → code → /review → /pro-test → /cleaner → /git
  (use @agent for ad-hoc tasks between commands)

Periodic:
  /guard (before releases)
  /doc-sync (after structural changes)
  /compare (when evaluating architecture)
  /doctor (when stuck on errors)
```

## Why Specialized Agents?

Commands like `/pro-test`, `/doc-sync`, `/guard`, and `/review` use specialized agents instead of `general` because:

1. **Isolated context** — Each agent works in its own window, not polluting your main conversation
2. **Focused instructions** — Agents load only relevant instruction files (testing.md, security.md, etc.)
3. **Limited tools** — Security auditor can't modify code; docs writer can't run bash commands
4. **Token efficiency** — Smaller context = faster and cheaper
5. **Higher quality** — Specialized prompts produce better results than generic ones
