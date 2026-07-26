# Ventilation Advisor

Ventilation Advisor is a platform-independent Swift package that answers one
question: should the user open, keep open, close, or keep closed their windows,
and what indoor conditions are expected afterward?

The package contains only domain and scientific logic. Weather retrieval,
location, sensors, persistence, background work, and user interfaces belong to
the consuming application.

The package is currently being implemented against the normative
[technical specification](Documentation/TechnicalSpecification.md).
The work is split into reviewable, one-hour
[implementation stages](Documentation/ImplementationStages/README.md).

## Requirements

- Swift 6.3
- A 64-bit target
- No third-party package dependencies

## Build and test

```powershell
$swift = "$env:LOCALAPPDATA\Programs\Swift\Toolchains\6.3.3+Asserts\usr\bin\swift.exe"
& $swift build
& $swift test
```
