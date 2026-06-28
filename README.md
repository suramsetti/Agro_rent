# Agro-Rent

A cross-platform **mobile app** for the agricultural sector. Agro-Rent helps farmers rent farm machinery, buy and sell supplies, hire drivers, and track equipment — all from a single Flutter application.

## Features

- **Machine rental** — Browse, search, filter, and book tractors, drones, and other farm equipment
- **Supplies marketplace** — Shop agricultural supplies with cart and order confirmation
- **Driver hiring** — Find drivers or register as a driver
- **Live tracking** — Location tracking with Google Maps
- **Bookings & profile** — Manage bookings, listings, receipts, and user settings
- **Government schemes** — Browse relevant agricultural schemes
- **Offline mode** — Local storage with Hive for use without a constant internet connection
- **Multi-language** — English, Hindi, Telugu, Tamil, Kannada, Malayalam, Bengali, Gujarati, and Marathi

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | [Flutter](https://flutter.dev) (Dart SDK ^3.8.1) |
| Backend | Firebase (Auth, Firestore, Storage) |
| Local storage | Hive |
| Maps | Google Maps Flutter |
| Platforms | Android, iOS, Web, Windows, Linux, macOS |

## Project Structure

```
lib/
├── models/       # Data models (user, machine, driver, order, product, etc.)
├── screens/      # UI screens (auth, home, rental, marketplace, tracking, profile)
├── services/     # Auth, Firestore, booking, cart, location, storage
├── widgets/      # Reusable UI components
├── l10n/         # Localization
└── main.dart     # App entry point
```

## Prerequisites

Before running the app, install:

1. [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. [Android Studio](https://developer.android.com/studio) (for Android) or [Xcode](https://developer.apple.com/xcode/) (for iOS on macOS)
3. A [Firebase](https://firebase.google.com/) project with Auth, Firestore, and Storage enabled
4. `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) placed in the correct platform folders

Verify your setup:

```bash
flutter doctor
```

## Run on a Physical Phone (USB)

This project is built for **mobile development**. You can run and test it on a real device by connecting your phone to your computer with a **USB cable**.

### Android (USB debugging)

1. On your Android phone, enable **Developer options** and turn on **USB debugging**
2. Connect the phone to your PC with a USB cable
3. Accept the **Allow USB debugging** prompt on the phone
4. Confirm the device is detected:

   ```bash
   flutter devices
   ```

5. Install dependencies and run the app:

   ```bash
   flutter pub get
   flutter run
   ```

   Flutter will build the app and launch it on the connected phone.

> **Tip:** If the device is not listed, install the [USB driver](https://developer.android.com/studio/run/oem-usb) for your phone manufacturer and ensure the cable supports data transfer (not charge-only).

### iOS (USB, macOS only)

1. Connect your iPhone or iPad with a USB cable
2. Trust the computer on the device when prompted
3. Open the project in Xcode once to configure signing (Team & Bundle ID)
4. Run from the terminal:

   ```bash
   flutter pub get
   flutter run
   ```

## Run on Emulator / Simulator

If you prefer not to use a physical device:

```bash
# Android emulator (start one from Android Studio first)
flutter run

# iOS simulator (macOS only)
flutter run
```

## Run on Web or Desktop

```bash
flutter run -d chrome    # Web
flutter run -d windows     # Windows
```

> Note: Some Firebase features may be limited on web unless Firebase is fully configured for web in `firebase_options.dart`.

## Configuration

- **App name:** `Agro-Rent` (see `lib/config/constants.dart`)
- **Google Maps:** Set your API keys in `lib/config/constants.dart` before using map/tracking features
- **Firebase:** Platform config files must match your Firebase project

## License

This project is for private/educational use. See repository settings for license details.
