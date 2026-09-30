# Task 28 — Android 14 Crash Investigation & Fix Report

## 1. Device Status

- **Status**: **NO PHYSICAL DEVICE CONNECTED VIA ADB**
- **Manufacturer**: Unattached / Undetected
- **Model**: Unattached / Undetected
- **Android Version**: Unattached (Target: Android 14 / API 34)
- **API Level**: Unattached (Target: API 34)
- **ADB Discovery**:
  - `adb devices -l` returned: `List of devices attached` (empty)
  - `flutter devices` returned: `Linux (desktop)`, `Chrome (web)`
  - `lsusb` inspection: No external USB Android device connected on any bus.
  - mDNS inspection: `adb mdns services` found 0 services on local Wi-Fi.

Per **Phase 2** mandatory instructions:
> *"If no physical Android device is detected: STOP. Do NOT claim Android runtime validation. Do NOT fabricate results. Report exactly what is preventing the test."*

---

## 2. Original Failure Symptom

As reported by the user upon sideloading `build/app/outputs/flutter-apk/app-release.apk` (built with `-PallowInsecureDebugSigning=true`) on their real Android 14 smartphone:
1. The user installs the APK successfully.
2. The user taps the Shift Puzzle app icon on the home screen / app drawer.
3. The app starts and displays the splash window briefly.
4. The app immediately terminates/crashes to the home screen.

---

## 3. Automated Baseline Verification (Phase 1)

Before inspecting the startup path, the automated repository baseline was verified:
- **`flutter analyze`**: **0 issues found** (clean analysis).
- **`flutter test`**: **316 / 316 tests passed** (100% pass rate).
- **Authoritative Solver Audit**: All 150 campaign levels verified with exact solver parity (Level 150 = 9 moves).
- **Gameplay / Content Freeze**: Fully preserved across all 150 levels, 15 chapters, 84 Memory Echo levels, and par economy.

---

## 4. Static Startup Path Analysis & Suspects (Phases 5–10)

Because runtime logcat capture requires an active ADB connection (`adb logcat -c` followed by `adb shell am start`), speculative code modifications were not executed prior to capturing live evidence. However, a comprehensive static audit of the startup path revealed the following high-probability root-cause candidates for Android 14:

### A. Pre-`runApp()` Asynchronous Ad Loading & Unattached Context
In `lib/main.dart` (lines 17–22):
```dart
final adService = kIsWeb
    ? NoOpAdService()
    : AdMobAdService(connectivityService: connectivityService);
await adService.initialize();
```
Inside `AdMobAdService.initialize()`:
```dart
await MobileAds.instance.initialize();
_isInitialized = true;
_loadInterstitialAd();
_loadRewardedAd();
```
- In Flutter on Android, `MobileAds.initialize()` and `InterstitialAd.load()` / `RewardedAd.load()` communicate with the native Android Google Mobile Ads SDK over platform channels.
- When invoked in `main()` before `runApp()` has mounted the widget tree and attached the `FlutterActivity` view hierarchy, the underlying Android Activity reference in the Flutter engine plugin binding may be null or detached.
- On Android 14, calling ad load requests before the activity reaches `RESUMED` or has a valid window token frequently triggers a native null-pointer exception or channel timeout.
- Furthermore, `_loadRewardedAd()` is an `async void` fire-and-forget method that calls `checkPlatformConnectivity()` (`NetworkInterface.list()`). In Dart, uncaught exceptions in `async void` methods cannot be caught by callers and trigger an unhandled exception that terminates the Flutter engine.

