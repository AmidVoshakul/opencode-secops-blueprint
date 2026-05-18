# Strict Rust Engineering Rules
1. NEVER use `unsafe` code blocks unless explicitly justified and wrapped in a safe abstraction.
2. Prefer standard library concurrency primitives (Arc, Mutex, RwLock, Channels) over external sync crates.
3. Always handle errors explicitly: minimize the usage of `.unwrap()` and `.expect()`. Use the `?` operator.
