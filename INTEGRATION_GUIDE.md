# Obsly Flutter SDK - Integration Guide

Step-by-step guide to integrate the Obsly Flutter SDK into your existing Flutter application. This guide covers everything from basic setup to advanced features.

## 📋 Overview

The Obsly Flutter SDK provides comprehensive app monitoring, analytics, and debugging capabilities. This guide will help you integrate it into your Flutter app efficiently and securely.

### What You'll Learn
- ✅ Basic SDK integration
- ✅ Configuration options
- ✅ Event tracking patterns
- ✅ Error handling setup
- ✅ Performance monitoring
- ✅ Privacy and security
- ✅ Testing and debugging

## 🚀 Quick Integration

### Step 1: Add Dependency

Add the Obsly Flutter SDK to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  obsly_flutter: ^1.0.1  # Latest version
```

Run the dependency installation:
```bash
flutter pub get
```

### Step 2: Basic Setup

Initialize the SDK in your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Obsly SDK
  await ObslySDK.instance.init(
    InitParameters(
      obslyKey: 'YOUR_API_KEY_HERE',
      instanceURL: 'https://api.obsly.io',
      debugMode: kDebugMode,
      config: ObslyConfig(
        enableCrashReporting: true,
        enableUITracking: true,
      ),
    ),
  );
  
  runApp(MyApp());
}
```

### Step 3: Get Your API Key

1. Contact [help@obsly.io](mailto:help@obsly.io) for access
2. Get your API key and instance URL
3. Review integration documentation

## 🔧 Detailed Integration

### Project Structure Integration

Here's how to organize Obsly integration in your project:

```
lib/
├── main.dart                 # SDK initialization
├── config/
│   └── obsly_config.dart     # Centralized configuration
├── services/
│   └── analytics_service.dart # Wrapper service
├── utils/
│   └── error_handler.dart    # Error handling utilities
└── widgets/
    └── tracked_widgets.dart  # UI tracking widgets
```

### Configuration Service

Create a centralized configuration service:

**lib/config/obsly_config.dart:**
```dart
import 'package:flutter/foundation.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class ObslyConfigService {
  static const String _apiKey = String.fromEnvironment(
    'OBSLY_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );
  
  static const String _instanceUrl = String.fromEnvironment(
    'OBSLY_INSTANCE_URL',
    defaultValue: 'https://api.obsly.io',
  );
  
  static InitParameters get parameters => InitParameters(
    obslyKey: _apiKey,
    instanceURL: _instanceUrl,
    debugMode: kDebugMode,
    logLevel: kDebugMode ? LogLevel.debug : LogLevel.error,
    config: _buildConfig(),
  );
  
  static ObslyConfig _buildConfig() {
    return ObslyConfig(
      enableCrashReporting: true,
      enableHttpInterception: !kDebugMode, // Only in production
      enableUITracking: true,
      enableDebugTools: kDebugMode,
      
      // Privacy protection
      piiFilters: [
        PIIFilter.email(),
        PIIFilter.creditCard(),
        PIIFilter.phoneNumber(),
        PIIFilter.custom(
          pattern: r'\b\d{3}-\d{2}-\d{4}\b', // SSN
          replacement: '[SSN-FILTERED]',
        ),
      ],
      
      // HTTP monitoring exclusions
      httpExclusions: [
        '/health',
        '/metrics',
        '/api/internal/',
        RegExp(r'/api/user/\d+/private'),
      ],
      
      // Performance settings
      maxEventsPerSession: kDebugMode ? 500 : 1000,
      flushInterval: Duration(seconds: kDebugMode ? 10 : 30),
      sessionTimeout: Duration(minutes: 30),
    );
  }
}
```

### Analytics Service Wrapper

Create a service wrapper for easier usage:

