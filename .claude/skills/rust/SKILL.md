---
name: rust
description: Write, review, and refactor Rust code with a focus on correctness, clear APIs, simple ownership, and minimal complexity. Use when adding or changing Rust code, designing Rust APIs, reviewing dependencies, or simplifying a Rust crate.
---

# Rust code quality

Prefer correct, straightforward code over clever abstractions. Make invalid states hard to represent, keep ownership clear, and solve the current problem without building infrastructure for hypothetical needs.

## Understand the project first

- Read the relevant manifests, module roots, nearby implementations, and project instructions before editing.
- Identify existing types, error handling, runtime, timers, synchronization primitives, and file organization. Reuse established patterns when they fit.
- Inspect callers and public contracts before changing behavior or signatures. Preserve compatibility unless a breaking change is requested.
- Keep changes focused. Do not mix unrelated cleanup into a correctness fix.

## API design and correctness

- Prefer methods on the struct or enum that owns the behavior over free functions. Use associated functions for construction or operations that do not need an instance.
- Avoid free functions when an existing type provides a natural home. Do not invent empty utility structs merely to hold unrelated functions.
- Make arguments required when the operation needs them. Do not accept `Option<T>` only to immediately unwrap it or reject `None`.
- Use `Option<T>` for genuine absence and `Result<T, E>` for failure. Do not replace meaningful absence with sentinel values or fabricated defaults.
- Model mutually exclusive states with enums rather than combinations of booleans and optional fields. Add types only when they enforce a useful invariant or clarify the domain.
- Validate untrusted input at boundaries. Handle relevant empty input, invalid ranges, overflow, indexing, Unicode, and partial failures explicitly.
- Propagate recoverable errors with useful context. Do not silently discard errors or turn failures into success-shaped defaults.
- Avoid `unwrap()` and `expect()` in library and example code. Prefer explicit handling or encode the invariant in the type. Assertions are appropriate in tests.
- Keep panics out of normal input handling. Any unavoidable panic should reflect a genuine programming invariant, not a foreseeable user error.

## Ownership without unnecessary machinery

- Start with owned values and borrowing. Add `Rc`, `Arc`, `RefCell`, `Mutex`, `RwLock`, or similar APIs only when the actual ownership and concurrency requirements need them.
- Before adding shared state, identify who owns the value, who mutates it, and whether access crosses threads. Try a simpler ownership flow first.
- Do not wrap values in `Arc<Mutex<_>>` by habit. Reference counting provides shared ownership, not automatic thread safety for the contents.
- Keep lock and mutable-borrow scopes small. Avoid holding guards across `.await`, callbacks, or reentrant operations.
- Prefer borrowing and explicit lifetimes over cloning when they naturally express ownership and keep the API clear. Do not clone merely to avoid writing lifetime annotations.
- Use a clone or allocation when independent ownership is needed or borrowing would introduce disproportionate complexity. Do not force tangled lifetimes or shared mutable state just to avoid a cheap clone.
- Avoid `unsafe` unless a safe implementation cannot meet a demonstrated requirement. Keep unavoidable unsafe code narrow and document its safety obligations.

## Async and dependencies

- Do not immediately add Tokio or another runtime. Check whether the application already has an executor, scheduler, timer, task API, or suitable synchronous primitive.
- Prefer async I/O over unnecessary threads or blocking calls for HTTP fetching, network requests, and other I/O-bound work when the application supports it. Waiting on I/O is not CPU-intensive work and usually does not need a dedicated thread.
- Use the existing runtime's nonblocking APIs where available. Keep genuinely CPU-intensive work and unavoidable blocking APIs on an appropriate worker or blocking pool rather than running them directly on executor threads.
- Keep straightforward synchronous code when async offers no practical benefit. Do not introduce a new runtime merely to make an isolated operation async.
- Keep blocking work off async executor threads using the project's existing mechanism. Consider cancellation, task lifetime, shutdown, and bounded concurrency when spawning work.
- Check existing dependencies and standard-library APIs before adding a crate. Avoid duplicate capabilities and enable only needed features.
- Check that dependencies are actually used, including dev dependencies, build dependencies, target-specific dependencies, and feature-gated paths. Account for derive macros and build scripts before declaring a dependency unused.
- Use existing dependency-audit tooling when available. Do not install new tools or remove uncertain dependencies merely to satisfy a superficial scan.

