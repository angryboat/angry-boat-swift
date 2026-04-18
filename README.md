# angry-boat-swift

A Swift package providing foundation utilities, SwiftData extensions, and SwiftUI components for iOS/macOS apps.

**Requirements:** iOS 26+, macOS 26+, Swift 6.2

---

## Libraries

### ABSFoundation

Core utilities and compile-time validation macros.

**Compile-time validated literals** — catch bad values at build time, not runtime:

```swift
import ABSFoundation

let id  = #UUID("550e8400-e29b-41d4-a716-446655440000")  // UUID, validated at compile time
let uid = #ULID("01ARZ3NDEKTSV4RRFFQ69G5FAV")            // ULID, validated at compile time
let url = #URL("https://example.com")                    // URL, validated at compile time
```

**ULID** — 128-bit sortable identifier, Crockford Base32 encoded. Conforms to `Comparable`, `Hashable`, `Codable`:

```swift
let id = ULID()                          // generate
let id = try ULID(string: "01ARZ3...")   // parse
```

**LocalizedEnum** — synthesizes a `localizedDescription` property from your strings catalog:

```swift
@LocalizedEnum(prefix: "MyEnum", separator: ".")
enum MyEnum {
    case active, suspended
}
// generates: var localizedDescription: String { ... }
```

**Other utilities:** `Keychain` (actor-based secure storage), `Debouncer` (`@Observable` rate limiter), `VersionNumber` (semantic version parsing/comparison), `PushController` (UserNotifications wrapper), web authentication session helpers.

---

### AngryBoatData

SwiftData extensions and validation.

**Type-safe queries** on any `PersistentModel` subclass:

```swift
let count = try await User.count(where: #Predicate { $0.isActive })
let users = try await User.fetch(where: #Predicate { $0.role == "admin" })
let exists = try await User.exists(where: #Predicate { $0.email == email })
let first  = try await User.first(sortBy: SortDescriptor(\.createdAt, order: .reverse))
```

**Validatable** — accumulating validation errors (no short-circuit):

```swift
struct User: Validatable {
    var email: String
    var age: Int

    func validates(context: inout ValidationContext<Self>) {
        if email.isEmpty { context.addError(message: "Email is required") }
        if age < 0      { context.addError(name: "age", actual: age, expected: 0) }
    }
}

try user.validate()  // throws ValidationError containing all errors
```

**SeedDataProvider** — populates a `ModelContainer` with test fixtures:

```swift
@SeedDataProvider
class UserSeeds {
    func generate() throws {
        create { User(name: "Alice") }
        create { User(name: "Bob") }
    }
}

// In tests:
try SeedData(UserSeeds.self, in: container)
```

**ModelContainer** convenience init with optional in-memory and CloudKit flags.

---

### AngryBoatUI

SwiftUI components.

**TaskButton** — async button with automatic loading state and error alert:

```swift
TaskButton {
    try await submitForm()
} label: {
    Text("Submit")
}
.workingLabel("Submitting…")
.shouldDisable(true)
.onError { error in
    // return nil to suppress the alert, or a modified error
    return error
}
```

Throw `TaskButtonAbort` to cancel silently without showing an error alert.

**Other views:** `QueryView` (SwiftUI data query wrapper), `ModelProviderView` (model data provider), `PushControllerStatusView` (notification permission status).

---

## Installation

Add via Swift Package Manager:

```swift
.package(url: "https://github.com/angryboat/angry-boat-swift", from: "…")
```

Then add the libraries you need to your target dependencies: `AngryBoatUI`, `AngryBoatData`, `ABSFoundation`.