**lib/services/analytics_service.dart:**
```dart
import 'package:obsly_flutter/obsly_sdk.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  
  bool get isInitialized => ObslySDK.instance.isInitialized;
  
  // Event tracking
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? metadata,
  }) async {
    await ObslySDK.instance.trackEvent(
      'user_action',
      metadata: {
        'action': action,
        ...?metadata,
      },
      category: 'user_interaction',
    );
  }
  
  Future<void> trackScreenView(String screenName) async {
    await ObslySDK.instance.trackScreenView(
      screenName,
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> trackBusinessEvent(
    String eventType,
    Map<String, dynamic> data,
  ) async {
    await ObslySDK.instance.trackEvent(
      eventType,
      metadata: data,
      category: 'business_logic',
    );
  }
  
  // Error tracking
  Future<void> trackError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    await ObslySDK.instance.trackError(
      error,
      stackTrace: stackTrace,
      category: context ?? 'general_error',
      metadata: metadata,
    );
  }
  
  // Session management
  Future<void> startUserSession(String userId) async {
    await ObslySDK.instance.startSession(
      userId: userId,
      metadata: {
        'session_start': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> endUserSession() async {
    await ObslySDK.instance.endSession();
  }
}
```

### Error Handler

Create a global error handler:

**lib/utils/error_handler.dart:**
```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class GlobalErrorHandler {
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _handleFlutterError(details);
    };
    
    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleAsyncError(error, stack);
      return true;
    };
  }
  
  static void _handleFlutterError(FlutterErrorDetails details) {
    AnalyticsService().trackError(
      details.exception,
      stackTrace: details.stack,
      context: 'flutter_framework',
      metadata: {
        'library': details.library,
        'context': details.context?.toString(),
        'widget': details.informationCollector?.call()?.toString(),
      },
    );
  }
  
  static void _handleAsyncError(Object error, StackTrace stack) {
    AnalyticsService().trackError(
      error,
      stackTrace: stack,
      context: 'async_error',
    );
  }
  
  // Wrapper for risky operations
  static Future<T?> handleOperation<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallback,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      await AnalyticsService().trackError(
        error,
        stackTrace: stackTrace,
        context: context ?? 'operation_error',
      );
      return fallback;
    }
  }
}
```

## 🎯 Integration Patterns

### Screen Tracking

#### Automatic Screen Tracking

For routes-based navigation:

```dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Track screen view
    AnalyticsService().trackScreenView(settings.name ?? 'unknown');
    
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => NotFoundScreen());
    }
  }
}
```

#### Manual Screen Tracking

For widget-based navigation:

```dart
abstract class TrackedStatefulWidget extends StatefulWidget {
  const TrackedStatefulWidget({Key? key}) : super(key: key);
  
  String get screenName;
}

abstract class TrackedState<T extends TrackedStatefulWidget> 
    extends State<T> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().trackScreenView(widget.screenName);
    });
  }
}

// Usage
class HomeScreen extends TrackedStatefulWidget {
  @override
  String get screenName => 'home_screen';
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends TrackedState<HomeScreen> {
  // Your widget implementation
}
```

### Button Tracking

Create tracked button widgets:

**lib/widgets/tracked_widgets.dart:**
```dart
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class TrackedElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String buttonId;
  final Map<String, dynamic>? trackingMetadata;
  
  const TrackedElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.buttonId,
    this.trackingMetadata,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null ? null : () {
        // Track button press
        AnalyticsService().trackUserAction(
          'button_pressed',
          metadata: {
            'button_id': buttonId,
            'screen': ModalRoute.of(context)?.settings.name ?? 'unknown',
            ...?trackingMetadata,
          },
        );
        
        // Execute original callback
        onPressed!();
      },
      child: child,
    );
  }
}

// Usage
TrackedElevatedButton(
  buttonId: 'login_button',
  onPressed: () => _handleLogin(),
  trackingMetadata: {'auth_method': 'email'},
  child: Text('Login'),
)
```

### Form Tracking

Track form interactions:

```dart
class TrackedForm extends StatefulWidget {
  final Widget child;
  final String formId;
  final VoidCallback? onSubmit;
  
  const TrackedForm({
    Key? key,
    required this.child,
    required this.formId,
    this.onSubmit,
  }) : super(key: key);
  
  @override
  _TrackedFormState createState() => _TrackedFormState();
}

class _TrackedFormState extends State<TrackedForm> {
  late DateTime _startTime;
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Track form start
    AnalyticsService().trackUserAction(
      'form_started',
      metadata: {'form_id': widget.formId},
    );
  }
  
  void _handleSubmit() {
    final duration = DateTime.now().difference(_startTime);
    
    // Track form submission
    AnalyticsService().trackUserAction(
      'form_submitted',
      metadata: {
        'form_id': widget.formId,
        'completion_time_seconds': duration.inSeconds,
      },
    );
    
    widget.onSubmit?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      child: widget.child,
    );
  }
}
```

