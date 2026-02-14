# Code Standards

Per-language conventions applied when writing code in these languages.

## Nix
- Use `lib.mk*` options for module options
- Treefmt/nixfmt for formatting
- No `with lib;` — use qualified names
- Secrets via sops-nix, never plaintext

## QML (Quickshell)
- Use shared singletons for theme/style/settings
- Proper anchoring and sizing, no binding loops
- Component naming conventions from the project

## Elixir
- Standard mix conventions, `@spec` and `@type` annotations
- Pattern matching over conditionals
- ExUnit tests alongside implementation

## Go
- Standard library first, justify external dependencies
- `go vet` and `staticcheck` clean
- Table-driven tests

## C
- `-Wall -Wextra -Werror` clean
- Check all return values, handle all error paths
- No memory leaks, clear ownership semantics

## Odin
- Follow official style conventions
- Use built-in allocators properly, defer for cleanup

## Haskell
- Prefer pure functions, isolate IO at the edges
- Use explicit type signatures on all top-level bindings
- `hlint` and `-Wall` clean
- Prefer `Text` over `String`

## Dart
- Follow official effective Dart style guide
- Strong typing — avoid `dynamic`, use proper generics
- `dart analyze` clean, no warnings

## Python
- Type hints on all function signatures
- `ruff` clean for linting and formatting
- Prefer dataclasses/attrs over raw dicts for structured data
- Virtual environments, never global installs
