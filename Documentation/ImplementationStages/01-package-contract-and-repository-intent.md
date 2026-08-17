# Session 1: Package Contract and Repository Intent

**Status:** Completed
**Completed:** 2026-07-19
**Merged to `main`:** 2026-07-26 in pull request #1

## Historical purpose

Session 1 established the written contract for the package before any production
Swift implementation. It converted the earlier handoff and Luftung behavioral
reference into a Swift-specific normative specification, corrected the
repository intent, and divided future work into one-hour TDD stages.

## Delivered artifacts

- [`Documentation/TechnicalSpecification.md`](../TechnicalSpecification.md)
  defines package boundaries, public API shapes, Codable representation,
  validation, psychrometrics, comfort scoring, prediction, selection,
  fresh-air behavior, explanations, and golden tests.
- [`README.md`](../../README.md) explains the package purpose, requirements,
  build commands, and documentation entry points.
- [`AGENTS.md`](../../AGENTS.md) defines the repository architecture,
  guardrails, and test-first workflow.
- [`Documentation/ImplementationStages/`](README.md) contains the staged
  implementation sequence.

## Completed acceptance record

- [x] Defined a Swift 6.3 package named `VentilationAdvisor`.
- [x] Limited the package to platform-independent domain and scientific logic.
- [x] Required `Date` for instants and Swift `Int` for duration values on 64-bit
      targets.
- [x] Defined Codable public domain models and typed public errors.
- [x] Recorded Magnus formulas, configurable scoring bands, ACH prediction, and
      deterministic recommendation behavior.
- [x] Recorded explanation categories and end-to-end golden cases.
- [x] Corrected README and repository-agent guidance.
- [x] Introduced no production Swift behavior.

## Evidence

```text
01c82cd docs: define ventilation advisor package specification
138a78c docs: add staged TDD implementation guides
63fa9b4 Merge pull request #1 from Firellon/feature/project-structure
```

The generated Swift package remained unchanged during this session. Session 2
is the first stage allowed to modify `Package.swift`, `Sources/`, or `Tests/`.
