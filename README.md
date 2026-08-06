# Nonsense Blocker - iOS Blocker App

Nonsense Blocker is a screen time app designed to break your doom-scrolling habits and reclaim your attention. 

Whenever you open a blocked app (like Instagram, Reddit, or LinkedIn), Nonsense Blocker intercepts the launch and overlays a native iOS Shield. You are roasted for wasting your time and must complete **25 moments of pause** (clicking through mindfulness and focus quotes) to unlock the app for a temporary 15-minute session.

---

## ⚡ How it Works (User Flow)
1. **Activate Blocker:** Open the app, grant Screen Time permissions, select the distracting apps you want to restrict, and toggle the Blocker ON.
2. **Blocked Screen:** Try to open any restricted app (e.g. Instagram). You will be blocked by our custom Shield screen.
3. **The 25-Quote Challenge:** Tap the **Next Quote** button 25 times to read and acknowledge the focus statements.
4. **Unlocked:** Once completed, the Shield automatically disappears, letting you into the app.
5. **Re-block:** After 15 minutes of usage, the app will automatically lock again.

---

## 🚀 Running on the iOS Simulator
If you do not have a physical iPhone connected, you can run the app immediately in the iOS Simulator:

1. Double-click **`NonsenseBlocker.xcodeproj`** to open the project in Xcode.
2. In the target bar at the top, select **`NonsenseBlocker`** and choose any virtual device (e.g., **iPhone 16**).
3. Click the **Run (Play)** button (or press `Cmd + R`).
4. Once the app launches in the Simulator, tap **Start Pause Practice** to test the 25-quote grid challenge directly!

---

## ⚡ Installing on a Physical iPhone (Quick Install)
To put this app onto your phone (or a friend's phone) using a Mac and Xcode:

### Step 1: Enable Developer Mode on the iPhone
1. On the iPhone, go to **Settings -> Privacy & Security**.
2. Scroll to the bottom and tap **Developer Mode**.
3. Toggle it **ON** and follow the prompts to restart the phone.
4. Once restarted, unlock the phone and tap **Turn On** when prompted.

### Step 2: Connect the Phone & Sign the Targets
1. Connect the iPhone to your Mac using a USB cable.
2. Unlock the iPhone and tap **Trust This Computer**.
3. In Xcode, click the **blue project root file** `NonsenseBlocker` at the very top of the left sidebar.
4. For **each** of the three targets (`NonsenseBlocker`, `NonsenseBlockerShield`, and `NonsenseBlockerAction`):
   * Select the target under the **Targets** list in the left panel.
   * Go to the **Signing & Capabilities** tab at the top.
   * Under the **Team** dropdown, select your Apple ID / Personal Team. *(If you haven't logged in, click "Add an Account..." and sign in with your free Apple ID).*
   * Xcode will automatically register the iPhone and generate local provisioning profiles.

### Step 3: Build and Install
1. In Xcode's top toolbar, click the device selector and select **your physical iPhone** under the **iOS Devices** list.
2. Click the **Play (Run)** button (or press `Cmd + R`).
3. Xcode will build and install the app directly onto the phone.

### Step 4: Trust the Developer Certificate (First time only)
1. On the iPhone, try to open the newly installed **Nonsense Blocker** app. You'll see an "Untrusted Developer" warning.
2. Go to **Settings -> General -> VPN & Device Management**.
3. Under **Developer App**, tap your Apple ID email.
4. Tap **Trust [Your Email]** and confirm.

Open the app, tap **Grant Access**, choose your apps, and reclaim your time!

---

## 🛠️ Troubleshooting Code Signing Issues
If you see the warning *"Your team has no devices from which to generate a provisioning profile"* during **Step 2**:
1. This is a restriction on free developer accounts: Apple requires at least one physical device connected to register the profile.
2. Simply connect your physical iPhone to the Mac via USB, select it in Xcode's device list, and click **Try Again** in the Signing tab. Xcode will register it and clear the warning!

---

## 📂 Developer Guide
For technical architecture, modular layout, state machine rules, and command-line test runner details, please refer to **[DEVELOPER.md](DEVELOPER.md)**.
