# Shakwa Flutter — Local Developer Setup Guide

## 1. Prerequisites and Required Tools

* **Flutter SDK:** Version 3.32.x (compatible with Dart 3.8.x)
* **Dart SDK:** Version 3.8.x (bundled with Flutter)
* **Java Development Kit (JDK):** JDK 17 (recommended for Android Gradle Plugin 8.x)
* **Android SDK:**
  * Android SDK Build-Tools 34.0.0+ / 35.0.0
  * Android NDK (version 27.0.12077973 recommended by modern plugins)
  * Target SDK: Android 34 / 35
  * Minimum SDK: Android 21 (Android 5.0 Lollipop)
* **IDE / Editor:**
  * Visual Studio Code (with Flutter and Dart extensions), OR
  * Android Studio (with Flutter plugin)

---

## 2. Project Structure Overview

```
Frontend/
├── android/            # Android host project & Gradle configuration
│   └── app/src/main/   # AndroidManifest & Network Security Configuration
├── assets/             # Images, icons, and SVG illustrations
├── docs/
│   └── LOCAL_SETUP.md  # Developer setup guide
├── lib/
│   ├── app/            # App entry, router & dependency injection
│   ├── core/           # Core networking (Dio), theme, storage, and config
│   └── features/       # Feature modules (Citizen, Employee, SuperAdmin, Auth)
├── test/               # Unit, repository, and widget tests
├── pubspec.yaml        # Package dependencies declaration
└── pubspec.lock        # Locked dependency graph
```

---

## 3. Opening the Project and Restoring Packages

### In VS Code:
1. Open VS Code.
2. Select **File > Open Folder...** and choose `Frontend`.
3. Open a terminal (`Ctrl+\``) and fetch packages:
   ```powershell
   flutter pub get
   ```

### In Android Studio:
1. Open Android Studio.
2. Select **Open** and select the `Frontend` directory.
3. Android Studio will automatically prompt to run `flutter pub get`. Alternatively, click **Pub get** in the top action banner or run `flutter pub get` in the terminal.

---

## 4. API Base URL Configuration

The Shakwa Flutter client connects to the ASP.NET Core backend. Configuration is controlled through `AppConfig` via compile-time `--dart-define` parameters:

### A. Android Emulator (Default)
When debugging on an Android Emulator, the emulator loopback address `10.0.2.2` maps directly to `localhost` on the host PC:
```powershell
flutter run
```
*(Defaults automatically to `http://10.0.2.2:5000/api`)*.

### B. Physical Android Device (LAN Connection)
When testing on a physical phone:
1. Ensure your phone and development PC are connected to the same Wi-Fi / local network.
2. Find your PC's local IP address (`ipconfig` in PowerShell, e.g. `192.168.1.50`).
3. Launch with `--dart-define`:
```powershell
flutter run --dart-define=API_URL=http://192.168.1.50:5000/api
```
*(Or specify `--dart-define=LAN_IP=192.168.1.50`)*.

### C. Production / Staging Environment
Production builds require secure HTTPS endpoints:
```powershell
flutter build apk --release --dart-define=API_ENV=production --dart-define=API_URL=https://api.shakwa.sa/api
```
*Note: In production mode (`API_ENV=production`), `AppConfig` enforces HTTPS and rejects unencrypted HTTP URLs.*

---

## 5. Network Security & SSL Validation

* **Android Network Security:** Cleartext HTTP traffic is strictly disallowed globally in release builds by `network_security_config.xml`. Only local emulator/loopback addresses (`10.0.2.2`, `127.0.0.1`, `localhost`) have cleartext exceptions for local testing.
* **Release SSL Certificate Validation:** Standard system CA certificate verification is strictly enforced in release mode.

---

## 6. Running Tests and Building Release Artifacts

### Run Automated Tests:
```powershell
flutter test
```

### Build Internal Test Release APK:
```powershell
flutter build apk --release
```
The output APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`
