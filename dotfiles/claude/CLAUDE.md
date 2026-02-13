# Global Instructions

## User
- **Name**: Elyria (SylvaraTheDev)
- **Git**: SylvaraTheDev <wing@elyria.dev>
- **Timezone**: UTC+10
- **Languages**: Nix, QML, Elixir, Go, C, Odin, Haskell, Dart, Python

## Preferences
- Minimal complexity — the right amount is the minimum needed
- Working code over perfect code
- Respect existing patterns — read before writing
- No over-engineering, no speculative abstractions
- Ship complete implementations, never stubs or TODOs

## Team Architecture: Orchestrator-Worker

Custom agents are available: **architect**, **engineer**, **reviewer**, **researcher**.

Use them via the Task tool when task complexity warrants it:
- **One-liner/trivial**: Do it directly, no agents
- **Bug fix / small change**: 1 engineer
- **New module / feature**: architect + engineer(s) + reviewer
- **Refactor / cross-cutting**: architect + engineers + reviewer
- **New project / large feature**: researcher + architect + engineers + reviewer

Communication rules:
1. All coordination flows through the lead (hub-and-spoke)
2. Each agent gets a concrete objective, clear boundaries, and output format
3. Review is mandatory before merging to shared branches

## Failure Prevention
- Write clear specifications before implementation (prevents spec ambiguity)
- Ask for clarification rather than assume (prevents wrong assumptions)
- Commit working increments with descriptive messages (prevents context loss)
- Review catches reasoning-action mismatches (the most common agent failure at 13.2%)
- Verify completeness before marking done (prevents premature termination)

## Code Standards

### Nix
- Use `lib.mk*` options for module options
- Treefmt/nixfmt for formatting
- No `with lib;` — use qualified names
- Secrets via sops-nix, never plaintext

### QML (Quickshell)
- Use shared singletons for theme/style/settings
- Proper anchoring and sizing, no binding loops
- Component naming conventions from the project

### Elixir
- Standard mix conventions, `@spec` and `@type` annotations
- Pattern matching over conditionals
- ExUnit tests alongside implementation

### Go
- Standard library first, justify external dependencies
- `go vet` and `staticcheck` clean
- Table-driven tests

### C
- `-Wall -Wextra -Werror` clean
- Check all return values, handle all error paths
- No memory leaks, clear ownership semantics

### Odin
- Follow official style conventions
- Use built-in allocators properly, defer for cleanup

### Haskell
- Prefer pure functions, isolate IO at the edges
- Use explicit type signatures on all top-level bindings
- `hlint` and `-Wall` clean
- Prefer `Text` over `String`

### Dart
- Follow official effective Dart style guide
- Strong typing — avoid `dynamic`, use proper generics
- `dart analyze` clean, no warnings

### Python
- Type hints on all function signatures
- `ruff` clean for linting and formatting
- Prefer dataclasses/attrs over raw dicts for structured data
- Virtual environments, never global installs
