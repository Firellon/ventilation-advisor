# AGENTS.md

This file provides guidance to AI agents working in this repository. It is the
root intent node for the Swift package, its tests, and its documentation.

## Repository Map

This repository contains a platform-independent ventilation-advisor library:

- `Documentation/` - normative specifications and implementation guidance
- `Sources/` - Swift package source organized by domain responsibility
- `Tests/` - Swift Testing suites organized by domain responsibility

## Architecture

Swift 6 strict concurrency is enforced project-wide. Public value types must be
safe to move across isolation boundaries. Tests use the Swift Testing framework.

The package contains only advisor, psychrometric, prediction, scoring, and
explanation logic. Platform services and UI belong to consuming applications.

## Global Guardrails

- Treat `Sources/`, `Tests/`, and the normative technical specification as the
  source of truth.
- Do not edit generated build output under `.build/`.
- Keep platform APIs, networking, persistence, sensors, permissions, and UI out
  of the package.
- Keep changes narrowly scoped and introduce production behavior with a failing
  test first.
- Use `Date` for instants and `Int` for duration values; supported execution
  targets are 64-bit.
- Write commit subjects in concise present simple with a Conventional Commits
  prefix, then a short description of why the change was made.

## Development Workflow

```powershell
swift build
swift test
```

## Intent Layer Maintenance

- Keep this file aligned with the actual repository.
- Update `Repository Map` when the top-level structure changes.
- Keep volatile type and version details in the technical specification rather
  than duplicating them here.
