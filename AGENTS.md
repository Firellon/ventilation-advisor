# AGENTS.md

This file provides guidance to AI agents working in this repository. It is the root intent node for the framework, generated artifacts, and planning docs.

## Repository Map

This repository is a Swift Pacakage framework for broadcasting captured content:

- `Sources/` - Source organized by feature and framework layer
- `Tests/` - Tests organized by feature and framework layer
- `.agents/skills/` - Agent skills for swift-concurrency, swift-testing, and swiftui

## Architecture

Swift 6 strict concurrency is enforced project-wide. Tests use the Swift Testing framework.

Formatting is handled by `swift-format` (configured in `.swift-format`).

## Global Guardrails

- Treat `Sources/` and `Tests/` as the source of truth. Do not edit generated outputs, derived Info.plists, or resources unless explicitly requested.
- Keep changes narrowly scoped. Do not mix architecture migration, and capture-pipeline refactors in one pass unless the user explicitly asks.
- See `.agents/skills/swift-concurrency/SKILL.md` for concurrency guidance.
- See `.agents/skills/swift-testing-expert/SKILL.md` for testing guidance.

## Development Workflow

`swift build`
`swift test`

## Intent Layer Maintenance

When updating this file, keep it aligned with the actual repository instead of turning it into generic policy text. Avoid referencing internal type names, specific modules, or version numbers that change more frequently than monthly.

- Update `Repository Map` when top-level directory structure changes.
- Update `Global Guardrails` when build tooling, concurrency rules, or source of truth boundaries change.
- If new subdirectories gain their own `AGENTS.md`, keep this root file focused on cross-cutting repo guidance and push local workflow details down into the nearest intent node.
