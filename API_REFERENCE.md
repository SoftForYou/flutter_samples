# Obsly Flutter SDK - API Reference

Complete API reference for the Obsly Flutter SDK version 0.2.0. This guide covers all public APIs, configuration options, and integration patterns.

## 📚 Table of Contents

- [Installation](#installation)
- [Initialization](#initialization)
- [Core APIs](#core-apis)
- [Configuration](#configuration)
- [Event Tracking](#event-tracking)
- [Error Handling](#error-handling)
- [HTTP Monitoring](#http-monitoring)
- [UI Tracking](#ui-tracking)
- [Debug Tools](#debug-tools)
- [Types & Models](#types--models)

## 🚀 Installation

Add the SDK to your `pubspec.yaml`:

```yaml
dependencies:
  obsly_flutter: ^0.2.0
```

Import in your Dart files:

```dart
import 'package:obsly_flutter/obsly_sdk.dart';
```

## ⚙️ Initialization

### ObslySDK.instance.init()

Initialize the Obsly SDK with configuration parameters.

```dart
Future<void> init(InitParameters parameters)
```

**Parameters:**
- `parameters` (InitParameters): Configuration for SDK initialization

**Example:**
```dart
await ObslySDK.instance.init(
  InitParameters(
    obslyKey: 'your-api-key',
    instanceURL: 'https://api.obsly.io',
    debugMode: kDebugMode,
    config: ObslyConfig(
      enableCrashReporting: true,
      enableUITracking: true,
    ),
  ),
);
```

### InitParameters

Configuration class for SDK initialization.

**Properties:**
- `obslyKey` (String): Your Obsly API key
- `instanceURL` (String): Obsly API endpoint URL
- `debugMode` (bool): Enable debug logging and tools
- `logLevel` (LogLevel): Logging verbosity level
- `config` (ObslyConfig): Advanced SDK configuration

**Example:**
```dart
const parameters = InitParameters(
  obslyKey: 'your-api-key',
  instanceURL: 'https://api.obsly.io',
  debugMode: true,
  logLevel: LogLevel.debug,
  config: ObslyConfig(/* ... */),
);
```

## 🔧 Core APIs

### ObslySDK.instance

Main SDK instance for accessing all functionality.

**Properties:**
- `isInitialized` (bool): Whether SDK has been initialized
- `currentSession` (Session?): Current user session
- `config` (ObslyConfig): Current SDK configuration

### Event Tracking

#### trackEvent()

Track custom events with metadata.

```dart
Future<void> trackEvent(
  String eventName, {
  Map<String, dynamic>? metadata,
  String? category,
  DateTime? timestamp,
})
```

**Parameters:**
- `eventName` (String): Name of the event
- `metadata` (Map<String, dynamic>?): Additional event data
- `category` (String?): Event category for filtering
- `timestamp` (DateTime?): Custom timestamp (defaults to now)

**Example:**
```dart
await ObslySDK.instance.trackEvent(
  'user_action',
  metadata: {
    'button': 'login',
    'screen': 'auth',
    'user_id': '12345',
  },
  category: 'authentication',
);
```

#### trackError()

Track errors and exceptions.

```dart
Future<void> trackError(
  dynamic error, {
  StackTrace? stackTrace,
  String? category,
  Map<String, dynamic>? metadata,
  bool fatal = false,
})
```

**Parameters:**
- `error` (dynamic): The error or exception
- `stackTrace` (StackTrace?): Stack trace for the error
- `category` (String?): Error category
- `metadata` (Map<String, dynamic>?): Additional error context
- `fatal` (bool): Whether this is a fatal error

**Example:**
```dart
try {
  await riskyOperation();
} catch (error, stackTrace) {
  await ObslySDK.instance.trackError(
    error,
    stackTrace: stackTrace,
    category: 'api_error',
    metadata: {'endpoint': '/api/users'},
    fatal: false,
  );
}
```

#### trackScreenView()

Track screen navigation and views.

```dart
Future<void> trackScreenView(
  String screenName, {
  Map<String, dynamic>? metadata,
})
```

**Parameters:**
- `screenName` (String): Name of the screen
- `metadata` (Map<String, dynamic>?): Additional screen context

**Example:**
```dart
await ObslySDK.instance.trackScreenView(
  'home_screen',
  metadata: {
    'user_type': 'premium',
    'tab': 'dashboard',
  },
);
```

## ⚙️ Configuration

### ObslyConfig

Advanced configuration options for the SDK.

```dart
class ObslyConfig {
  const ObslyConfig({
    this.enableCrashReporting = true,
    this.enableHttpInterception = false,
    this.enableUITracking = false,
    this.enableDebugTools = false,
    this.piiFilters = const [],
    this.httpExclusions = const [],
    this.maxEventsPerSession = 1000,
    this.flushInterval = const Duration(seconds: 30),
    this.sessionTimeout = const Duration(minutes: 30),
  });
}
```

**Properties:**

#### Core Features
- `enableCrashReporting` (bool): Automatic crash detection and reporting
- `enableHttpInterception` (bool): Automatic HTTP request monitoring
- `enableUITracking` (bool): Automatic UI interaction tracking
- `enableDebugTools` (bool): Enable debug panel and tools

#### Privacy & Security
- `piiFilters` (List<PIIFilter>): Filters for personally identifiable information
- `httpExclusions` (List<dynamic>): URLs/patterns to exclude from monitoring

#### Performance
- `maxEventsPerSession` (int): Maximum events to store per session
- `flushInterval` (Duration): How often to send events to server
- `sessionTimeout` (Duration): When to consider a session ended

**Example:**
```dart
const config = ObslyConfig(
  enableCrashReporting: true,
  enableHttpInterception: true,
  enableUITracking: true,
  enableDebugTools: kDebugMode,
  piiFilters: [
    PIIFilter.email(),
    PIIFilter.creditCard(),
    PIIFilter.custom(pattern: r'\b\d{3}-\d{2}-\d{4}\b'),
  ],
  httpExclusions: [
    '/api/sensitive',
    '/internal/',
    RegExp(r'/api/user/\d+/private'),
  ],
  maxEventsPerSession: 500,
  flushInterval: Duration(seconds: 15),
);
```

### PIIFilter

Filters for protecting personally identifiable information.

#### Predefined Filters
```dart
// Email addresses
PIIFilter.email()

// Credit card numbers
PIIFilter.creditCard()

// Phone numbers
PIIFilter.phoneNumber()

// Account numbers
PIIFilter.accountNumber()

// Custom regex pattern
PIIFilter.custom(pattern: r'your-regex-pattern')
```

**Example:**
```dart
const piiFilters = [
  PIIFilter.email(),
  PIIFilter.creditCard(),
  PIIFilter.custom(
    pattern: r'\b\d{3}-\d{2}-\d{4}\b', // SSN pattern
    replacement: '[SSN-FILTERED]',
  ),
];
```

## 🌐 HTTP Monitoring

### Automatic Interception

When `enableHttpInterception` is true, the SDK automatically monitors:
- Request/response times
- HTTP status codes
- Request/response sizes
- Request URLs (filtered for PII)

### Manual HTTP Events

Track HTTP requests manually:

```dart
await ObslySDK.instance.trackEvent(
  'http_request',
  metadata: {
    'method': 'POST',
    'url': '/api/users',
    'status_code': 200,
    'duration_ms': 150,
    'request_size': 1024,
    'response_size': 2048,
  },
  category: 'network',
);
```

### HTTP Configuration

```dart
ObslyConfig(
  enableHttpInterception: true,
  httpExclusions: [
    '/health',
    '/metrics',
    RegExp(r'/api/internal/.*'),
    'https://external-analytics.com',
  ],
)
```

## 🎯 UI Tracking

### Automatic UI Events

When `enableUITracking` is true, the SDK automatically tracks:
- Button taps
- Form submissions
- Navigation events
- Gesture interactions

### Manual UI Events

Track UI interactions manually:

```dart
// Button press
await ObslySDK.instance.trackEvent(
  'button_pressed',
  metadata: {
    'button_id': 'login_button',
    'screen': 'auth_screen',
    'coordinates': {'x': 100, 'y': 200},
  },
  category: 'ui_interaction',
);

// Form submission
await ObslySDK.instance.trackEvent(
  'form_submitted',
  metadata: {
    'form_type': 'contact_form',
    'field_count': 5,
    'completion_time_ms': 45000,
  },
  category: 'user_input',
);
```

## 🔍 Debug Tools

### Debug Panel

Access the debug interface programmatically:

```dart
// Show debug panel
await ObslySDK.instance.showDebugPanel();

// Check if debug tools are enabled
bool debugEnabled = ObslySDK.instance.config.enableDebugTools;
```

### Debug Events

View captured events:

```dart
// Get recent events
List<Event> events = await ObslySDK.instance.getRecentEvents(limit: 50);

// Clear events
await ObslySDK.instance.clearEvents();
```

### Debug Widget

Include the debug floating action button:

```dart
import 'package:obsly_flutter/widgets/obsly_debug_fab.dart';

Scaffold(
  body: YourContent(),
  floatingActionButton: ObslyDebugFAB(), // Automatic debug panel access
)
```

## 📊 Types & Models

### Event

Represents a tracked event.

```dart
class Event {
  final String id;
  final String name;
  final String? category;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String sessionId;
}
```

### Session

Represents a user session.

```dart
class Session {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String userId;
  final Map<String, dynamic>? metadata;
}
```

### LogLevel

Enumeration for logging levels.

```dart
enum LogLevel {
  none,    // No logging
  error,   // Errors only
  warning, // Warnings and errors
  info,    // General information
  debug,   // Detailed debug information
  verbose, // All logging
}
```

## 🔄 Advanced Usage

### Custom Session Management

```dart
// Start a new session
await ObslySDK.instance.startSession(
  userId: 'user123',
  metadata: {'user_type': 'premium'},
);

// End current session
await ObslySDK.instance.endSession();
```

### Batch Event Processing

```dart
// Queue events for batch processing
await ObslySDK.instance.queueEvent(event1);
await ObslySDK.instance.queueEvent(event2);

// Flush queued events
await ObslySDK.instance.flushEvents();
```

### Configuration Updates

```dart
// Update configuration at runtime
await ObslySDK.instance.updateConfig(
  ObslyConfig(
    enableDebugTools: false,
    maxEventsPerSession: 2000,
  ),
);
```

## 🚨 Error Handling

### SDK Errors

Handle SDK-specific errors:

```dart
try {
  await ObslySDK.instance.init(parameters);
} on ObslyInitializationException catch (e) {
  print('Failed to initialize Obsly: ${e.message}');
} on ObslyNetworkException catch (e) {
  print('Network error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

### Exception Types

- `ObslyInitializationException`: SDK initialization failures
- `ObslyNetworkException`: Network connectivity issues
- `ObslyConfigurationException`: Invalid configuration
- `ObslyStorageException`: Local storage issues

## 📋 Best Practices

### Performance
- Use appropriate `flushInterval` for your app's usage patterns
- Set reasonable `maxEventsPerSession` limits
- Consider disabling debug tools in production

### Privacy
- Always configure PII filters for sensitive data
- Use HTTP exclusions for sensitive endpoints
- Review tracked metadata for privacy compliance

### Error Handling
- Wrap SDK calls in try-catch blocks
- Provide fallback behavior when SDK fails
- Monitor SDK health in production

### Testing
- Use debug mode during development
- Test with various network conditions
- Verify PII filtering effectiveness

---

## 📞 Support

For additional help:
- 📖 [Documentation](./doc/)
- 🐛 [Report Issues](https://github.com/SoftForYou/flutter_samples/issues)
- 💬 [Community Support](https://discord.gg/obsly)

**Version**: 0.2.0 | **Last Updated**: December 2024
