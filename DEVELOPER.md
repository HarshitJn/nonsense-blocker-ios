# Developer & Architecture Guide - Nonsense Blocker

This document covers the technical architecture, codebase modularization, state machine mechanics, and CLI test design of the **Nonsense Blocker** iOS application.

---

## Codebase Architecture Overview

To support cross-platform unit testing (compiling and executing tests on macOS Terminal without requiring the full Xcode IDE or iOS SDKs), the codebase is split into a **platform-independent Core library** and a **platform-dependent iOS Application wrapper**.

```
                           +--------------------------------------+
                           |        NonsenseBlockerCore           |
                           |       (Pure Swift Library)           |
                           |                                      |
                           |  +--------------------+              |
                           |  |  QuotesDatabase    |              |
                           |  +--------------------+              |
                           |            ^                         |
                           |            |                         |
                           |  +--------------------+              |
                           |  |BlockSessionManager |              |
                           |  +--------------------+              |
                           |            |                         |
                           |            v                         |
                           |  +--------------------+              |
                           |  |   KeyValueStore    |              |
                           |  |    (Protocol)      |              |
                           |  +--------------------+              |
                           +--------------------------------------+
                                     ^            ^
                +--------------------+            +-------------------+
                |                                                     |
+--------------------------------+                  +--------------------------------+
|        iOS Application         |                  |        Shield Extensions       |
|     (SwiftUI/ManagedSettings)  |                  |    (ManagedSettingsUI / TUI)   |
|                                |                  |                                |
|  - BlockManager (Store bind)   |                  |  - ShieldConfigurationExtension|
|  - ContentView (Dashboard)     |                  |  - ShieldActionExtension       |
|  - UserDefaults App Group      |                  |  - UserDefaults App Group      |
+--------------------------------+                  +--------------------------------+
```

---

## 1. Core Engine Modules (`Sources/NonsenseBlockerCore`)

### KeyValueStore Protocol (`KeyValueStore.swift`)
An abstraction of key-value persistence.
* **Why it exists:** iOS App Extensions run in separate sandboxed processes and cannot share memory with the main app. They must communicate state asynchronously.
* **Interface:**
  ```swift
  public protocol KeyValueStore {
      func set(_ value: Any?, forKey defaultName: String)
      func string(forKey defaultName: String) -> String?
      func integer(forKey defaultName: String) -> Int
      func double(forKey defaultName: String) -> Double
      func bool(forKey defaultName: String) -> Bool
      func removeObject(forKey defaultName: String)
  }
  ```
* **Production Bind:** Extends standard `UserDefaults` to conform to `KeyValueStore`, allowing us to instantiate it with a shared container identifier: `UserDefaults(suiteName: "group.com.harshitjn.nonsenseblocker")`.
* **Testing Bind:** A lightweight, thread-safe `MockKeyValueStore` that holds values in-memory, eliminating plist disk-write and sandbox container requirements during CLI tests.

### Quotes & Roast Matcher (`QuotesDatabase.swift`)
* Holds the offline database of 210 curated quotes and focus slogans.
* Maps domain suffixes (e.g. `instagram.com`, `reddit.com`, `linkedin.com`) to custom `AppRoast` metadata containing icons, headers, and roasts.
* Provides a randomized picker that shuffles quotes and prepends custom emojis.

### The 25-Clicks State Machine (`BlockSessionManager.swift`)
Manages the challenge state transitions, click records, and session unblock limits.
* **Click Progression Flow:**
  1. Tapping the Primary Button on the Shield increments the count in the `KeyValueStore`.
  2. If the count is `< 25`, it randomizes a new quote, updates `NonsenseBlocker_CurrentQuote`, and returns `false` (blocking entry).
  3. On the **25th tap**, it resets the clicks to `0`, clears the active quote cache, sets `NonsenseBlocker_UnblockedUntil` to `Date() + 15 minutes` (900 seconds), and returns `true` (triggering unblock).
* **Session Expiry:** `isUnblocked(appIdentifier:)` evaluates if the current epoch timestamp is less than `NonsenseBlocker_UnblockedUntil`. Once expired, the app is re-shielded on its next launch.

---

## 2. Command Line Test Runner (`Sources/NonsenseBlockerTestRunner`)

Because macOS Command Line Tools do not distribute the `XCTest` framework (which is packaged exclusively inside the Xcode IDE bundle), standard `swift test` fails on machines without Xcode.

To bypass this dependency, we built a standalone **`NonsenseBlockerTestRunner`** executable target.
* **Implementation (`main.swift`):** Runs assertions using Swift's native `assert(_:_:file:line:)` and prints clear console logs.
* **Compiling & Running:**
  ```bash
  swift run NonsenseBlockerTestRunner
  ```
* **Test Coverage:**
  1. Shuffling logic & database load size (exactly 210 quotes).
  2. Subdomain roast matching rules.
  3. Initialization verification (starts locked).
  4. Challenge click counting, quote rotation, and unblocking thresholds.
  5. Session duration timer expiration.
  6. Manual lock/unlock commands.

---

## 3. Project Configuration & XcodeGen (`project.yml`)

We manage the Xcode Project structure via `XcodeGen` rather than tracking raw `project.pbxproj` XML files (which are prone to git merge conflicts).

`project.yml` defines four targets:
1. **`NonsenseBlocker`**: The main SwiftUI app target.
2. **`NonsenseBlockerShield`**: App Extension target for Shield Configuration.
3. **`NonsenseBlockerAction`**: App Extension target for Shield Action interception.
4. **`NonsenseBlockerCore`**: Static library compiled for iOS, carrying the core modules.

To regenerate the `.xcodeproj` files after modifying file trees or project dependencies, run:
```bash
xcodegen generate
```