## Simplicity and organization

- Use the simplest implementation that preserves correctness. Prefer clear control flow over dense iterator chains, unnecessary indirection, and clever generic machinery.
- Reuse suitable existing types. Avoid one-use traits, redundant wrappers, speculative extension points, and abstractions that hide a few straightforward operations.
- Use descriptive names such as `width`, `height`, and `destination`. Do not shorten names at the cost of clarity.
- Leave a blank line between method definitions and between implementation blocks. Separate distinct logical steps where it improves readability.
- For REST APIs and UI applications, split endpoints, components, and supporting behavior into cohesive files instead of growing a catch-all file. Do not fragment every tiny helper into its own module.
- Keep related behavior together and expose only the visibility callers actually need. Prefer `crate::` imports over `super::` imports.
- Verify every source file is reachable from a module root or a declared Cargo target under its intended configuration. A passing build does not validate orphaned `.rs` files.
- Remove obsolete code rather than leaving disconnected files or silencing warnings with broad `allow` attributes. Preserve intentional feature-gated and platform-specific code.

## Data layout and performance

- When designing or rewriting data-heavy code, ask whether data-oriented design would simplify processing and reduce work. Start from actual access patterns, data volume, and transformations rather than an object hierarchy.
- Prefer compact, contiguous storage and batch processing where they fit. Avoid unnecessary pointer chasing, repeated passes, and processing data that the operation does not need.
- Explicitly consider a structure of arrays instead of an array of structures when hot loops process only a subset of fields across many records. Keep an array of structures when records are usually accessed as a whole. Choose based on access patterns, not a blanket rule.
- When using a structure of arrays, keep column lengths and indices consistent through a clear owning API. Do not scatter synchronization of parallel collections across callers.
- Do not use arrays or vectors of booleans to represent indexed flags. Use a bitset instead, with an integer mask for a small fixed set or an appropriate existing bitset type for larger sets. Preserve logical length and handle unused trailing bits correctly.
- Improve execution before adding result caching. Remove unnecessary work and improve algorithms, data layout, and batching first. Add caching only when execution cannot reasonably be made fast enough or an external bottleneck such as network access or GPU work limits it.
- When caching is justified, define cache keys, invalidation, freshness, and memory bounds explicitly. Do not trade correctness for a faster stale result unless the contract permits it.
- Validate performance claims with relevant measurements when practical. Do not introduce complex layouts, custom low-level machinery, or caches based only on intuition.

## Tests and verification

- Inline unit tests and `#[cfg(test)]` modules in source files are fine. Put separate test files in the crate's `tests/` directory, never in `src/`.
- Never use `#[path]` or `include!` from `src/` to pull in tests from elsewhere.
- Exercise behavior through the public API in integration tests. Use inline unit tests for private behavior when needed rather than exposing implementation details solely to make them testable.
- When adding or changing tests, cover the changed behavior and relevant failure cases. Prefer deterministic tests over sleeps, live network access, or shared global state.
- After code changes, run a cheap compilation check for the affected package or target, usually `cargo check -p <package>`. Check relevant features or targets when the changed code is gated.
- Do not run tests unless you modified them or the user explicitly requests it. When running tests, prefer the individual integration target or affected package over the whole workspace.
- Check formatting with the project's formatter. Review the diff for accidental changes, debug output, unused dependencies, and disconnected files.
- Report what changed and which checks actually ran. State limitations without implying that uncompiled configurations or unrun tests passed.

## Comments and documentation

- Comment only where names and code do not convey important intent. Focus on a high-level explanation of why, with a little how only when necessary.
- Keep implementation comments to one line where possible, two only when needed. Avoid narrating obvious operations or recording the reasoning process behind an edit.
- Document public contracts when needed, including meaningful errors, panic conditions, and safety requirements. Keep required API documentation complete rather than forcing it into the implementation-comment limit.
- Do not justify code by referring to another implementation or repeating its rules. Keep each rule's source of truth in one place and document the local invariant instead.
- Do not leave historical explanations, debug logs, or speculative TODOs behind. Do not use em dashes or semicolons in comments or documentation.
