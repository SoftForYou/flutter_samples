# 🚀 Obsly Flutter Examples

<div align="center">
  
**Professional Flutter Examples by [Obsly.io](https://obsly.io)**

*Complete, production-ready Flutter applications showcasing advanced observability and monitoring*

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-1f425f.svg?logo=flutter)](https://flutter.dev/)
[![Powered by Obsly](https://img.shields.io/badge/Powered%20by-Obsly.io-6366f1.svg)](https://obsly.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

</div>

---

## 🎯 What You'll Find Here

This repository contains **enterprise-grade Flutter examples** that demonstrate real-world integration patterns with the [Obsly observability platform](https://obsly.io). Perfect for developers who want to see how professional monitoring and analytics work in practice.

> **Quick Start**: Clone, `flutter pub get`, `flutter run` - that's it! 🎉

## ⚡ Quick Start

### Prerequisites

- **Flutter** 3.4.0+ | **Dart** 3.0.0+
- **Mobile**: iOS 12.0+ / Android API 21+
- **Web**: Modern browser with WebAssembly support

### 🎮 Ready to Code?

```bash
# 1️⃣ Clone & Navigate
git clone https://github.com/SoftForYou/flutter_samples.git
cd flutter_samples

# 2️⃣ Pick Your Adventure
cd banking_app        # 🏦 Full-featured banking app
# OR
cd obsly_demo_app     # 🎯 Quick SDK demo

# 3️⃣ Launch & Enjoy
flutter pub get && flutter run
```

### 📱 What's Inside

| Example | Purpose | Developer Experience |
|---------|---------|---------------------|
| **🏦 Banking App** | Enterprise-grade monitoring | Complete integration patterns, PII filtering, debug tools |
| **🎯 Demo App** | SDK basics | Clean code, clear examples, learning-focused |

## 📱 Examples Overview

### Banking App - Advanced Integration

**Location**: [`banking_app/`](./banking_app/)

A comprehensive banking application that demonstrates enterprise-level integration of the Obsly SDK with:

- **🔐 Authentication Flow Monitoring** - Track login attempts, failures, and security events
- **💳 Transaction Tracking** - Monitor payment flows with PII filtering
- **🌐 HTTP Request Monitoring** - Automatic network call interception and analytics
- **🎯 UI Interaction Tracking** - Button clicks, navigation, and user behavior
- **📊 Performance Monitoring** - App launch times, screen render performance
- **🛡️ Crash Handling** - Automatic crash detection and reporting
- **🔍 Debug Tools** - Real-time event viewer and configuration interface
- **📱 Multi-Platform** - iOS, Android, and Web support

**Key Features Demonstrated**:

- PII data filtering and anonymization
- Custom event definitions and metadata
- Rule-based event processing
- Real-time debug interface
- HTTP interceptor configuration
- Error boundary implementation

### Demo App - Basic Integration

**Location**: [`obsly_demo_app/`](./obsly_demo_app/)

A clean, minimal example perfect for understanding core SDK concepts:

- **📝 Basic Event Tracking** - Simple user actions and app events
- **⚙️ Essential Configuration** - Minimal SDK setup and initialization
- **🔧 Core Features** - Event creation, metadata attachment
- **📖 Clear Documentation** - Well-commented code for learning

## 🛠️ Developer Integration Guide

### Step 1: Add Dependency

```yaml
dependencies:
  obsly_flutter: ^1.0.1  # Latest version
```

### Step 2: Get Your API Key

🔑 **Get your API key**: Contact us at [help@obsly.io](mailto:help@obsly.io) to get your API key and access

### Step 3: Initialize & Go

```dart
import 'package:obsly_flutter/obsly_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🚀 One-line initialization
  await ObslySDK.instance.init(InitParameters(
    obslyKey: 'your-api-key-here',
    instanceURL: 'https://api.obsly.io',
    debugMode: kDebugMode,
  ));

  runApp(MyApp());
}
```

### Step 4: Track Like a Pro

```dart
// 📊 Custom events
await Obsly.trackEvent('user_login', metadata: {
  'method': 'biometric',
  'success': true,
});

// 🐛 Error tracking
await Obsly.trackError(error, stackTrace: stackTrace);

// 🎯 Performance monitoring (automatic!)
// HTTP calls, UI interactions, crashes - all tracked automatically
```

> **Pro Tip**: Check out the banking app for real-world patterns and best practices! 🏦

## 📚 Developer Resources

### 🔍 Code Walkthrough - Banking App

| 🚀 Feature | 📝 What It Does | 💻 Code Location |
|-----------|----------------|------------------|
| **🔐 Auth Flow** | Login/logout tracking with security events | [`auth_service.dart`](./banking_app/lib/services/auth_service.dart) |
| **🌐 HTTP Monitor** | Automatic API call interception & analytics | [`api_service.dart`](./banking_app/lib/services/api_service.dart) |
| **👆 UI Tracking** | Button clicks, navigation, user interactions | [`widgets/`](./banking_app/lib/widgets/) |
| **🛡️ Error Handling** | Crash reporting and error boundaries | [`utils/error_handler.dart`](./banking_app/lib/utils/error_handler.dart) |
| **🔧 Debug Tools** | Real-time event viewer & SDK configuration | [`debug_screen.dart`](./banking_app/lib/screens/debug_screen.dart) |

### ⚙️ Configuration Recipes

#### 🚀 Basic Setup (Perfect for Getting Started)

```dart
ObslyConfig(
  enableCrashReporting: true,
  enableHttpInterception: true,
  enableUITracking: true,
  debugMode: kDebugMode,
)
```

#### 🛡️ Production-Ready with PII Protection

```dart
ObslyConfig(
  enableCrashReporting: true,
  enableHttpInterception: true,
  enableUITracking: true,
  debugMode: false,  // Production mode
  
  // 🔒 Automatic PII filtering
  piiFilters: [
    PIIFilter.email(),           // Filters email addresses
    PIIFilter.creditCard(),      // Filters credit card numbers
    PIIFilter.phone(),           // Filters phone numbers
    PIIFilter.custom(pattern: r'\b\d{3}-\d{2}-\d{4}\b'), // Custom: SSN
  ],
  
  // 🚫 Exclude sensitive endpoints
  httpExclusions: [
    '/api/auth/login',
    '/api/user/sensitive',
    RegExp(r'/api/payment/.*'),
  ],
)
```

## 🛠️ Advanced Developer Setup

### 🔥 Local SDK Development

Want to contribute to the Obsly SDK? Here's how to set up local development:

```bash
# 1️⃣ Clone the SDK
git clone https://github.com/SoftForYou/flutter_samples.git

# 2️⃣ Link locally in pubspec.yaml
dependencies:
  obsly_flutter:
    path: ../obsly_flutter  # Point to your local SDK

# 3️⃣ Hot reload magic ✨
flutter run --hot
```

### 🧪 Testing & Quality

```bash
# 🔍 Run all tests
flutter test

# 📊 Coverage report
flutter test --coverage
lcov --list coverage/lcov.info

# 🚀 Test on all platforms
flutter test -d chrome      # Web
flutter test -d macos       # macOS
flutter test -d ios         # iOS Simulator
```

## 🌐 Platform Support

| Platform    | Banking App | Demo App | Status        |
| ----------- | ----------- | -------- | ------------- |
| **iOS**     | ✅          | ✅       | Full support  |
| **Android** | ✅          | ✅       | Full support  |
| **Web**     | ✅          | ✅       | Full support  |
| **macOS**   | ⚠️          | ⚠️       | Basic support |
| **Windows** | ⚠️          | ⚠️       | Basic support |
| **Linux**   | ⚠️          | ⚠️       | Basic support |

## 📸 Screenshots

> **📷 Screenshots Coming Soon**: We're preparing screenshots of both example applications to showcase the Obsly Flutter library integration in action.

### Banking App Features Preview
- 🏠 **Dashboard Screen**: Complete banking interface with Obsly monitoring
- 🔧 **Debug Tools**: Real-time event viewer and SDK configuration interface
- 💳 **Transaction Flow**: End-to-end transaction monitoring with analytics
- 📊 **Performance Metrics**: Live performance data and monitoring tools

### Demo App Features Preview  
- 🛍️ **Product Catalog**: E-commerce interface with automatic event tracking
- 🛒 **Shopping Cart**: Complete shopping flow with Obsly integration
- 📱 **Navigation Tracking**: Automatic screen transition monitoring
- 🎯 **User Interactions**: Button clicks and gesture tracking demonstrations

**Screenshots to be added:**
- `screenshots/banking_app_home.png` - Banking app main dashboard
- `screenshots/banking_app_debug.png` - Debug tools interface
- `screenshots/banking_app_transactions.png` - Transaction flow
- `screenshots/demo_app_main.png` - Demo app home screen
- `screenshots/demo_app_cart.png` - Shopping cart interface
- `screenshots/demo_app_debug.png` - Event tracking in action

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Process

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Essential Links

| Resource | Description |
|----------|-------------|
| 🏠 **[Obsly.io](https://obsly.io)** | Main platform website |
| 📦 **[Flutter SDK](https://pub.dev/packages/obsly_flutter)** | Pub.dev package |
| 📚 **[Documentation](./doc/)** | Complete guides & tutorials |
| 🔧 **[API Reference](https://pub.dev/documentation/obsly_flutter/latest/)** | Detailed API docs |

## 🤝 Support & Community

| Channel | Purpose |
|---------|---------|
| 📧 **[help@obsly.io](mailto:help@obsly.io)** | Technical support |
| 🐛 **[GitHub Issues](https://github.com/SoftForYou/flutter_samples/issues)** | Bug reports & features |
| 📚 **[Documentation](./doc/)** | Complete guides & tutorials |

---

<div align="center">

**🚀 Made with ❤️ by the [Obsly.io](https://obsly.io) team**

*Empowering developers with world-class observability tools*

[![Obsly](https://img.shields.io/badge/Powered%20by-Obsly.io-6366f1.svg)](https://obsly.io)

</div>
