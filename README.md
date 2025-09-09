# Obsly Flutter Examples

This repository contains complete, working example applications that demonstrate how to integrate and use the Obsly observability library in Flutter applications. These examples showcase real-world integration patterns and best practices for implementing comprehensive app monitoring, event tracking, and user behavior analytics.

## 🚀 Quick Start

### Prerequisites

- Flutter 3.4.0 or higher
- Dart 3.0.0 or higher
- iOS 12.0+ / Android API 21+ for mobile builds
- Modern web browser for web builds
- Obsly library account (sign up at [obsly.io](https://obsly.io))

### Getting Started

1. **Clone this repository**

   ```bash
   git clone https://github.com/obsly/flutter_examples.git
   cd flutter_examples
   ```

2. **Choose an example to run**

   - [`banking_app/`](./banking_app/) - Complete banking application showcasing advanced Obsly integration
   - [`obsly_demo_app/`](./obsly_demo_app/) - Simple demonstration of core Obsly library features

3. **Run the example**
   ```bash
   cd banking_app  # or obsly_demo_app
   flutter pub get
   flutter run
   ```

## 📱 Examples Overview

### Banking App - Advanced Integration

**Location**: [`banking_app/`](./banking_app/)

A comprehensive banking application that demonstrates enterprise-level integration of the Obsly library with:

- **🔐 Authentication Flow Monitoring** - Track login attempts, failures, and security events
- **💳 Transaction Tracking** - Monitor payment flows with data filtering
- **🌐 HTTP Request Monitoring** - Automatic network call interception and analytics
- **🎯 UI Interaction Tracking** - Button clicks, navigation, and user behavior analytics
- **📊 Performance Monitoring** - App launch times, screen render performance, and metrics
- **🛡️ Crash Handling** - Automatic crash detection and error reporting
- **🔍 Debug Tools** - Real-time event viewer and configuration interface
- **📱 Multi-Platform** - iOS, Android, and Web support
- **📋 Rules Engine** - Dynamic rule-based event processing and alerts

**Key Features Demonstrated**:

- Event interception (UI, lifecycle, navigation, console, crash, HTTP)
- Custom event definitions and metadata
- Rules engine for dynamic event processing
- Real-time debug interface and monitoring
- HTTP request/response interception
- Performance metrics and analytics

### Demo App - Basic Integration

**Location**: [`obsly_demo_app/`](./obsly_demo_app/)

A clean, minimal example perfect for understanding core Obsly library concepts:

- **📝 Basic Event Tracking** - Simple user actions and app events
- **⚙️ Essential Configuration** - Minimal library setup and initialization
- **🔧 Core Features** - Event creation, metadata attachment, and basic monitoring
- **📖 Clear Documentation** - Well-commented code for learning

## 🛠️ Integration Guide

### 1. Add Dependency

Add the Obsly Flutter library to your `pubspec.yaml`:

```yaml
dependencies:
  obsly_flutter: ^0.2.0
```

### 2. Get Your API Key

Contact us at [help@obsly.io](mailto:help@obsly.io) to get your API key and access to the Obsly platform.

### 3. Initialize Library

```dart
import 'package:obsly_flutter/obsly_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Obsly library
  await ObslySDK.instance.init(
    InitParameters(
      obslyKey: 'YOUR_OBSLY_API_KEY_HERE', // Replace with your actual API key
      instanceURL: 'https://api.obsly.io',
      debugMode: kDebugMode,
      config: ObslyConfig(
        // Your configuration here
      ),
    ),
  );

  runApp(MyApp());
}
```

### 4. Track Events

```dart
// Track custom events
await Obsly.trackEvent(
  'user_action',
  metadata: {'button': 'login', 'screen': 'auth'},
);

// Track errors
await Obsly.trackError(
  error,
  stackTrace: stackTrace,
  category: 'authentication',
);
```

## 📖 Documentation

Complete documentation for the Obsly library is available in the [`doc/`](./doc/) folder.

### Banking App Features

| Feature             | Description                                | Code Example                                                                     |
| ------------------- | ------------------------------------------ | -------------------------------------------------------------------------------- |
| **Authentication**  | Login/logout tracking with security events | [`lib/services/auth_service.dart`](./banking_app/lib/services/auth_service.dart) |
| **HTTP Monitoring** | Automatic API call interception            | [`lib/services/api_service.dart`](./banking_app/lib/services/api_service.dart)   |
| **UI Tracking**     | Button clicks and navigation events        | [`lib/widgets/`](./banking_app/lib/widgets/)                                     |
| **Error Handling**  | Crash reporting and error boundaries       | [`lib/utils/error_handler.dart`](./banking_app/lib/utils/error_handler.dart)     |
| **Debug Tools**     | Real-time event viewer                     | [`lib/screens/debug_screen.dart`](./banking_app/lib/screens/debug_screen.dart)   |

### Configuration Examples

#### Basic Configuration

```dart
ObslyConfig(
  enableCrashReporting: true,
  enableHttpInterception: true,
  enableUITracking: true,
  debugMode: kDebugMode,
)
```

#### Advanced Configuration with PII Filtering

```dart
ObslyConfig(
  enableCrashReporting: true,
  enableHttpInterception: true,
  enableUITracking: true,
  debugMode: kDebugMode,
  piiFilters: [
    PIIFilter.email(),
    PIIFilter.creditCard(),
    PIIFilter.custom(pattern: r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
  ],
  httpExclusions: [
    '/api/sensitive',
    RegExp(r'/api/user/\d+/private'),
  ],
)
```

## 🔧 Development Setup

### Local Development

1. **Clone the main SDK repository** (for development)

   ```bash
   git clone https://github.com/your-username/obsly_flutter.git
   ```

2. **Use local SDK dependency** (in pubspec.yaml)

   ```yaml
   dependencies:
     obsly_flutter:
       path: ../obsly_flutter # Adjust path as needed
   ```

3. **Run with hot reload**
   ```bash
   flutter run --hot
   ```

### Testing

Both examples include comprehensive test suites:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
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

### Banking App

<img src="screenshots/banking_app_home.png" width="300" alt="Banking App Home">
<img src="screenshots/banking_app_debug.png" width="300" alt="Banking App Debug Tools">

### Demo App

<img src="screenshots/demo_app_main.png" width="300" alt="Demo App Main Screen">

## 📚 Library Features

The Obsly library provides comprehensive observability for Flutter applications:

### Event Interception
- **UI Events** - Automatic capture of user interactions (taps, gestures, form submissions)
- **Lifecycle Events** - App state changes, screen navigation, and user flows
- **Navigation Events** - Route changes and navigation patterns
- **Console Events** - Debug logs, warnings, and console output
- **Crash Events** - Unhandled exceptions and error reporting
- **HTTP Events** - Network requests, responses, and API interactions

### Rules Engine
- **Dynamic Rules** - Server-side rule configuration without app updates
- **Event Processing** - Real-time event filtering and transformation
- **Alerts & Notifications** - Automated alerting based on custom conditions
- **Business Logic** - Custom rules for business-specific event handling

### Performance & Analytics
- **Real-time Metrics** - Performance monitoring and KPI tracking
- **User Behavior Analytics** - Understanding user journey and patterns
- **Custom Events** - Track business-specific events and conversions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Obsly Flutter Library](https://pub.dev/packages/obsly_flutter)
- [Complete Documentation](./doc/)
- [API Reference](./doc/api-reference.md)
- [Integration Guide](./doc/integration-guide.md)

## 📞 Support

- 📧 Email: [help@obsly.io](mailto:help@obsly.io)
- 📖 Documentation: [Complete docs](./doc/)
- 🐛 Bug Reports: [GitHub Issues](https://github.com/obsly/flutter_examples/issues)

---

**Example applications for the Obsly observability library**
