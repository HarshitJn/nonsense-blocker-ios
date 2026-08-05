# Nonsense Blocker (iOS App & Core Engine)

This is the iOS version of the **Nonsense Blocker** concept, rewritten from the ground up to utilize iOS Screen Time APIs (`FamilyControls` & `ManagedSettings`) and modern SwiftUI.

## How it Works (iOS Native)
1. **App Selection:** The user opens Nonsense Blocker and selects which distracting apps/categories to block using the native iOS `FamilyActivityPicker`.
2. **Dynamic Blocker:** When any blocked app is launched, the iOS system intercepts the launch and overlays a custom Shield.
3. **The 25-Quote Pause:** The user must read and tap **25 quotes** directly on the Shield screen. Each tap of the primary button displays a new random focus/mindfulness quote and increments the click counter.
4. **Auto-Unblock:** Once the 25th quote is reached, the Shield Action Extension removes the app from the shield list, allowing the user to open and use it.
5. **Auto-Reblock:** The app remains unblocked for a default duration of 15 minutes, after which it automatically blocks again.

---

## Directory Structure

```
├── Package.swift                             # SPM Manifest for macOS CLI compilation & tests
├── Sources/
│   ├── NonsenseBlockerCore/                  # Pure Swift business logic (Core Engine)
│   │   ├── KeyValueStore.swift              # Local storage interface abstraction
│   │   ├── QuotesDatabase.swift             # 210 quotes, emojis, and app roasts matching
│   │   └── BlockSessionManager.swift        # 25-click state machine & unblock timer logic
│   └── NonsenseBlockerTestRunner/            # Command Line Test Runner (no IDE dependencies)
│       └── main.swift                        # Test suites using standard assertions
└── iOSApp/                                   # iOS-Specific targets (Xcode Integration)
    ├── BlockManager.swift                    # Interface with ManagedSettings API
    ├── ContentView.swift                     # SwiftUI Main UI & Blocker Simulator
    ├── ShieldConfigurationExtension.swift     # Customizes the Shield UI text/colors
    └── ShieldActionExtension.swift           # Intercepts Shield button clicks
```

---

## Running the Unit Tests (CLI Mode)

Since the core engine is decoupled from iOS-specific SDKs, you can compile and run the comprehensive test suite directly on macOS using the Swift Package Manager CLI:

```bash
swift run NonsenseBlockerTestRunner
```

This compiles the `NonsenseBlockerCore` module and runs the test runner checking:
* Quotes database loading.
* App-specific roast matching (Instagram, Reddit, LinkedIn, Pinterest, TradingView).
* The 25-click challenge state transitions.
* Challenge quote rotations.
* Unblock session durations and expiry.

---

## Xcode Setup & iOS Deployment

To compile the production iOS App, open Xcode and follow these steps:

### 1. Create Xcode Project
1. Open Xcode and create a new project: **iOS Application -> SwiftUI**. Name it `NonsenseBlocker`.
2. Right-click the project navigation sidebar and select **New Target...**.
3. Choose **Shield Configuration Extension** and name it `NonsenseBlockerShield`.
4. Choose **Shield Action Extension** and name it `NonsenseBlockerAction`.

### 2. Add Sources
* Add the files inside `iOSApp/` to your project and assign them to the correct targets:
  * `BlockManager.swift` and `ContentView.swift` -> **Main App Target**
  * `ShieldConfigurationExtension.swift` -> **Shield Configuration Target**
  * `ShieldActionExtension.swift` -> **Shield Action Target**
* Add `Sources/NonsenseBlockerCore/` as a local dependency package, or drag-and-drop the files directly into the project workspace making sure they are checked under **Target Membership** for all three targets.

### 3. Add App Groups Capability
To allow the main app and extensions to share the click counter and session timer state:
1. Select the **NonsenseBlocker** project file in Xcode.
2. Select the **NonsenseBlocker** target, go to **Signing & Capabilities**, click **+ Capability**, and add **App Groups**.
3. Create a group named `group.com.harshitjn.nonsenseblocker`.
4. Add the exact same capability and group name to both **NonsenseBlockerShield** and **NonsenseBlockerAction** targets.

### 4. Entitlements
* **On Simulator:** The app will run immediately! Simulators approve Screen Time authorization by default.
* **On Physical Device:** Request the **Family Controls** entitlement from Apple via your developer account dashboard, and enable it in the target's provisioning profile.
