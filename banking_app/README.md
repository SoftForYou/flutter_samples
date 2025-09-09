# Banking App - Obsly Flutter SDK Demo

A comprehensive banking application demonstrating enterprise-level integration of the Obsly Flutter SDK. This example showcases advanced monitoring, analytics, and debugging capabilities in a realistic banking context.

## 🎯 Features Demonstrated

### Core Banking Features

- 🔐 **Secure Authentication** - Login/logout with biometric support
- 💰 **Account Management** - View balances, transaction history
- 💳 **Money Transfers** - Send money between accounts
- 📊 **Financial Analytics** - Spending analysis and budgeting
- 🎯 **Investment Tracking** - Portfolio management and market data

### Obsly SDK Integration

- 📱 **UI Interaction Tracking** - Every button click, screen view, and user action
- 🌐 **HTTP Request Monitoring** - Automatic API call interception and analytics
- 🛡️ **Crash Reporting** - Comprehensive error tracking and stack traces
- 🔍 **Performance Monitoring** - App launch times, screen render performance
- 🎨 **Debug Tools** - Real-time event viewer and SDK configuration interface
- 🔒 **PII Protection** - Automatic filtering of sensitive data

## 🚀 Quick Start

1. **Install dependencies**

   ```bash
   flutter pub get
   ```

2. **Run the app**

   ```bash
   flutter run
   ```

3. **Explore features**
   - Login with demo credentials
   - Navigate through banking features
   - Open debug panel (floating action button)
   - Monitor events in real-time
   - **🚨 IMPORTANTE**: Pulsa el botón azul "Send" (📤) en Obsly Tools para enviar eventos a la plataforma

## 📱 App Architecture

```
lib/
├── main.dart                 # App entry point and Obsly initialization
├── screens/                  # UI screens with integrated tracking
│   ├── login_screen.dart     # Authentication with event tracking
│   ├── home_screen.dart      # Dashboard with performance monitoring
│   ├── transfer_screen.dart  # Transaction tracking
│   └── debug_screen.dart     # Obsly debug interface
├── services/                 # Business logic with monitoring
│   ├── auth_service.dart     # Authentication events
│   ├── api_service.dart      # HTTP interception setup
│   └── banking_service.dart  # Financial transaction tracking
├── widgets/                  # Reusable UI components
│   ├── tracked_button.dart   # Button with automatic click tracking
│   └── error_boundary.dart   # Error handling widget
└── utils/
    ├── obsly_config.dart     # SDK configuration
    └── error_handler.dart    # Global error handling
```

## 🔧 SDK Configuration

### Basic Setup

```dart
await Obsly.initialize(
  config: ObslyConfig(
    enableCrashReporting: true,
    enableHttpInterception: true,
    enableUITracking: true,
    debugMode: kDebugMode,
  ),
);
```

### Advanced Configuration

```dart
await Obsly.initialize(
  config: ObslyConfig(
    enableCrashReporting: true,
    enableHttpInterception: true,
    enableUITracking: true,
    debugMode: kDebugMode,

    // PII Protection
    piiFilters: [
      PIIFilter.email(),
      PIIFilter.creditCard(),
      PIIFilter.accountNumber(),
      PIIFilter.custom(pattern: r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
    ],

    // HTTP Monitoring
    httpExclusions: [
      '/api/sensitive',
      '/api/internal',
      RegExp(r'/api/user/\d+/private'),
    ],

    // Performance Settings
    maxEventsPerSession: 1000,
    flushInterval: Duration(seconds: 30),
  ),
);
```

## 📊 Event Tracking Examples

### User Authentication

```dart
// Login attempt
await Obsly.trackEvent('auth_login_attempt', metadata: {
  'method': 'email',
  'timestamp': DateTime.now().toIso8601String(),
});

// Login success
await Obsly.trackEvent('auth_login_success', metadata: {
  'userId': userId,
  'sessionId': sessionId,
});
```

### Financial Transactions

```dart
// Money transfer
await Obsly.trackEvent('transfer_initiated', metadata: {
  'fromAccount': fromAccountId,
  'toAccount': toAccountId,
  'amount': amount.toString(), // Automatically filtered if PII
  'currency': 'USD',
});
```

### Error Tracking

```dart
// Automatic crash reporting
try {
  await riskyOperation();
} catch (error, stackTrace) {
  await Obsly.trackError(
    error,
    stackTrace: stackTrace,
    category: 'banking_operation',
    metadata: {'operation': 'transfer'},
  );
}
```

## 🎨 Debug Features

> **📸 See Visual Examples**: Complete screenshots and detailed explanations in the **[Obsly Tools Guide - Banking App Implementation](../doc/obsly-tools-guide.md#banking-app-implementation)**

> **📤 CRÍTICO - Envío de Eventos**: Cuando usas las herramientas de debug (`enableDebugTools: true`), **el envío automático de eventos está DESACTIVADO**. Para ver los eventos en la plataforma Obsly, **DEBES pulsar el botón azul "Send" (📤)** en la pestaña Events del debug overlay, o llamar `ObslySDK.instance.forceFlush()` programáticamente.

### Real-time Event Viewer

- View all tracked events in real-time
- Filter events by type and category
- Inspect event metadata and timestamps
- Export events for analysis

### SDK Configuration Panel

- Toggle tracking features on/off
- Adjust performance settings
- Test PII filtering rules
- View SDK status and health

### Performance Metrics

- App launch time tracking
- Screen render performance
- Memory usage monitoring
- Network request latency

## 🛡️ Security & Privacy

### PII Protection

- Automatic detection and filtering of:
  - Email addresses
  - Credit card numbers
  - Account numbers
  - Social security numbers
  - Custom patterns via regex

### Data Handling

- All sensitive data is filtered before transmission
- Events are stored locally with encryption
- Network requests are monitored but never logged with sensitive payloads
- Debug data is only available in development builds

## 🧪 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
```

### Test Scenarios

- Authentication flows with event tracking
- Transaction processing with monitoring
- Error scenarios and crash handling
- PII filtering validation
- UI interaction tracking

## 📱 Platform Support

| Feature               | iOS | Android | Web |
| --------------------- | --- | ------- | --- |
| Basic tracking        | ✅  | ✅      | ✅  |
| HTTP interception     | ✅  | ✅      | ✅  |
| Crash reporting       | ✅  | ✅      | ⚠️  |
| Biometric auth        | ✅  | ✅      | ❌  |
| Background processing | ✅  | ✅      | ❌  |

## 🔗 Related Resources

- [Obsly Flutter SDK Documentation](../doc/)
- **[Obsly Tools Guide - Banking App Implementation](../doc/obsly-tools-guide.md#banking-app-implementation)** - Complete visual guide with screenshots
- [Banking App Architecture Guide](docs/architecture.md)
- [Security Best Practices](docs/security.md)
- [Performance Optimization](docs/performance.md)

## 📞 Support

If you encounter issues with this example:

1. Check the [troubleshooting guide](docs/troubleshooting.md)
2. Review the [FAQ](docs/faq.md)
3. Open an issue in the [main repository](https://github.com/SoftForYou/flutter_samples/issues)

---

This example demonstrates production-ready integration patterns for the Obsly Flutter SDK in a financial services context.
