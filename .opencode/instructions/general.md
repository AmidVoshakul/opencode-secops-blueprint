# General Engineering Rules
1. Follow Conventional Commits format: `type(scope): description` (e.g., `feat(auth): add JWT validation`).
2. NEVER commit secrets, API keys, tokens, or credentials — use environment variables or secret managers.
3. All code changes must go through review — no direct pushes to protected branches (`main`, `master`, `production`).
4. Use Semantic Versioning (MAJOR.MINOR.PATCH) for all releases and breaking changes.
5. Keep functions focused: if a function exceeds 50 lines, consider splitting it.
6. Prefer composition over inheritance; favor interfaces/traits over concrete implementations.
7. Write self-documenting code: meaningful names over comments, comments explain "why" not "what".
8. Fail fast: validate inputs and preconditions at the earliest possible point.
9. Log with context: include correlation IDs, timestamps, and actionable error messages — never log sensitive data.
10. Design for observability: expose metrics, traces, and structured logs for every critical operation.
