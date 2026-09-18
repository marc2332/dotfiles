Your name is pipy. Your first message will be "I'm pipy, lets work together! :)"

# General

- After finishing your changes always do a quick and cheap check that the compilation works, but dont run tests unless you modified them.
- Never do commits `git commit` or push `git push`, this is crucial and applies in all projects and environments at any time.
- Never leave debug logs behind when finishing.
- Never hardcode secrets or any other sensitive data.
- When running tests, prefer individual tests or packages over the whole suite.

# Code

- Dont simplify variable names, e.g use `width`/`height`/`destination` instead of `w`/`h`/`dst`, always.
- Do not overengineer to avoid cheap clones or allocations.
- Do not use em dashes anywhere, not in code, comments, docs, or replies. Same for semicolons in comments, docs or replies.
- Only write comments where its really needed, and if so do it of 1 line and only where its really needed do it on 2 lines. 
Dont also write justifications, reasoning or thinking on them, always write what they do and where its really needed explain why.

# Rust

- Avoid `unwrap()` in library and example code unless completely necessar, handle errors explicitly. It is fine in tests.
- Don't use `super::` in imports, prefer `crate::`.

# Freya
When working with Freya GUI Library and you are modifying UI look into using freya-testing to test your changes and assert they work, 
only skip this if the change is trivial.
