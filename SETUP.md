# 🚀 Developer Setup Guide

<div align="center">

**Professional Flutter Examples by [Obsly.io](https://obsly.io)**

*Get up and running in under 5 minutes*

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-1f425f.svg?logo=flutter)](https://flutter.dev/)
[![Powered by Obsly](https://img.shields.io/badge/Powered%20by-Obsly.io-6366f1.svg)](https://obsly.io)

</div>

---

## ⚡ Quick Start (TL;DR)

```bash
git clone https://github.com/SoftForYou/flutter_samples.git
cd flutter_samples/banking_app
flutter pub get && flutter run
```

*Need an API key? Get one free at [app.obsly.com](https://app.obsly.com) in 30 seconds!*

## 📋 Prerequisites

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| 🦋 **Flutter** | 3.4.0+ | `flutter --version` |
| 🎯 **Dart** | 3.0.0+ | `dart --version` |
| 🔧 **Git** | Latest | `git --version` |

> **One Command Check**: Run `flutter doctor` to verify everything is set up correctly!

### Platform-Specific Requirements

#### For iOS Development
- **Xcode**: 14.0 or higher
- **iOS Simulator** or physical iOS device (iOS 12.0+)
- **CocoaPods**: Usually installed with Xcode

#### For Android Development
- **Android Studio** or **Android SDK Tools**
- **Android Emulator** or physical Android device (API level 21+)

#### For Web Development
- **Chrome** or another modern web browser

## 🔧 Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/SoftForYou/flutter_samples.git
cd flutter_samples
```

### 2. Get Your Obsly API Key 🔑

**Get API Key**:
1. 📧 Contact [help@obsly.io](mailto:help@obsly.io) for access
2. ✅ Receive your API key and instance URL
3. 📋 Keep your credentials secure

> **Pro tip**: Keep this tab open - you'll need the key in the next step!

### 3. Configure API Keys

#### Option A: Direct Configuration (Quickest)

Replace the placeholder in each app's main.dart file:

**For Banking App:**
```bash
# Edit the file
code banking_app/lib/main.dart
# or
nano banking_app/lib/main.dart
```

Find this line:
```dart
obslyKey: 'YOUR_OBSLY_API_KEY_HERE',
```

Replace `'YOUR_OBSLY_API_KEY_HERE'` with your actual API key.

**For Demo App:**
```bash
# Edit the file
code obsly_demo_app/lib/main.dart
# or 
nano obsly_demo_app/lib/main.dart
```

Replace the same placeholder with your API key.

#### Option B: Environment Variables (Recommended for Production)

Create a `.env` file in each app directory:

**banking_app/.env:**
```
OBSLY_API_KEY=your_actual_api_key_here
```

**obsly_demo_app/.env:**
```
OBSLY_API_KEY=your_actual_api_key_here
```

Then modify the main.dart files to use environment variables:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  
  await ObslySDK.instance.init(
    InitParameters(
      obslyKey: dotenv.env['OBSLY_API_KEY'] ?? 'YOUR_OBSLY_API_KEY_HERE',
      // ... rest of configuration
    ),
  );
}
```

### 4. Install Dependencies

#### For Banking App:
```bash
cd banking_app
flutter pub get
```

#### For Demo App:
```bash
cd obsly_demo_app
flutter pub get
```

### 5. Verify Installation

Check that Flutter can detect your devices:
```bash
flutter devices
```

You should see available devices/simulators.

## 🚀 Running the Applications

### Banking App

```bash
cd banking_app

# For iOS Simulator
flutter run -d ios

# For Android Emulator
flutter run -d android

# For Web
flutter run -d web

# For a specific device
flutter run -d "device_id"
```

### Demo App

```bash
cd obsly_demo_app

# Same commands as above
flutter run -d ios      # iOS
flutter run -d android  # Android
flutter run -d web      # Web
```

## 🔍 Troubleshooting

### Common Issues

#### 1. "No devices found"
```bash
# Check connected devices
flutter devices

# For iOS Simulator
open -a Simulator

# For Android Emulator
flutter emulators --launch <emulator_id>
```

#### 2. "Obsly initialization failed"
- Verify your API key is correct
- Check your internet connection
- Ensure the Obsly service is accessible

#### 3. "Package not found" errors
```bash
# Clean and reinstall dependencies
flutter clean
flutter pub get

# For iOS, also update pods
cd ios && pod install && cd ..
```

#### 4. iOS Build Issues
```bash
# Update CocoaPods
cd ios
pod install --repo-update
cd ..
```

#### 5. Android Build Issues
```bash
# Clean build
flutter clean
flutter pub get

# Check Android SDK configuration
flutter doctor
```

### Debug Mode

Both apps run with debug mode enabled by default. You can:

1. **View Events**: Tap the debug button (bug icon) in the app
2. **Check Console**: Look for Obsly logs in your IDE console
3. **Monitor Network**: Use Flutter Inspector to see HTTP requests

### Performance Mode

To test performance monitoring:

```bash
# Build in profile mode
flutter run --profile

# Build in release mode (for production testing)
flutter run --release
```

## ⚙️ Configuration Options

### SDK Configuration

The apps demonstrate different configuration patterns:

#### Minimal Configuration (Demo App)
```dart
ObslyConfig(
  enableCrashReporting: true,
  enableUITracking: true,
  debugMode: true,
)
```

#### Production Configuration (Banking App)
```dart
ObslyConfig(
  enableCrashReporting: true,
  enableHttpInterception: true,
  enableUITracking: true,
  debugMode: kDebugMode,
  piiFilters: [
    PIIFilter.email(),
    PIIFilter.creditCard(),
    PIIFilter.accountNumber(),
  ],
  httpExclusions: [
    '/api/sensitive',
    RegExp(r'/api/user/\d+/private'),
  ],
  maxEventsPerSession: 1000,
  flushInterval: Duration(seconds: 30),
)
```

### Environment-Specific Settings

You can customize settings for different environments:

```dart
final config = ObslyConfig(
  enableCrashReporting: true,
  enableHttpInterception: !kDebugMode, // Only in production
  enableUITracking: true,
  debugMode: kDebugMode,
  instanceURL: kDebugMode 
    ? 'https://api.staging.obsly.io'
    : 'https://api.obsly.io',
);
```

## 🧪 Testing

### Unit Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/obsly_integration_test.dart
```

### Integration Tests
```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d android
```

### Manual Testing Checklist

- [ ] App launches without errors
- [ ] Obsly SDK initializes successfully
- [ ] Events are captured when interacting with UI
- [ ] Debug panel shows captured events
- [ ] Network requests are intercepted (Banking App)
- [ ] Crash handling works (force a test crash)

## 🔐 Security Considerations

### API Key Security

**✅ Do:**
- Use environment variables in production
- Add `.env` files to `.gitignore`
- Rotate API keys regularly
- Use different keys for development/production

**❌ Don't:**
- Commit API keys to version control
- Share API keys in plain text
- Use production keys in development

### PII Protection

The Banking App demonstrates PII filtering:
- Credit card numbers are automatically masked
- Email addresses are filtered in HTTP requests
- Account numbers are sanitized in events

## 📚 Next Steps

After successful setup:

1. **Explore the Apps**: Try all features to understand SDK capabilities
2. **Check Debug Tools**: Use the debug panels to see events in real-time
3. **Review Code**: Study the implementation patterns
4. **Integrate in Your App**: Apply learned patterns to your own project
5. **Read Documentation**: Check the comprehensive docs for advanced features

## 📞 Support

If you encounter issues:

1. **Check this guide** for common solutions
2. **Review the app logs** for specific error messages
3. **Visit the FAQ** in the main README
4. **Open an issue** on GitHub with:
   - Your Flutter/Dart version
   - Platform (iOS/Android/Web)
   - Complete error messages
   - Steps to reproduce

---

**Happy coding! 🚀**
