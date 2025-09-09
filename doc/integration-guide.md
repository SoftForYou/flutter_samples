# Integration Guide - Obsly Flutter SDK

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Basic Configuration](#basic-configuration)
- [Platform Configuration](#platform-configuration)
- [Advanced Configuration](#advanced-configuration)
- [Integration Verification](#integration-verification)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Minimum Versions

- **Flutter**: >= 3.0.0
- **Dart**: >= 3.4.0
- **iOS**: >= 12.0
- **Android**: API Level 21 (Android 5.0)
- **Web**: Modern browsers (Chrome 88+, Firefox 85+, Safari 14+)

### Obsly Account

1. Contact us at [help@obsly.io](mailto:help@obsly.io) for access
2. Get your API key and instance URL
3. Review documentation and integration examples

## Installation

### 1. Add Dependency

Add `obsly_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  obsly_flutter: ^1.0.1
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Import SDK

```dart
import 'package:obsly_flutter/obsly_sdk.dart';
```

## Basic Configuration

### Simplified API (Recommended - Standard Pattern)

The new API follows the standard pattern of libraries like Firebase, Sentry and Provider:

```dart
import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

void main() {
  // Standard pattern: Error protection + simple configuration
  ObslySDK.run(() {
    runApp(
      ObslySDK.wrapApp(
        app: const MyApp(),
        obslyKey: 'YOUR_OBSLY_API_KEY',
        instanceURL: 'https://api.obsly.io',
        debugMode: true,
        logLevel: LogLevel.debug,
        enableDebugTools: true, // ⚠️ ONLY for development
        config: const ObslyConfig(
          enableDebugTools: true, // ⚠️ ONLY for development
          enableScreenshotOnUi: true,
          rageClick: RageClickConfig(
            active: true,
            screenshot: true,
            screenshotPercent: 0.25,
          ),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      home: const HomePage(),
    );
  }
}
```

### Manual API (For advanced cases)

If you need granular control of initialization:

```dart
import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Manual initialization with error capture
  ObslySDK.run(() async {
    try {
      // Initialize SDK before building the app
      await ObslySDK.instance.init(InitParameters(
        obslyKey: 'YOUR_OBSLY_API_KEY',
        instanceURL: 'https://api.obsly.io',
        appName: 'My Flutter App',
        appVersion: '1.0.0',
        logLevel: LogLevel.error,
        config: const ObslyConfig(
          enableUI: true,
          enableRequestLog: true,
          enableCrashes: true,
          enableDebugTools: false,
          enableScreenshotOnUi: false,
        ),
      ));

      runApp(MyApp());
    } catch (e) {
      // App works without Obsly in case of error
      runApp(MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ObslySDK.instance.wrapAppLegacy(
      app: MaterialApp(
        title: 'My Flutter App',
        home: HomePage(),
      ),
      enableDebugTools: false, // true to show debug overlay
    );
  }
}
```

## Platform Configuration

### iOS

#### 1. Info.plist Configuration

Add necessary permissions in `ios/Runner/Info.plist`:

```xml
<dict>
  <!-- Network permissions (already included by default) -->
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
      <key>obsly.com</key>
      <dict>
        <key>NSExceptionAllowsInsecureHTTPLoads</key>
        <false/>
        <key>NSExceptionMinimumTLSVersion</key>
        <string>TLSv1.2</string>
      </dict>
    </dict>
  </dict>

  <!-- App information -->
  <key>CFBundleDisplayName</key>
  <string>My Flutter App</string>
  <key>CFBundleVersion</key>
  <string>1.0.0</string>
</dict>
```

#### 2. Build Settings Configuration

In `ios/Runner.xcodeproj`, ensure that:

- **iOS Deployment Target**: 12.0 or higher
- **Swift Language Version**: 5.0 or higher

### Android

#### 1. build.gradle Configuration

In `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        // ...
    }
}
```

#### 2. AndroidManifest.xml Permissions

In `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Network permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:label="My Flutter App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">
        <!-- App configuration -->
    </application>
</manifest>
```

### Web

#### 1. index.html Configuration

In `web/index.html`, ensure you include necessary meta tags:

```html
<!DOCTYPE html>
<html>
  <head>
    <base href="$FLUTTER_BASE_HREF" />
    <meta charset="UTF-8" />
    <meta content="IE=Edge" http-equiv="X-UA-Compatible" />
    <meta name="description" content="My Flutter App" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta name="apple-mobile-web-app-title" content="My Flutter App" />
    <link rel="apple-touch-icon" href="icons/Icon-192.png" />
    <link rel="icon" type="image/png" href="favicon.png" />
    <title>My Flutter App</title>

    <!-- Content Security Policy -->
    <meta
      http-equiv="Content-Security-Policy"
      content="default-src 'self' data: gap: https://api.obsly.com;
                 style-src 'self' 'unsafe-inline';
                 script-src 'self' 'unsafe-inline' 'unsafe-eval';"
    />
  </head>
  <body>
    <!-- Flutter app is injected here -->
    <script src="main.dart.js" type="application/javascript"></script>
  </body>
</html>
```

#### 2. CORS Configuration

If using a custom server, ensure CORS is configured correctly:

```dart
// In your server
app.use(cors({
  origin: ['https://your-domain.com', 'http://localhost:3000'],
  credentials: true,
}));
```

## Advanced Configuration

### Rate Limiting Configuration

```dart
const config = ObslyConfig(
  rateLimits: RateLimits(
    // Limits for error events
    error: RateLimitConfig(
      interval: 5000,        // 5 seconds
      bucketSize: 10,        // Maximum 10 errors
      trailing: true,        // Send events at end of period
      emptyBucketDelay: 2000, // 2 seconds before emptying
      rejectWhenBucketFull: true, // Reject when full
    ),

    // Limits for UI events
    ui: RateLimitConfig(
      interval: 1000,        // 1 second
      bucketSize: 20,        // Maximum 20 UI events
      trailing: false,
      emptyBucketDelay: 1000,
    ),

    // Limits for HTTP requests
    request: RateLimitConfig(
      interval: 1000,
      bucketSize: 30,        // More permissive for requests
      trailing: true,
    ),
  ),
);
```

### Request Capture Configuration

#### Headers Whitelist

```dart
const config = ObslyConfig(
  requestHeadersWhitelist: [
    RequestHeadersConfig(
      url: 'https://api.myapp.com/*',
      fromStatus: 400,
      toStatus: 599,
      headers: [
        'content-type',
        'authorization',
        'x-request-id',
        'x-correlation-id',
      ],
    ),
    RequestHeadersConfig(
      url: 'https://payments.myapp.com/*',
      fromStatus: 200,  // Also capture successful responses
      toStatus: 599,
      headers: ['x-transaction-id', 'x-payment-status'],
    ),
  ],
);
```

#### Body Whitelist

```dart
const config = ObslyConfig(
  requestBodyWhitelist: [
    RequestBodyConfig(
      url: 'https://api.myapp.com/auth/*',
      fromStatus: 400,
      toStatus: 499,
      captureRequestBody: true,   // Capture request body
      captureResponseBody: false, // Don't capture response for privacy
    ),
    RequestBodyConfig(
      url: 'https://api.myapp.com/public/*',
      fromStatus: 500,
      toStatus: 599,
      captureRequestBody: true,
      captureResponseBody: true,
    ),
  ],
);
```

### Screenshot Configuration

```dart
const config = ObslyConfig(
  enableScreenshotOnUi: true,
  rageClick: RageClickConfig(
    screenshot: true,
    screenshotPercent: 0.3, // 30% of rage clicks
    threshold: 3,           // 3 fast clicks = rage click
    timeWindow: 1000,       // In 1 second
  ),
);
```

### Environment Configuration

> ⚠️ **IMPORTANT**: Never enable `enableDebugTools: true` in production. Debug tools show internal SDK messages (like "new session created") that should not be visible to end users.

> 📤 **EVENT SENDING BEHAVIOR**: When debug tools are enabled (`enableDebugTools: true`), **automatic event sending is disabled by default**. Events are captured and stored locally but are not sent to the server automatically. To send events to the server, use the **"Send"** button (📤) in the Events tab of the debug overlay or call `ObslySDK.instance.forceFlush()` programmatically.

#### Development

```dart
const developmentConfig = ObslyConfig(
  enableDebugTools: true,
  enableScreenshotOnUi: true,
  enableUI: true,
  enableRequestLog: true,
  enableCrashes: true,
  messengerInterval: 10, // More frequent sending for development
);
```

#### Production

```dart
const productionConfig = ObslyConfig(
  enableDebugTools: false,
  enableScreenshotOnUi: false,
  enableUI: true,
  enableRequestLog: true,
  enableCrashes: true,
  messengerInterval: 60, // Less frequent sending for production
  bufferSize: 50, // Smaller buffer to control memory
);
```

#### Dynamic Environment Configuration

```dart
void main() {
  // Detect environment
  const bool isProduction = bool.fromEnvironment('dart.vm.product');

  ObslySDK.run(() {
    runApp(
      ObslySDK.wrapApp(
        app: const MyApp(),
        obslyKey: isProduction
            ? 'PRODUCTION_API_KEY'
            : 'DEVELOPMENT_API_KEY',
        instanceURL: isProduction
            ? 'https://api.obsly.com'
            : 'https://dev-api.obsly.com',
        debugMode: !isProduction,
        logLevel: isProduction
            ? LogLevel.error
            : LogLevel.debug,
        enableDebugTools: !isProduction,
        config: isProduction
            ? productionConfig
            : developmentConfig,
      ),
    );
  });
}
```

## Integration Verification

### 1. Basic Verification

```dart
void verifyIntegration() {
  // Verify SDK is initialized
  if (ObslySDK.instance.isInitialized) {
    print('✅ SDK initialized correctly');
  } else {
    print('❌ SDK not initialized');
  }

  // Verify session
  final session = ObslySDK.instance.getSessionInfo();
  if (session != null) {
    print('✅ Active session: ${session.sessionId}');
  } else {
    print('❌ No active session');
  }
}
```

### 2. Event Testing

```dart
void testEventCapture() async {
  // Manual event test
  await ObslySDK.instance.trackEvent({
    'type': 'integration_test',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'message': 'Verifying event capture',
  });

  // Metrics test
  await ObslySDK.instance.metrics.incCounter(
    'INTEGRATION_TEST', 'TEST', 'VERIFY', 'SETUP', 'SUCCESS'
  );

  // Performance test
  await ObslySDK.instance.performance.startTransaction('INTEGRATION_TEST');
  await Future.delayed(Duration(milliseconds: 100));
  await ObslySDK.instance.performance.endTransaction('INTEGRATION_TEST');

  print('✅ Event tests completed');
}
```

### 3. Network Verification

```dart
void testNetworkConnection() async {
  try {
    // Force flush to verify connectivity
    await ObslySDK.instance.flush();
    print('✅ Obsly server connection successful');
  } catch (e) {
    print('❌ Connection error: $e');
  }
}
```

### 4. Debug Tools

Enable debug tools temporarily for verification:

```dart
// In development, enable debug tools
return ObslySDK.instance.wrapApp(
  app: myApp,
  enableDebugTools: true, // Temporary for verification
);
```

Debug tools will show:

- ✅ Real-time captured events
- ✅ Session state
- ✅ Current configuration
- ✅ Performance metrics
- ✅ System logs

## Best Practices

### 1. Initialization

```dart
void main() {
  // ✅ Simplified standard pattern
  ObslySDK.run(() {
    runApp(
      ObslySDK.wrapApp(
        app: const MyApp(),
        obslyKey: 'YOUR_OBSLY_API_KEY',
        instanceURL: 'https://api.obsly.io',
        debugMode: true,
        logLevel: LogLevel.debug,
        enableDebugTools: true,
      ),
    );
  });
}

// ✅ For advanced cases with manual control
void mainAdvanced() async {
  WidgetsFlutterBinding.ensureInitialized();

  ObslySDK.run(() async {
    try {
      // ✅ Initialize SDK before runApp()
      await ObslySDK.instance.init(initParams);
      runApp(MyApp());
    } catch (e) {
      // ✅ Handle errors without blocking the app
      print('Error initializing Obsly: $e');
      runApp(MyApp()); // App works without Obsly
    }
  });
}
```

### 2. API Key Management

```dart
// ✅ Use environment variables
class AppConfig {
  static const String obslyApiKey = String.fromEnvironment(
    'OBSLY_API_KEY',
    defaultValue: 'development-key', // Only for development
  );

  static const String obslyInstanceUrl = String.fromEnvironment(
    'OBSLY_INSTANCE_URL',
    defaultValue: 'https://dev-api.obsly.com',
  );
}
```

### 3. Session Management

```dart
class AuthService {
  static Future<void> login(String userId) async {
    // ✅ Start new session on login
    await ObslySDK.instance.setUserID(userId);
    await ObslySDK.instance.startNewSession();

    // ✅ Add relevant context
    await ObslySDK.instance.addTag([
      Tag(key: 'login_method', value: 'email'),
      Tag(key: 'user_type', value: 'premium'),
    ], 'Authentication');
  }

  static Future<void> logout() async {
    // ✅ Close session on logout
    await ObslySDK.instance.closeCurrentSession();
  }
}
```

### 4. Critical Error Capture

```dart
class PaymentService {
  static Future<void> processPayment(PaymentData data) async {
    try {
      // ✅ Start transaction for critical operation
      await ObslySDK.instance.performance.startTransaction(
        'PAYMENT_PROCESS',
        'Processing user payment'
      );

      final result = await paymentGateway.process(data);

      // ✅ Add success context
      await ObslySDK.instance.addTag([
        Tag(key: 'payment_amount', value: data.amount.toString()),
        Tag(key: 'payment_method', value: data.method),
        Tag(key: 'payment_status', value: 'success'),
      ], 'Payment');

      await ObslySDK.instance.performance.endTransaction('PAYMENT_PROCESS');

    } catch (error, stackTrace) {
      // ✅ Capture critical errors with full context
      await ObslySDK.instance.createErrorEvent(
        title: 'Payment Processing Failed',
        message: 'Critical payment failure in checkout flow',
        error: error,
        stackTrace: stackTrace,
        traceId: 'payment-${DateTime.now().millisecondsSinceEpoch}',
      );

      await ObslySDK.instance.performance.endTransaction('PAYMENT_PROCESS');
      rethrow;
    }
  }
}
```

### 5. Performance Monitoring

```dart
class DatabaseService {
  static Future<T> withPerformanceTracking<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    // ✅ Reusable pattern for performance tracking
    await ObslySDK.instance.performance.startTransaction(operationName);

    try {
      final result = await operation();
      await ObslySDK.instance.performance.endTransaction(operationName);
      return result;
    } catch (e) {
      await ObslySDK.instance.performance.endTransaction(operationName);
      rethrow;
    }
  }
}

// Usage:
final users = await DatabaseService.withPerformanceTracking(
  'FETCH_USERS',
  () => database.getUsers(),
);
```

## Troubleshooting

### Problem: SDK doesn't initialize

**Symptoms**: `isInitialized` returns `false`

**Solutions**:

1. Verify `WidgetsFlutterBinding.ensureInitialized()` is called before `init()`
2. Verify API key and Instance URL
3. Verify network connectivity
4. Review logs with `logLevel: LogLevel.debug`

```dart
// ✅ Initialization debugging
await ObslySDK.instance.init(InitParameters(
  // ... parameters
  logLevel: LogLevel.debug, // Temporary for debugging
));

print('Initialized: ${ObslySDK.instance.isInitialized}');
```

### Problem: Events are not sent

**Symptoms**: Events are captured but don't reach the server

**Solutions**:

1. Verify network configuration
2. Verify `isSendActive()` returns `true`
3. Force manual flush

```dart
// ✅ Send debugging
print('Send active: ${ObslySDK.instance.isSendActive()}');
await ObslySDK.instance.forceFlush();
```

### Problem: App slows down

**Symptoms**: App is slower after integrating Obsly

**Solutions**:

1. Configure more restrictive rate limiting
2. Disable screenshots on UI events
3. Reduce logging level in production

```dart
// ✅ Performance-optimized configuration
const config = ObslyConfig(
  enableScreenshotOnUi: false,
  logLevel: LogLevel.error,
  rateLimits: RateLimits(
    ui: RateLimitConfig(bucketSize: 5), // Reduce UI events
  ),
);
```

### Problem: Debug tools don't appear

**Symptoms**: `enableDebugTools: true` doesn't show overlay

**Solutions**:

1. Verify SDK is initialized
2. Verify `wrapApp()` is applied correctly
3. Verify the app is a `MaterialApp`

```dart
// ✅ Debug tools verification
if (!ObslySDK.instance.isInitialized) {
  print('SDK not initialized - debug tools not available');
}

// ✅ Correct application
return ObslySDK.instance.wrapApp(
  app: MaterialApp( // Must be MaterialApp
    // ...
  ),
  enableDebugTools: true,
);
```

### Problem: High memory usage

**Symptoms**: Memory usage increases constantly

**Solutions**:

1. Verify storage configuration
2. Implement automatic cleanup
3. Reduce event retention

```dart
// ✅ Manual cleanup when needed
await ObslySDK.instance.flush();

// ✅ In extreme cases, reinitialize SDK
await ObslySDK.instance.dispose();
await ObslySDK.instance.init(initParams);
```

## GoRouter Integration Guide

### Overview

The Obsly Flutter SDK uses the **standard observer pattern** for GoRouter integration, which is the recommended approach for modern Flutter navigation. However, **very old GoRouter versions** (< 3.0) have limitations that may require workarounds.

> 📱 **GoRouter Version Note**: Our observer pattern (`ObslySDK.goRouterObservers`) works optimally with **GoRouter 3.0+**. For legacy projects using very old GoRouter versions, you may need to upgrade GoRouter first.

> ⚠️ **Legacy Support**: We provided manual integration methods for compatibility with very old GoRouter versions, but these are **deprecated** and will be removed in future versions.

### Current Recommended Pattern

Use the standard observer pattern for GoRouter integration:

```dart
final GoRouter router = GoRouter(
  routes: [...],
  observers: ObslySDK.goRouterObservers, // ✅ Standard pattern
);
```

### Legacy Pattern (For Very Old GoRouter Versions)

**Only for projects with GoRouter < 3.0** that cannot be upgraded, we previously provided manual integration methods. This pattern is **deprecated** and should be avoided:

#### Old GoRouter Setup (GoRouter < 3.0)

```dart
// ❌ OLD - Deprecated pattern (DO NOT USE)

// routes.dart - Old way
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    // ... more routes
  ],
  // NO observers - manual tracking required
);

// main.dart - Old way
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ObslySDK.instance.init(initParams);

  // ❌ Manual GoRouter initialization required
  await ObslySDK.initializeGoRouter(router);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ GoRouter < 3.0 required manual delegate specification
    return MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );

    // ✅ GoRouter 3.0+ simplified to single routerConfig
    // return MaterialApp.router(
    //   routerConfig: router,
    // );
  }
}
```

#### Old Manual Route Tracking

```dart
// ❌ Manual route notifications in your app code
class NavigationService {
  static Future<void> navigateToProfile() async {
    context.go('/profile');
    // Manual notification required after each navigation
    await ObslySDK.notifyRouteChange('/profile');
  }

  static Future<void> navigateToSettings() async {
    context.go('/settings');
    // Manual notification required after each navigation
    await ObslySDK.notifyRouteChange('/settings');
  }
}

// ❌ Manual status checking
void checkGoRouterStatus() {
  bool isActive = ObslySDK.isGoRouterActive();
  if (isActive) {
    print('GoRouter tracking is active');
  }
}
```

#### Problems with Old Pattern

- **❌ Manual synchronization required** - Easy to forget `notifyRouteChange()` calls
- **❌ Error-prone** - Route tracking could get out of sync with actual navigation
- **❌ Boilerplate code** - Required extra code in every navigation action
- **❌ Three separate methods** - Complex API surface
- **❌ No automatic detection** - Had to manually initialize and manage state
- **❌ GoRouter < 3.0 complexity** - Required manual delegate specification in MaterialApp.router

### Standard Observer Pattern (Recommended)

Our SDK uses the standard Flutter observer pattern, which works with **GoRouter 3.0+** using the simplified `routerConfig` approach:

```dart
// ✅ NEW - Automatic pattern (RECOMMENDED)
final GoRouter router = GoRouter(
  routes: [...],
  observers: ObslySDK.goRouterObservers, // 👈 Single line integration
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ObslySDK.instance.init(initParams);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // GoRouter automatically detected
    );
  }
}
```

### Requirements

For optimal GoRouter integration, ensure your project meets these requirements:

- **GoRouter 3.0+** - Our observer pattern works optimally with GoRouter 3.0 and later
- **Flutter 3.0+** - Modern routing APIs require recent Flutter versions

#### For GoRouter < 3.0 Projects

If your project uses very old GoRouter versions (< 3.0), you have two options:

1. **Recommended**: Upgrade GoRouter to 3.0+ and use our standard observer pattern
2. **Legacy**: Use the deprecated manual methods (not recommended, will be removed)

```dart
// Upgrade your pubspec.yaml
dependencies:
  go_router: ^13.0.0  # Use modern version