### HTTP Request Tracking

For manual HTTP tracking (when auto-interception is disabled):

```dart
class TrackedHttpClient {
  final http.Client _client = http.Client();
  
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await _client.post(url, headers: headers, body: body);
      stopwatch.stop();
      
      // Track successful request
      AnalyticsService().trackUserAction(
        'http_request',
        metadata: {
          'method': 'POST',
          'url': url.toString(),
          'status_code': response.statusCode,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'success': response.statusCode < 400,
        },
      );
      
      return response;
    } catch (error) {
      stopwatch.stop();
      
      // Track failed request
      AnalyticsService().trackError(
        error,
        context: 'http_request',
        metadata: {
          'method': 'POST',
          'url': url.toString(),
          'duration_ms': stopwatch.elapsedMilliseconds,
        },
      );
      
      rethrow;
    }
  }
}
```

## 🔐 Environment Configuration

### Development vs Production

Use different configurations for different environments:

**pubspec.yaml:**
```yaml
dependencies:
  flutter_dotenv: ^5.0.2  # For environment variables
```

**.env.development:**
```
OBSLY_API_KEY=dev_api_key_here
OBSLY_INSTANCE_URL=https://api.staging.obsly.io
ENABLE_DEBUG_TOOLS=true
```

**.env.production:**
```
OBSLY_API_KEY=prod_api_key_here
OBSLY_INSTANCE_URL=https://api.obsly.io
ENABLE_DEBUG_TOOLS=false
```

**Environment-aware configuration:**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static Future<void> load() async {
    if (kDebugMode) {
      await dotenv.load(fileName: '.env.development');
    } else {
      await dotenv.load(fileName: '.env.production');
    }
  }
  
  static String get obslyApiKey => 
    dotenv.env['OBSLY_API_KEY'] ?? 'YOUR_API_KEY_HERE';
  
  static String get obslyInstanceUrl => 
    dotenv.env['OBSLY_INSTANCE_URL'] ?? 'https://api.obsly.io';
  
  static bool get enableDebugTools => 
    dotenv.env['ENABLE_DEBUG_TOOLS']?.toLowerCase() == 'true';
}

// Usage in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EnvironmentConfig.load();
  
  await ObslySDK.instance.init(
    InitParameters(
      obslyKey: EnvironmentConfig.obslyApiKey,
      instanceURL: EnvironmentConfig.obslyInstanceUrl,
      debugMode: kDebugMode,
      config: ObslyConfig(
        enableDebugTools: EnvironmentConfig.enableDebugTools,
        // ... other config
      ),
    ),
  );
  
  runApp(MyApp());
}
```

## 🧪 Testing Integration

### Unit Testing

Mock the Obsly SDK for unit tests:

```dart
// test/mocks/mock_obsly_sdk.dart
import 'package:mockito/mockito.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class MockObslySDK extends Mock implements ObslySDK {
  @override
  bool get isInitialized => true;
  
  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? metadata,
    String? category,
    DateTime? timestamp,
  }) async {
    // Mock implementation
  }
}

// test/services/analytics_service_test.dart
void main() {
  group('AnalyticsService', () {
    late MockObslySDK mockSdk;
    late AnalyticsService analyticsService;
    
    setUp(() {
      mockSdk = MockObslySDK();
      // Inject mock into service
      analyticsService = AnalyticsService();
    });
    
    test('should track user action', () async {
      await analyticsService.trackUserAction('test_action');
      
      verify(mockSdk.trackEvent(
        'user_action',
        metadata: any,
        category: 'user_interaction',
      )).called(1);
    });
  });
}
```

### Integration Testing

Test SDK integration in real scenarios:

```dart
// integration_test/obsly_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;
import 'package:obsly_flutter/obsly_sdk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Obsly Integration Tests', () {
    testWidgets('SDK initializes successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      expect(ObslySDK.instance.isInitialized, isTrue);
    });
    
    testWidgets('Events are tracked on user interaction', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Tap a button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify event was tracked (check debug panel or logs)
      final events = await ObslySDK.instance.getRecentEvents();
      expect(events.any((e) => e.name == 'user_action'), isTrue);
    });
  });
}
```

## 📊 Performance Considerations

### Optimizing Event Volume

```dart
class SmartAnalyticsService {
  static const int _maxEventsPerMinute = 10;
  final Map<String, List<DateTime>> _eventHistory = {};
  
