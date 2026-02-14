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