```

### Upgrading from Legacy Pattern

If you're currently using the deprecated manual methods, follow these steps:

#### Step 1: Upgrade GoRouter (if needed)

First, ensure you have GoRouter 3.0+ in your pubspec.yaml:

```dart
dependencies:
  go_router: ^13.0.0  # Modern version
```

#### Step 2: Remove Manual Methods

Remove all calls to the deprecated manual methods:

```dart
// ❌ Remove these lines from main.dart
await ObslySDK.initializeGoRouter(router);

// ❌ Remove these from your navigation services/functions
await ObslySDK.notifyRouteChange('/new-route');
await ObslySDK.notifyRouteChange('/profile');
await ObslySDK.notifyRouteChange('/settings');

// ❌ Remove status checking calls
bool active = ObslySDK.isGoRouterActive();
```

#### Step 3: Use Standard Observer Pattern

Add the observer to your GoRouter configuration:

```dart
// ✅ Use our standard observer pattern
final GoRouter router = GoRouter(
  routes: [...],
  observers: ObslySDK.goRouterObservers, // Standard integration
);
```

#### Step 4: Complete Example

**Before (Legacy Pattern):**

```dart
// routes.dart - Old way
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
  // ❌ No observers - manual tracking required
);

// navigation_service.dart - Manual notifications required
class NavigationService {
  static Future<void> goToProfile() async {
    context.go('/profile');
    await ObslySDK.notifyRouteChange('/profile'); // ❌ Manual call
  }
}

