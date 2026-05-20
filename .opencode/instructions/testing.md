# Testing & QA Standards
1. Maintain minimum 80% code coverage — new code must not reduce the overall coverage percentage.
2. Tests must be isolated and deterministic — no reliance on external services, real clocks, or random data without seeding.
3. Write integration tests for all external dependencies (databases, APIs, message queues) using mocks or test containers.
4. Apply fuzz testing (`cargo fuzz`, `afl`) to all parsers, deserializers, and user-input handlers.
5. Every bug fix must include a regression test that reproduces the original failure.
6. Use the Test Pyramid: 70% unit tests, 20% integration tests, 10% end-to-end tests.
7. Test names must describe the scenario and expected outcome: `test_login_fails_with_expired_token`.
8. Mock external services at the boundary — never mock internal business logic.
9. Run mutation testing (e.g., `cargo-mutants`) to verify that tests actually catch logical errors.
10. Performance tests must have defined baselines — alert on regressions exceeding 10% latency or throughput drop.
11. Property-based testing (`proptest`, `quickcheck`) for functions with well-defined mathematical or logical invariants.
12. All tests must pass in CI before merge — no `#[ignore]` or `skip` annotations in the main branch.
