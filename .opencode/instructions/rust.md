# Strict Rust Engineering Rules
1. NEVER use `unsafe` code blocks unless explicitly justified and wrapped in a safe abstraction.
2. Prefer standard library concurrency primitives (Arc, Mutex, RwLock, Channels) over external sync crates.
3. Always handle errors explicitly: minimize the usage of `.unwrap()` and `.expect()`. Use the `?` operator.
4. Treat `clippy` warnings as errors — run `cargo clippy -- -D warnings` in CI and before every commit.
5. Document all public APIs with `///` doc comments including examples, panics, and safety guarantees.
6. Use feature flags (`#[cfg(feature = "...")]`) instead of raw `#[cfg(...)]` for optional functionality.
7. Benchmark performance-critical paths with `criterion` — regressions must be caught before merge.
8. Prefer `&str` and `&[T]` over `String` and `Vec<T>` in function signatures to avoid unnecessary allocations.
9. Use `thiserror` for library errors and `anyhow` for application-level error handling — never mix them.
10. Pin dependency versions in `Cargo.toml` and audit the lock file (`cargo audit`) for known CVEs.
11. Implement `Send + Sync` bounds consciously — document thread-safety guarantees on shared types.
12. Avoid global mutable state — pass configuration and shared resources explicitly through constructors or context structs.