// main.dart - Old way
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ObslySDK.instance.init(initParams);

  // ❌ Manual GoRouter initialization required
  await ObslySDK.initializeGoRouter(router);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ GoRouter < 3.0 required manual delegates
    return MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
```

**After (Standard Pattern):**

```dart
// routes.dart
final GoRouter router = GoRouter(
  routes: [...],
  observers: ObslySDK.goRouterObservers, // 👈 Add this line
);

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ObslySDK.instance.init(initParams);
  // No manual GoRouter initialization needed

  runApp(MyApp());
}
```

### Benefits of New Pattern

- ✅ **Zero configuration** - Automatic detection and setup
- ✅ **Simplified API** - Single observer line instead of 3 methods
- ✅ **Better reliability** - No manual synchronization needed
- ✅ **Framework-agnostic** - Works with the navigation provider system
- ✅ **Automatic route tracking** - All navigation events captured automatically
- ✅ **Real-time integration** - Immediate route change detection

### Verification

After migration, verify the integration is working:

```dart
void verifyGoRouterIntegration() {
  // Check if navigation tracking is active
  final navigationProvider = NavigationIntegrationV2.instance.goRouterNavigatorProvider;

  if (navigationProvider != null && navigationProvider.isActive) {
    print('✅ GoRouter integration active');
  } else {
    print('❌ GoRouter integration not detected');
  }
}
```

### Complete Working Example

Here's a complete implementation showing the new GoRouter integration:

**routes.dart:**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/home',
  navigatorKey: rootNavigatorKey,
  observers: ObslySDK.goRouterObservers, // 👈 Observer integration
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
```

