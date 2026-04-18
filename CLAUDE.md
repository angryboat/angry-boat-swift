# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
swift build          # build all targets
swift test           # run all tests
swift test --filter MyTestCase   # run a single test class or method
```

No linter is configured. CI runs on macOS 26 via `.github/workflows/swift.yml`.

## Platform Requirements

- macOS 26 / iOS 26 minimum
- Swift 6.2
- Swift 6 strict concurrency enabled

## Package Structure

Four targets with a clean dependency graph:

```
ABSMacro (compiler plugin)
    ↑
ABSFoundation ← AngryBoatData
                AngryBoatUI ← ABSFoundation
```

**ABSMacro** — Swift macro implementations (compiler plugin, depends on `swift-syntax`). Contains freestanding expression macros (`#UUID`, `#ULID`, `#URL`) that validate string literals at compile time, plus attached macros (`@LocalizedEnum`, `@SeedDataProvider`).

**ABSFoundation** — Core utilities: ULID type, keychain actor, OSLog wrapper, debouncer, semantic versioning, push notification controller, web auth session helpers. Macro declarations live here.

**AngryBoatData** — SwiftData layer: type-safe query extensions on `PersistentModel`, `Validatable` protocol with `ValidationContext` error aggregation, `SeedDataProvider` macro/protocol for test fixtures, `ModelContainer` convenience init with CloudKit support.

**AngryBoatUI** — SwiftUI components: `TaskButton` (async task with loading/error states), `QueryView`, `ModelProviderView`, `PushControllerStatusView`.

## Key Patterns

**Compile-time validation macros** — `#UUID("...")`, `#ULID("...")`, `#URL("...")` expand to force-unwrapped values if valid, or emit a compile error. Macro logic lives in `ABSMacro/`; declarations (the `macro` keyword) live in `ABSFoundation/ABSFoundation.swift`.

**ULID** — Full implementation in `ABSFoundation/ULID.swift`. 128-bit sortable ID, Crockford Base32 encoded (26 chars). First character must be ≤ `7` to avoid overflow. Conforms to `Comparable`, `Hashable`, `Codable`.

**Validatable** — `AngryBoatData/Validatable.swift`. Types conform to `Validatable` and call `context.add(error:)` inside `validate(context:)`. Validation errors accumulate rather than short-circuit.

**SeedDataProvider** — `@SeedDataProvider` macro synthesizes a `modelContainer` property and `SeedDataProvider` conformance. Used in tests to provide pre-populated in-memory SwiftData containers.

**SwiftData queries** — `AngryBoatData/PersistentModel.swift` adds `.count()`, `.fetch()`, `.exists()`, `.first()` static methods to `PersistentModel` subtypes. These accept `#Predicate` and `SortDescriptor` parameters.

**Concurrency** — `MainActor` isolation on UI types; `KeychainService` is an `actor`; `Debouncer` is `@Observable`. All types are `Sendable` where crossing actor boundaries.
