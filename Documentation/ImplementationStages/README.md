# Ventilation Advisor Implementation Stages

The package is implemented in eight bounded sessions. Each session is intended
to fit into approximately one hour with Codex assistance and ends at a clean,
independently reviewable checkpoint.

The [technical specification](../TechnicalSpecification.md) is normative. If a
stage document conflicts with it, update the stage document before writing code;
do not silently reinterpret the contract during implementation.

## Shared TDD workflow

Every coding session follows this sequence:

1. Confirm the previous session's `swift build` and `swift test` are green.
2. Write the smallest Swift Testing test for the next required behavior.
3. Run the test and confirm it fails because the behavior is missing.
4. Write only enough production code to make that test pass.
5. Run the focused test, then the complete test suite.
6. Refactor only while all tests remain green.
7. Run `swift build` and `swift test` and inspect `git diff --check`.
8. Commit only the current session's files.

On Windows:

```powershell
$swift = "$env:LOCALAPPDATA\Programs\Swift\Toolchains\6.3.3+Asserts\usr\bin\swift.exe"
& $swift build
& $swift test
```

## Sessions

1. **Package contract and repository intent** — completed in
   [`TechnicalSpecification.md`](../TechnicalSpecification.md).
2. [Package identity and public models](02-package-identity-and-public-models.md)
3. [Validation and psychrometrics](03-validation-and-psychrometrics.md)
4. [Range-based comfort scoring](04-range-based-comfort-scoring.md)
5. [Ventilation prediction](05-ventilation-prediction.md)
6. [Candidate generation and recommendation selection](06-candidate-selection.md)
7. [Fresh-air override and explanations](07-fresh-air-and-explanations.md)
8. [Advisor composition and golden tests](08-advisor-and-golden-tests.md)

## Session boundary rule

If a session reaches its time boundary before all acceptance criteria are green,
finish the current red-green cycle and stop. Do not start behavior assigned to a
later session. Record the remaining unchecked acceptance criteria on its GitHub
issue for the next working block.

