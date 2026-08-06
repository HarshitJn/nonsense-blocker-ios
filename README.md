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

## ⚡ Quick Install on an iPhone (Friend's Device Guide)

Since the project is pre-configured with **XcodeGen**, your friend does **not** need to manually create targets, configure plists, or add capabilities. Everything is already set up!

### Step 1: Open the Project
1. Clone this repository to a Mac.
2. Open the folder and double-click **`NonsenseBlocker.xcodeproj`** (the file with the blue blueprint icon) to open it in Xcode.

### Step 2: Enable Developer Mode on the iPhone
1. On the iPhone, go to **Settings -> Privacy & Security**.
2. Scroll to the bottom, tap **Developer Mode**, toggle it **ON**, and follow the prompts to restart the phone.
3. Once restarted, unlock the phone and tap **Turn On** when prompted.

### Step 3: Connect the Phone & Sign the Targets
1. Connect the iPhone to the Mac using a USB cable.
2. If prompted on the iPhone, unlock it and tap **Trust This Computer**.
3. In Xcode's left sidebar, click the **blue project root file** `NonsenseBlocker` at the very top.
4. For **each** of the three targets (`NonsenseBlocker`, `NonsenseBlockerShield`, and `NonsenseBlockerAction`):
   * Select the target under the **Targets** list in the left panel.
   * Go to the **Signing & Capabilities** tab at the top.
   * Under the **Team** dropdown, select your Apple ID / Personal Team. *(If you haven't logged in, click "Add an Account..." and sign in with your free Apple ID).*
   * Xcode will automatically register your friend's iPhone and generate the provisioning profiles.

### Step 4: Build and Install
1. In Xcode's top toolbar, click the device selector (next to the Play/Run button) and select **your physical iPhone** under the **iOS Devices** list.
2. Click the **Play (Run)** button (or press `Cmd + R`).
3. Xcode will build the app and install it directly onto the phone.

### Step 5: Trust the Developer Certificate (First time only)
1. On the iPhone, try to open the newly installed **Nonsense Blocker** app. You'll see an "Untrusted Developer" warning.
2. Go to **Settings -> General -> VPN & Device Management**.
3. Under **Developer App**, tap your Apple ID email.
4. Tap **Trust [Your Email]** and confirm.

Now they can open the app, tap **Grant Access** to authorize Screen Time, select their apps to block, and turn the blocker **ON**!

