# Obsly Flutter Library - API Reference

Complete API reference for the Obsly Flutter library. This guide covers all event interception capabilities, rules engine, analytics features, and configuration options.

## Table of Contents

- [Core SDK API](#core-sdk-api)
- [Event Interception API](#event-interception-api)
- [Rules Engine API](#rules-engine-api)
- [Configuration Options](#configuration-options)
- [Analytics & Metrics](#analytics--metrics)
- [Session Management](#session-management)
- [Debug Tools](#debug-tools)

## Core SDK API

### ObslySDK Class

The main entry point for the Obsly library.

#### Initialization

```dart
static Future<void> init(InitParameters parameters)
```

Initializes the Obsly library with the specified configuration.

**Parameters:**
- `parameters` (InitParameters): Configuration for library initialization

**Example:**
```dart
await ObslySDK.instance.init(InitParameters(
  obslyKey: 'your-api-key',
  instanceURL: 'https://api.obsly.io',
  appName: 'My App',
  appVersion: '1.0.0',
  config: ObslyConfig(
    enableUI: true,
    enableRequestLog: true,
    enableCrashes: true,
  ),
));
```

#### App Wrapping

```dart
Widget wrapApp({required Widget app})
```

Wraps your Flutter app to enable automatic event interception.

**Example:**
```dart
ObslySDK.instance.wrapApp(
  app: MaterialApp(
    title: 'My App',
    home: HomePage(),
  ),
)
```

## Event Interception API

The Event Interception API automatically captures various types of events from your Flutter application. This section explains how to set up and configure each type of event interception.

### UI Events

Automatic capture of user interface interactions including taps, gestures, form inputs, and scroll events.

#### Setup and Configuration

To enable UI event interception, configure it during SDK initialization:

```dart
await ObslySDK.instance.init(InitParameters(
  obslyKey: 'your-api-key',
  instanceURL: 'https://api.obsly.io',
  config: ObslyConfig(
    enableUI: true,                      // Enable UI event capture
    enableScreenshotOnUi: false,         // Capture screenshots (optional)
    automaticViewDetection: true,        // Auto-detect screen changes
    rageClick: RageClickConfig(          // Rage click detection
      active: true,
      screenshot: true,
      screenshotPercent: 0.5,
    ),
  ),
));
```

#### Automatically Captured Events

When UI interception is enabled, the following events are captured automatically:

##### Tap Events
- **Button Clicks**: All button interactions (ElevatedButton, TextButton, IconButton, etc.)
- **Widget Taps**: GestureDetector and InkWell taps
- **List Item Taps**: ListView and GridView item selections

```dart
// Example captured data for tap events
{
  "event_type": "ui_tap",
  "widget_type": "ElevatedButton",
  "screen": "LoginScreen",
  "coordinates": {"x": 180, "y": 340},
  "timestamp": "2024-01-15T10:30:00Z",
  "metadata": {
    "button_text": "Login",
    "widget_key": "login_button"
  }
}
```

##### Gesture Events
- **Swipes**: Pan and swipe gestures
- **Long Presses**: Long press interactions
- **Pinch Gestures**: Scale and zoom gestures

```dart
// Example captured data for gesture events
{
  "event_type": "ui_gesture",
  "gesture_type": "swipe",
  "direction": "left",
  "screen": "ProductGallery",
  "velocity": 1250.5,
  "timestamp": "2024-01-15T10:31:00Z"
}
```

##### Form Events
- **Text Input**: TextField and TextFormField interactions
- **Form Submissions**: Form validation and submission events
- **Dropdown Selections**: DropdownButton selections

```dart
// Example captured data for form events
{
  "event_type": "ui_form",
  "action": "text_input",
  "field_name": "email",
  "screen": "RegistrationScreen",
  "field_type": "email",
  "validation_status": "valid",
  "timestamp": "2024-01-15T10:32:00Z"
}
```

##### Scroll Events
- **List Scrolling**: ListView and GridView scroll interactions
- **Page Navigation**: PageView and TabView navigation
- **Scroll Position**: Scroll start, end, and position tracking

```dart
// Example captured data for scroll events
{
  "event_type": "ui_scroll",
  "scroll_type": "list_scroll",
  "direction": "down",
  "screen": "ProductList",
  "scroll_position": 450.0,
  "scroll_extent": 1200.0,
  "timestamp": "2024-01-15T10:33:00Z"
}
```

#### Manual UI Event Tracking

For custom UI events or additional tracking, use the standard `trackEvent` method:

```dart
Future<void> trackEvent(
  String eventName, {
  Map<String, dynamic>? metadata,
  String? category,
  DateTime? timestamp,
})
```

**Examples:**

```dart
// Track custom button interaction
await ObslySDK.instance.trackEvent(
  'custom_button_pressed',
  metadata: {
    'button_id': 'special_action_button',
    'screen': 'dashboard',
    'user_segment': 'premium',
    'feature_flag': 'new_ui_enabled',
  },
  category: 'ui_interaction',
);

// Track complex user interaction
await ObslySDK.instance.trackEvent(
  'multi_step_interaction',
  metadata: {
    'step': 3,
    'total_steps': 5,
    'interaction_type': 'wizard_navigation',
    'time_spent_seconds': 45,
  },
  category: 'user_flow',
);

// Track form field focus
await ObslySDK.instance.trackEvent(
  'form_field_focus',
  metadata: {
    'field_name': 'credit_card_number',
    'form_type': 'payment',
    'field_position': 2,
    'previous_field': 'cardholder_name',
  },
  category: 'form_interaction',
);
```

#### Advanced UI Configuration

For fine-grained control over UI event capture:

```dart
ObslyConfig(
  enableUI: true,
  
  // Screenshot configuration
  enableScreenshotOnUi: true,
  
  // Rage click detection
  rageClick: RageClickConfig(
    active: true,                // Enable rage click detection
    screenshot: true,            // Take screenshot on rage clicks
    screenshotPercent: 0.8,      // Screenshot quality (0.0 - 1.0)
  ),
  
  // Automatic view detection
  automaticViewDetection: true,  // Auto-detect screen transitions
)
```

### HTTP Events

Automatic interception of network requests and responses.

#### Captured Data
- Request URL, method, headers, body
- Response status code, headers, body
- Request/response timing
- Error information

#### Configuration

```dart
ObslyConfig(
  enableRequestLog: true,
  requestBodyWhitelist: [
    RequestBodyConfig(
      url: 'https://api.example.com/*',
      fromStatus: 400,
      toStatus: 599,
      captureRequestBody: true,
      captureResponseBody: true,
    ),
  ],
  requestHeadersWhitelist: [
    RequestHeadersConfig(
      url: 'https://api.example.com/*',
      fromStatus: 200,
      toStatus: 599,
      headers: ['content-type', 'authorization'],
    ),
  ],
)
```

### Navigation Events

Automatic tracking of screen navigation and route changes.

#### Captured Events
- Route pushes and pops
- Screen transitions
- Deep link navigation
- Tab changes

### Console Events

Capture of debug logs and console output.

#### Captured Data
- Debug messages
- Error logs
- Warning messages
- Stack traces

### Crash Events

Automatic detection and reporting of application crashes.

#### Captured Data
- Exception details
- Stack traces
- App state at crash
- Device information

### Lifecycle Events

Monitoring of application lifecycle state changes.

#### Captured Events
- App foreground/background transitions
- Session start/end
- Memory warnings
- Device orientation changes

## Rules Engine API

### Rule Definition

```dart
class Rule {
  final String id;
  final String name;
  final String condition;
  final List<RuleAction> actions;
  final bool enabled;
}
```

### Rule Types

#### Filter Rules
```dart
Rule(
  id: 'filter_test_events',
  name: 'Filter Test Events',
  condition: 'event.metadata.environment === "test"',
  actions: [ExcludeAction()],
)
```

#### Alert Rules
```dart
Rule(
  id: 'critical_error_alert',
  name: 'Critical Error Alert',
  condition: 'event.type === "crash" && event.severity === "critical"',
  actions: [
    AlertAction(
      severity: 'high',
      message: 'Critical error detected',
      channels: ['email', 'slack'],
    ),
  ],
)
```

#### Transform Rules
```dart
Rule(
  id: 'enrich_user_events',
  name: 'Enrich User Events',
  condition: 'event.type === "ui" && event.userId != null',
  actions: [
    TransformAction(
      addMetadata: {
        'user_segment': 'premium',
        'session_duration': '${sessionDuration}',
      },
    ),
  ],
)
```

### Rule Management

```dart
// Add rule
await ObslySDK.instance.addRule(rule);

// Update rule
await ObslySDK.instance.updateRule(ruleId, newRule);

// Delete rule
await ObslySDK.instance.deleteRule(ruleId);

// Enable/disable rule
await ObslySDK.instance.setRuleEnabled(ruleId, enabled);
```

## Configuration Options

### ObslyConfig

| Property | Type | Description |
|----------|------|-------------|
| `enableScreenshotOnUi` | `bool?` | Capture screenshots on UI events |
| `enableCrashes` | `bool?` | Enable crash event capture |
| `enableLifeCycleLog` | `bool?` | Enable lifecycle event logging |
| `enableRequestLog` | `bool?` | Enable HTTP request logging |
| `enableUI` | `bool?` | Enable UI event capture |
| `enableMetrics` | `bool?` | Enable metrics system |
| `enablePerformance` | `bool?` | Enable performance monitoring |
| `automaticViewDetection` | `bool?` | Automatic screen detection |
| `captureConsole` | `bool?` | Capture console logs |
| `captureBodyOnError` | `bool?` | Capture HTTP body on errors |
| `sessionMaxLengthMins` | `int?` | Maximum session duration |
| `bufferSize` | `int?` | Event buffer size |
| `messengerInterval` | `int?` | Event sending interval (min: 10 seconds) |
| `enableDebugTools` | `bool?` | Enable debug tools |
| `requestBlacklist` | `List<String>?` | URLs to ignore |
| `requestBodyWhitelist` | `List<RequestBodyConfig>?` | Body capture configuration |
| `requestHeadersWhitelist` | `List<RequestHeadersConfig>?` | Header capture configuration |
| `rageClick` | `RageClickConfig?` | Rage click detection configuration |

## Analytics & Metrics

### Custom Metrics

```dart
// Counter metrics
await ObslySDK.instance.metrics.incCounter(
  'button_clicks',
  fbl: 'ui',
  operation: 'interaction',
  view: 'home_screen',
  state: 'success',
);

// Gauge metrics
await ObslySDK.instance.metrics.setGauge(
  'active_users',
  activeUserCount,
  fbl: 'analytics',
  operation: 'tracking',
  view: 'dashboard',
  state: 'current',
);

// Histogram metrics
await ObslySDK.instance.metrics.recordHistogram(
  'api_response_time',
  responseTime,
  fbl: 'performance',
  operation: 'api_call',
  view: 'data_loading',
  state: 'completed',
);
```

### Performance Tracking

```dart
// Start performance transaction
await ObslySDK.instance.performance.startTransaction(
  'user_login',
  'Complete user authentication process',
);

// Add performance steps
await ObslySDK.instance.performance.startStep(
  'validate_credentials',
  'user_login',
  'Validate user credentials',
);

await ObslySDK.instance.performance.finishStep(
  'validate_credentials',
  'user_login',
);

// End transaction
await ObslySDK.instance.performance.endTransaction('user_login');
```

### Business Analytics

```dart
// Track business events
await ObslySDK.instance.trackEvent(
  'purchase_completed',
  metadata: {
    'order_id': 'ORD-123456',
    'amount': 99.99,
    'currency': 'USD',
    'payment_method': 'credit_card',
    'items': ['item1', 'item2'],
  },
  category: 'e_commerce',
);
```

## Session Management

### Session Control

```dart
// Start new session
await ObslySDK.instance.startNewSession();

// Set user ID
await ObslySDK.instance.setUserID('user123');

// Set additional IDs
await ObslySDK.instance.setPersonID('person456');
await ObslySDK.instance.setPassportID('passport789');

// Add session tags
await ObslySDK.instance.addTag([
  Tag(key: 'user_type', value: 'premium'),
  Tag(key: 'subscription', value: 'annual'),
], 'User Context');

// End session
await ObslySDK.instance.closeCurrentSession();
```

### Session Information

```dart
// Get current session info
SessionInfo? session = ObslySDK.instance.getSessionInfo();
if (session != null) {
  print('Session ID: ${session.sessionId}');
  print('Start Time: ${session.startTime}');
  print('User ID: ${session.userId}');
}

// Check if session is active
bool isActive = ObslySDK.instance.isSessionActive();
```

## Debug Tools

### Debug Interface

```dart
// Show debug panel (development only)
await ObslySDK.instance.showDebugPanel();

// Get recent events
List<Event> events = await ObslySDK.instance.getRecentEvents(limit: 100);

// Force flush events
await ObslySDK.instance.forceFlush();

// Clear local events
await ObslySDK.instance.clearEvents();
```

### Event Inspection

```dart
// Get event statistics
Map<String, dynamic> stats = await ObslySDK.instance.getEventStats();
print('Total events: ${stats['total_events']}');
print('Pending events: ${stats['pending_events']}');

// Check SDK status
bool isInitialized = ObslySDK.instance.isInitialized;
bool isSendActive = ObslySDK.instance.isSendActive();
```

## Configuration Examples

### Production Configuration

```dart
const productionConfig = ObslyConfig(
  // Core features
  enableUI: true,
  enableRequestLog: true,
  enableCrashes: true,
  enableLifeCycleLog: true,
  enableMetrics: true,
  
  // Privacy settings
  enableScreenshotOnUi: false,
  captureConsole: false,
  
  // Performance settings
  sessionMaxLengthMins: 60,
  messengerInterval: 30,
  bufferSize: 50,
  
  // Security
  enableDebugTools: false,
  
  // Request filtering
  requestBlacklist: [
    'https://analytics.google.com/*',
    'https://firebase.googleapis.com/*',
  ],
  
  requestBodyWhitelist: [
    RequestBodyConfig(
      url: 'https://api.myapp.com/errors/*',
      fromStatus: 500,
      toStatus: 599,
      captureRequestBody: false,
      captureResponseBody: true,
    ),
  ],
);
```

### Development Configuration

```dart
const developmentConfig = ObslyConfig(
  // All features enabled
  enableUI: true,
  enableRequestLog: true,
  enableCrashes: true,
  enableLifeCycleLog: true,
  enableMetrics: true,
  enablePerformance: true,
  
  // Debug settings
  enableScreenshotOnUi: true,
  captureConsole: true,
  enableDebugTools: true,
  
  // More permissive settings
  sessionMaxLengthMins: 120,
  messengerInterval: 10,
  bufferSize: 200,
  
  // Capture more data for debugging
  requestBodyWhitelist: [
    RequestBodyConfig(
      url: 'https://dev-api.myapp.com/*',
      fromStatus: 200,
      toStatus: 599,
      captureRequestBody: true,
      captureResponseBody: true,
    ),
  ],
);
```

## Support

For questions about the API or integration:

- 📧 Email: [help@obsly.io](mailto:help@obsly.io)
- 📖 Documentation: [Complete docs](./)

## Auxiliary Configuration Classes

### RageClickConfig
```dart
class RageClickConfig {
  final bool? active;
  final bool? screenshot;
  final double? screenshotPercent;
}
```

### RequestHeadersConfig
```dart
class RequestHeadersConfig {
  final String url;           // URL pattern (supports wildcards)
  final int fromStatus;       // Minimum status code
  final int toStatus;         // Maximum status code  
  final List<String> headers; // Headers to capture
}
```

### RequestBodyConfig
```dart
class RequestBodyConfig {
  final String url;                    // URL pattern
  final int fromStatus;                // Minimum status code
  final int toStatus;                  // Maximum status code
  final bool captureRequestBody;       // Capture request body
  final bool captureResponseBody;      // Capture response body
}
```

### Event Classes

```dart
class Event {
  final String id;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? category;
  final String sessionId;
}

class Tag {
  final String key;
  final String value;
}

class SessionInfo {
  final String sessionId;
  final DateTime startTime;
  final String? userId;
  final Map<String, dynamic>? metadata;
}
```

## Key Features

1. **Comprehensive Event Interception**: UI, lifecycle, navigation, console, crash, and HTTP events
2. **Rules Engine**: Dynamic event processing and filtering
3. **Real-time Analytics**: Performance monitoring and business metrics
4. **Debug Tools**: Development and troubleshooting capabilities
5. **Flexible Configuration**: Granular control over all features

This API reference covers the complete Obsly Flutter library functionality for comprehensive application observability.