### B. Over-Targeted Android SDK (`targetSdk = 36`)
In `android/app/build.gradle.kts` (lines 18 & 29):
```kotlin
compileSdk = 36
targetSdk = 36
```
- API 36 is Android 16 (Baklava), which is an unfinalized future developer preview.
- Running an APK targeting API 36 on an Android 14 (API 34) physical device causes the Android OS to enforce strict preview-level restrictions.
- Specifically, Android 14 enforces `RECEIVER_EXPORTED` / `RECEIVER_NOT_EXPORTED` on all dynamically registered broadcast receivers (such as those registered by Google Mobile Ads or Flutter plugins). If a third-party plugin registers a receiver without the explicit flag when `targetSdk >= 34`, Android 14 throws:
  `java.lang.SecurityException: com.shiftpuzzle.game: One of RECEIVER_EXPORTED or RECEIVER_NOT_EXPORTED should be specified`.
- Aligning `targetSdk` to 34 (Android 14) or 35 (Android 15) is standard industry practice.

### C. Release Optimization / R8 Keep Rules
In `android/app/proguard-rules.pro`:
- While `io.flutter.**` and `com.google.android.gms.ads.**` are preserved, native Flame, SharedPreferences, or Flutter embedding callbacks may experience reflection or class stripping if R8 aggressively optimizes classes accessed via JNI.
- A comparison between `flutter build apk --debug` and `flutter build apk --release` on the physical device is required to definitively isolate whether R8 minification is involved.

---

## 5. What Prevents Physical Execution

The physical test cannot be performed because **no Android device is currently accessible via ADB** on the workstation:
```bash
$ adb devices -l
List of devices attached
```
Workstation USB bus scan:
```bash
$ lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 8087:0a2b Intel Corp. Bluetooth wireless interface
Bus 001 Device 004: ID 05c8:0383 Cheng Uei Precision Industry Co., Ltd (Foxlink) HP HD Camera
Bus 001 Device 008: ID 138a:003f Validity Sensors, Inc. VFS495 Fingerprint Reader
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```
No external phone is physically plugged in.

---

## 6. Exact Steps to Enable Live Debugging & Fix Validation

To diagnose the exact crash via live logcat and validate the fix on your physical Android 14 device:

### Option 1: Connect via USB Cable (Recommended)
1. On your Android 14 phone, navigate to **Settings** > **About Phone**.
2. Tap **Build Number** 7 times to enable **Developer Options**.
3. Go to **Settings** > **System** > **Developer Options** and enable **USB Debugging**.
4. Connect the phone to this computer using a USB-C data cable.
5. On the phone screen, accept the prompt: **"Allow USB debugging from this computer?"** (check "Always allow").
6. Verify connection by running:
   ```bash
   adb devices -l
   ```

### Option 2: Connect via Wireless Debugging (Wi-Fi)
1. Ensure both the phone and this PC are connected to the same Wi-Fi network (`192.168.1.0/24`).
2. On the phone, go to **Settings** > **Developer Options** > **Wireless Debugging** (toggle ON).
3. Tap **Pair device with pairing code**. Note the IP address, port, and 6-digit code.
4. Run:
   ```bash
   adb pair <DEVICE_IP>:<PAIRING_PORT> <PAIRING_CODE>
   adb connect <DEVICE_IP>:<CONNECT_PORT>
   ```

### Once Connected, Execute Live Reproduction:
```bash
# Clear logcat
adb logcat -c

# Launch the app
adb shell am start -n com.shiftpuzzle.game/com.shiftpuzzle.shift_puzzle.MainActivity

# Capture native/Flutter crash stack trace
adb logcat -d -v threadtime | grep -E "FATAL EXCEPTION|AndroidRuntime|Flutter|libflutter|ShiftPuzzle|E/flutter|Exception|Error|Caused by|SIGSEGV|SIGABRT"
```

---

## 7. Remaining Blockers

1. **Hardware Connection**: Physical Android 14 device is not connected to the host via USB or Wireless ADB (`adb devices -l` is empty).
2. **Logcat Capture**: Live crash stack trace cannot be captured until ADB recognizes the device.

---

## 8. Final Status

**C. PHYSICAL DEVICE STILL BLOCKED**

*No physical phone detected by ADB or Flutter. Zero application code modified, no speculative changes applied. Ready to immediately capture logcat as soon as the device is connected.*