**main.dart:**

```dart
import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ObslySDK.instance.init(
    const InitParameters(
      obslyKey: 'YOUR_API_KEY',
      instanceURL: 'https://api.obsly.io',
      debugMode: true,
      config: ObslyConfig(
        enableLifeCycleLog: true,
        automaticViewDetection: true,
      ),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ObslySDK.instance.wrapApp(
      app: MaterialApp.router(
        title: 'My App',
        routerConfig: router, // GoRouter automatically detected
      ),
    );
  }
}
```

### Troubleshooting Migration

**Problem**: Navigation events not captured after migration

**Solution**: Ensure `observers: ObslySDK.goRouterObservers` is added to your GoRouter configuration

**Problem**: Compilation errors about missing methods

**Solution**: Remove all calls to deprecated methods (`initializeGoRouter`, `notifyRouteChange`, `isGoRouterActive`)

**Problem**: Multiple navigation systems detected

**Solution**: Ensure you're using either MaterialApp.router (with GoRouter) OR MaterialApp (standard navigation), not both

## Next Steps

After completing basic integration:

1. 📚 Review [Usage Examples](examples.md) for specific cases
2. 🔧 Explore [Advanced Features](advanced-features.md)
3. 🐛 Configure [Debug Tools](debug-tools.md) for development
4. 📈 Implement specific business metrics
5. 🎯 Configure alerts and monitoring (contact help@obsly.io for guidance)

Your Obsly Flutter SDK integration is complete! 🎉
