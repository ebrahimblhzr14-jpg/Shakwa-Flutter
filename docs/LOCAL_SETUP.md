# Shakwa Flutter — Local Developer Setup Guide

## 1. Primary Development Tools & Prerequisites

* **Primary Editor:** Visual Studio Code (VS Code) with:
  * **Flutter** extension (by Dart Code)
  * **Dart** extension (by Dart Code)
* **Mobile Emulator:** Android Emulator (run from an existing Android SDK installation or managed via Android Studio's Virtual Device Manager).
* **Flutter SDK:** Version 3.32.x (bundled with Dart 3.8.x).
* **Android SDK:**
  * Android SDK Build-Tools 34.0.0+ / 35.0.0
  * Android NDK (version 27.0.12077973)
  * Android Platform API 34 or 35
  * Minimum Supported Android version: API 21 (Android 5.0 Lollipop)
* **Java Development Kit (JDK):** JDK 17 (recommended for Android Gradle Plugin 8.x).

---

## 2. Downloading the Repository

Anyone can obtain the Flutter source code directly from GitHub without an account:
1. Navigate to: `https://github.com/ebrahimblhzr14-jpg/Shakwa-Flutter`
2. Click the green **Code** button and select **Download ZIP**.
3. Extract the downloaded ZIP archive to a local folder (e.g., `C:\Projects\Shakwa-Flutter`).

Alternatively, clone via Git:
```powershell
git clone https://github.com/ebrahimblhzr14-jpg/Shakwa-Flutter.git
```

---

## 3. Project Structure

```
Shakwa-Flutter/
├── android/            # Android Gradle project & network security configuration
├── assets/             # Branding icons, images, and SVG illustrations
├── docs/
│   └── LOCAL_SETUP.md  # Developer setup guide
├── lib/
│   ├── app/            # Application entry (main.dart), routing, and theme
│   ├── core/           # Network client (Dio), error mappers, storage, and security
│   └── features/       # Clean Architecture features:
│       ├── authentication/ # Login, registration, JWT TokenManager
│       ├── complaints/     # Citizen complaint tracking, submission, comments
│       ├── admin/          # Employee complaint processing & assignment
│       └── super_admin/    # SuperAdmin analytics, user & department management
├── test/               # Unit, BLoC, repository, and widget tests (194 tests)
├── pubspec.yaml        # Package dependencies declaration
└── pubspec.lock        # Locked dependency versions
```

---

## 4. Opening in Visual Studio Code & Restoring Dependencies

1. Launch **Visual Studio Code**.
2. Select **File > Open Folder...** and choose the `Shakwa-Flutter` root directory.
3. Open an integrated terminal in VS Code (**Terminal > New Terminal** or press **Ctrl+\`**).
4. Restore Flutter package dependencies:
   ```powershell
   flutter pub get
   ```

---

## 5. Starting the Android Emulator & Running the App

### Step 1: Start the Android Emulator
* **From VS Code:** Click on the device selector in the bottom right corner of the VS Code status bar (or press **Ctrl+Shift+P** and type `Flutter: Select Device`), then select your installed Android Emulator to launch it.
* **From Command Line:**
  ```powershell
  flutter emulators --launch <emulator_id>
  ```
  *(Or launch an AVD directly via Android Studio's Virtual Device Manager).*

### Step 2: Configure the API Base URL for Android Emulator
The Shakwa client connects to the ASP.NET Core backend API. In Android emulators, `10.0.2.2` represents the host PC's `localhost`:
* **Default behavior:** Running `flutter run` automatically defaults to `http://10.0.2.2:5000/api`.
* **Explicit command:**
  ```powershell
  flutter run --dart-define=API_URL=http://10.0.2.2:5000/api
  ```

### Step 3: Run the Application
In VS Code, press **F5** (or open the **Run and Debug** view and click **Start Debugging**). Alternatively, execute:
```powershell
flutter run
```

---

## 6. Testing & Release Verification

### Run Automated Quality Tests:
In the integrated terminal:
```powershell
flutter test
```
*(All 194 tests will execute: unit, error mapping, upload, token concurrency, BLoC, and widget tests)*.

### Build Android Release APK:
```powershell
flutter build apk --release
```
The output APK will be placed at:
`build/app/outputs/flutter-apk/app-release.apk`
