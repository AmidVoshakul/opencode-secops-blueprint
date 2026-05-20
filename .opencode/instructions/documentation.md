# Documentation Standards
1. Every public module, function, type, and trait must have a `///` doc comment describing purpose, parameters, and return values.
2. Maintain a `CHANGELOG.md` following Keep a Changelog format — auto-generated from Conventional Commits where possible.
3. Record Architecture Decision Records (ADRs) in `docs/adr/` for any significant design choice, including context, alternatives considered, and consequences.
4. Keep `README.md` as the project entry point: purpose, quick-start (3 steps), and links to deeper docs — no implementation details.
5. `ARCHITECTURE.md` must reflect the current directory structure, data flow, and component boundaries — update it on every structural change.
6. API documentation must include request/response schemas, authentication requirements, error codes, and example calls.
7. Inline comments explain "why", not "what" — code should be self-explanatory; comments justify non-obvious decisions.
8. Deprecate, don't delete: mark obsolete APIs with `#[deprecated]` (Rust) or equivalent, provide migration guides, and remove after 2 release cycles.
9. All configuration options must be documented in `docs/ENVIRONMENT.md` with defaults, required/optional status, and examples.
10. Run documentation link checks in CI — broken relative links in `.md` files must fail the build.