  Future<void> trackEventWithRateLimit(
    String eventName, {
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(Duration(minutes: 1));
    
    // Clean old events
    _eventHistory[eventName]?.removeWhere((time) => time.isBefore(oneMinuteAgo));
    
    // Check rate limit
    final recentEvents = _eventHistory[eventName] ?? [];
    if (recentEvents.length >= _maxEventsPerMinute) {
      return; // Skip this event
    }
    
    // Track event and record timestamp
    await ObslySDK.instance.trackEvent(eventName, metadata: metadata);
    _eventHistory[eventName] = [...recentEvents, now];
  }
}
```

### Batch Processing

```dart
class BatchAnalyticsService {
  final List<Map<String, dynamic>> _eventQueue = [];
  Timer? _flushTimer;
  
  void queueEvent(String eventName, Map<String, dynamic>? metadata) {
    _eventQueue.add({
      'name': eventName,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Schedule flush if not already scheduled
    _flushTimer ??= Timer(Duration(seconds: 5), _flushEvents);
  }
  
  void _flushEvents() {
    if (_eventQueue.isEmpty) return;
    
    // Process all queued events
    for (final event in _eventQueue) {
      ObslySDK.instance.trackEvent(
        event['name'],
        metadata: event['metadata'],
      );
    }
    
    _eventQueue.clear();
    _flushTimer = null;
  }
}
```

## 🔍 Debugging and Troubleshooting

### Debug Configuration

Enable comprehensive debugging:

```dart
ObslyConfig(
  enableDebugTools: true,
  debugMode: true,
  logLevel: LogLevel.verbose,
)
```

### Custom Debug Widget

Create a debug panel for development:

```dart
class ObslyDebugPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Obsly Debug')),
      body: ListView(
        children: [
          ListTile(
            title: Text('SDK Status'),
            subtitle: Text(ObslySDK.instance.isInitialized ? 'Initialized' : 'Not initialized'),
          ),
          ListTile(
            title: Text('Recent Events'),
            onTap: () => _showRecentEvents(context),
          ),
          ListTile(
            title: Text('Clear Events'),
            onTap: () => ObslySDK.instance.clearEvents(),
          ),
        ],
      ),
    );
  }
  
  void _showRecentEvents(BuildContext context) async {
    final events = await ObslySDK.instance.getRecentEvents();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recent Events'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.name),
                subtitle: Text(event.timestamp.toString()),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
```

## 📋 Migration Guide

### From Other Analytics SDKs

If you're migrating from another analytics SDK:

```dart
// Legacy Firebase Analytics
// await FirebaseAnalytics.instance.logEvent(
//   name: 'user_action',
//   parameters: {'action': 'login'},
// );

// Obsly equivalent
await AnalyticsService().trackUserAction(
  'login',
  metadata: {'action': 'login'},
);
```

### Gradual Integration

Implement Obsly alongside existing analytics:

```dart
class HybridAnalyticsService {
  Future<void> trackEvent(
    String eventName,
    Map<String, dynamic>? metadata,
  ) async {
    // Track with both systems during migration
    await Future.wait([
      // Existing analytics
      FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: metadata ?? {},
      ),
      
      // New Obsly analytics
      ObslySDK.instance.trackEvent(
        eventName,
        metadata: metadata,
      ),
    ]);
  }
}
```

## ✅ Checklist

Before going to production:

- [ ] API key configured correctly
- [ ] PII filters implemented
- [ ] Error handling set up
- [ ] Performance optimizations applied
- [ ] Integration tested on all platforms
- [ ] Debug tools disabled in production
- [ ] Privacy compliance verified
- [ ] Documentation updated

## 📞 Support

Need help with integration?

- 📖 [API Reference](API_REFERENCE.md)
- 🛠️ [Setup Guide](SETUP.md)
- 💬 [Community Discord](https://discord.gg/obsly)
- 🐛 [Report Issues](https://github.com/SoftForYou/flutter_samples/issues)

---

**Happy integrating! 🚀**
