# Shift Puzzle — Local Android QA APK Distribution Server

A temporary, self-contained local web server and QR generator designed to sideload the exact verified Shift Puzzle QA APK onto a physical Android device over local Wi-Fi without requiring ADB.

---

## 1. Purpose

This utility solves the physical Android testing requirement when USB debugging or ADB is unavailable. It serves the exact QA APK over the local network and generates a crisp, offline QR code that points directly to the APK download on your phone.

---

## 2. Verified APK Specification

- **Source Path**: `build/app/outputs/flutter-apk/app-release.apk`
- **Served Filename**: `shift-puzzle-qa.apk`
- **File Size**: 50.6 MB (`50,619,900` bytes)
- **SHA-256**: `2829b2ea9314c98d45fcd028697c5e257b8a22d7cc473598484808bcc1ac9a18`
- **Build Type**: Release build signed with Android Debug Key (`-PallowInsecureDebugSigning=true`)
- **Monetization**: Configured with official Google AdMob **TEST IDs**
- **Distribution Notice**: **QA / Sideload ONLY. Not for Google Play release.**

---

## 3. How to Start the Server

Run the launcher script from the repository root:

```bash
./qa-apk-server/start.sh
```

Or run directly with Python:

```bash
cd qa-apk-server && python3 server.py
```

### Server Output:
```
========================================
SHIFT PUZZLE — ANDROID QA SERVER
========================================

APK:
shift-puzzle-qa.apk

SHA-256:
2829b2ea9314c98d45fcd028697c5e257b8a22d7cc473598484808bcc1ac9a18

Local page:
http://localhost:8080/

Android phone:
http://<YOUR_LAN_IP>:8080/

Direct APK:
http://<YOUR_LAN_IP>:8080/shift-puzzle-qa.apk

QR:
Displayed on the local page.

IMPORTANT:
Both devices must be connected to the same Wi-Fi/LAN.
========================================
```

---

## 4. How to Stop the Server

Press `Ctrl + C` in the terminal where the server is running.

---

## 5. Network & Wi-Fi Requirement

- Both your development computer and your Android phone **must be connected to the same local Wi-Fi / LAN network**.
- Port `8080` must be accessible on your local network (ufw is inactive by default on this workstation).

---

## 6. Android Physical Installation Steps

1. Connect your Android phone to the same Wi-Fi network as your computer.
2. Open your camera or QR scanner app and scan the QR code displayed at `http://localhost:8080/` (or visit `http://<YOUR_LAN_IP>:8080/` directly in Chrome on your phone).
3. Tap the link to download `shift-puzzle-qa.apk`.
4. Once downloaded, tap the notification or open your **Files** / **Downloads** folder and tap `shift-puzzle-qa.apk`.
5. If Android prompts **"For your security, your phone is not allowed to install unknown apps from this source"**:
   - Tap **Settings**.
   - Toggle **Allow from this source** ON.
   - Tap back.
6. Tap **Install** (or **Update**).
7. Tap **Open** to launch Shift Puzzle.
8. Perform gameplay testing.
9. *(Optional)* After testing, you can disable the "Install unknown apps" permission for your browser.

---

## 7. How to Remove This Utility Afterward

When physical QA is complete, delete this directory entirely:

```bash
rm -rf qa-apk-server/
```
No files in the Flutter application (`lib/`, `android/`, `pubspec.yaml`, etc.) were created or modified.
