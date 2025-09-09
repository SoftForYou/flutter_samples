# Obsly Flutter SDK - Code Examples

Comprehensive collection of code examples showing how to use the Obsly Flutter SDK in various scenarios. These examples are based on real implementations from the banking_app and obsly_demo_app.

## 📋 Table of Contents

- [Basic Setup](#basic-setup)
- [Event Tracking](#event-tracking)
- [User Interface Tracking](#user-interface-tracking)
- [HTTP Monitoring](#http-monitoring)
- [Error Handling](#error-handling)
- [Authentication Flows](#authentication-flows)
- [E-commerce Tracking](#e-commerce-tracking)
- [Performance Monitoring](#performance-monitoring)
- [Custom Widgets](#custom-widgets)
- [Advanced Patterns](#advanced-patterns)

## 🚀 Basic Setup

### Minimal Setup

```dart
import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Obsly Example',
      home: HomeScreen(),
    );
  }
}
```

### Production Setup with Environment Variables

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await ObslySDK.instance.init(
    InitParameters(
      obslyKey: const String.fromEnvironment(
        'OBSLY_API_KEY',
        defaultValue: 'YOUR_API_KEY_HERE',
      ),
      instanceURL: const String.fromEnvironment(
        'OBSLY_INSTANCE_URL',
        defaultValue: 'https://api.obsly.io',
      ),
      debugMode: kDebugMode,
      logLevel: kDebugMode ? LogLevel.debug : LogLevel.error,
      config: ObslyConfig(
        enableCrashReporting: true,
        enableHttpInterception: !kDebugMode, // Only in production
        enableUITracking: true,
        enableDebugTools: kDebugMode,
        
        // Privacy protection
        piiFilters: [
          PIIFilter.email(),
          PIIFilter.creditCard(),
          PIIFilter.phoneNumber(),
        ],
        
        // Performance optimization
        maxEventsPerSession: kDebugMode ? 500 : 1000,
        flushInterval: Duration(seconds: kDebugMode ? 10 : 30),
      ),
    ),
  );
  
  runApp(MyApp());
}
```

## 📊 Event Tracking

### Basic Event Tracking

```dart
class EventTrackingExamples {
  // Simple event
  Future<void> trackSimpleEvent() async {
    await ObslySDK.instance.trackEvent('user_action');
  }
  
  // Event with metadata
  Future<void> trackEventWithMetadata() async {
    await ObslySDK.instance.trackEvent(
      'button_clicked',
      metadata: {
        'button_id': 'save_button',
        'screen': 'profile_edit',
        'user_type': 'premium',
      },
      category: 'user_interaction',
    );
  }
  
  // Custom timestamp event
  Future<void> trackPastEvent() async {
    await ObslySDK.instance.trackEvent(
      'offline_action',
      metadata: {'action': 'data_sync'},
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
    );
  }
  
  // Business event
  Future<void> trackBusinessEvent() async {
    await ObslySDK.instance.trackEvent(
      'purchase_completed',
      metadata: {
        'order_id': 'ORD-123456',
        'amount': 99.99,
        'currency': 'USD',
        'payment_method': 'credit_card',
        'items_count': 3,
      },
      category: 'e_commerce',
    );
  }
}
```

### User Journey Tracking

```dart
class UserJourneyTracker {
  String? _currentFlow;
  DateTime? _flowStartTime;
  
  void startFlow(String flowName) {
    _currentFlow = flowName;
    _flowStartTime = DateTime.now();
    
    ObslySDK.instance.trackEvent(
      'flow_started',
      metadata: {
        'flow_name': flowName,
        'start_time': _flowStartTime!.toIso8601String(),
      },
      category: 'user_journey',
    );
  }
  
  void trackFlowStep(String stepName, {Map<String, dynamic>? stepData}) {
    if (_currentFlow == null) return;
    
    ObslySDK.instance.trackEvent(
      'flow_step',
      metadata: {
        'flow_name': _currentFlow!,
        'step_name': stepName,
        'step_data': stepData,
        'time_since_start': DateTime.now().difference(_flowStartTime!).inSeconds,
      },
      category: 'user_journey',
    );
  }
  
  void completeFlow({bool success = true, String? reason}) {
    if (_currentFlow == null) return;
    
    final duration = DateTime.now().difference(_flowStartTime!);
    
    ObslySDK.instance.trackEvent(
      'flow_completed',
      metadata: {
        'flow_name': _currentFlow!,
        'success': success,
        'reason': reason,
        'duration_seconds': duration.inSeconds,
      },
      category: 'user_journey',
    );
    
    _currentFlow = null;
    _flowStartTime = null;
  }
}

// Usage example
class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _journeyTracker = UserJourneyTracker();
  
  @override
  void initState() {
    super.initState();
    _journeyTracker.startFlow('checkout');
  }
  
  void _onAddressConfirmed() {
    _journeyTracker.trackFlowStep('address_confirmed');
    // Continue to payment
  }
  
  void _onPaymentCompleted() {
    _journeyTracker.trackFlowStep('payment_completed');
    _journeyTracker.completeFlow(success: true);
  }
}
```

## 🎯 User Interface Tracking

### Button Tracking

```dart
class TrackedButton extends StatelessWidget {
  final String buttonId;
  final VoidCallback? onPressed;
  final Widget child;
  final Map<String, dynamic>? additionalMetadata;
  
  const TrackedButton({
    Key? key,
    required this.buttonId,
    required this.onPressed,
    required this.child,
    this.additionalMetadata,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null ? null : () {
        // Track button press
        ObslySDK.instance.trackEvent(
          'button_pressed',
          metadata: {
            'button_id': buttonId,
            'screen': _getCurrentScreenName(context),
            'timestamp': DateTime.now().toIso8601String(),
            ...?additionalMetadata,
          },
          category: 'ui_interaction',
        );
        
        onPressed!();
      },
      child: child,
    );
  }
  
  String _getCurrentScreenName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name ?? 'unknown_screen';
  }
}

// Usage
TrackedButton(
  buttonId: 'login_submit',
  onPressed: () => _handleLogin(),
  additionalMetadata: {
    'auth_method': 'email',
    'remember_me': _rememberMe,
  },
  child: Text('Login'),
)
```

### Form Tracking

```dart
class TrackedForm extends StatefulWidget {
  final String formId;
  final Widget child;
  final VoidCallback? onSubmit;
  final List<String> fieldNames;
  
  const TrackedForm({
    Key? key,
    required this.formId,
    required this.child,
    required this.fieldNames,
    this.onSubmit,
  }) : super(key: key);
  
  @override
  _TrackedFormState createState() => _TrackedFormState();
}

class _TrackedFormState extends State<TrackedForm> {
  late DateTime _startTime;
  final Set<String> _interactedFields = {};
  final Map<String, int> _fieldInteractions = {};
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    ObslySDK.instance.trackEvent(
      'form_started',
      metadata: {
        'form_id': widget.formId,
        'field_count': widget.fieldNames.length,
        'start_time': _startTime.toIso8601String(),
      },
      category: 'form_interaction',
    );
  }
  
  void trackFieldInteraction(String fieldName) {
    _interactedFields.add(fieldName);
    _fieldInteractions[fieldName] = (_fieldInteractions[fieldName] ?? 0) + 1;
    
    ObslySDK.instance.trackEvent(
      'form_field_interaction',
      metadata: {
        'form_id': widget.formId,
        'field_name': fieldName,
        'interaction_count': _fieldInteractions[fieldName],
        'time_since_start': DateTime.now().difference(_startTime).inSeconds,
      },
      category: 'form_interaction',
    );
  }
  
  void _handleSubmit() {
    final completionTime = DateTime.now().difference(_startTime);
    
    ObslySDK.instance.trackEvent(
      'form_submitted',
      metadata: {
        'form_id': widget.formId,
        'completion_time_seconds': completionTime.inSeconds,
        'fields_interacted': _interactedFields.length,
        'total_interactions': _fieldInteractions.values.fold(0, (a, b) => a + b),
        'completion_rate': _interactedFields.length / widget.fieldNames.length,
      },
      category: 'form_interaction',
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

// Tracked text field
class TrackedTextFormField extends StatelessWidget {
  final String fieldName;
  final String? labelText;
  final Function(String)? onChanged;
  final Function()? onFieldInteracted;
  
  const TrackedTextFormField({
    Key? key,
    required this.fieldName,
    this.labelText,
    this.onChanged,
    this.onFieldInteracted,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: labelText),
      onTap: () => onFieldInteracted?.call(),
      onChanged: (value) {
        onFieldInteracted?.call();
        onChanged?.call(value);
      },
    );
  }
}
```

### Screen Navigation Tracking

```dart
class ScreenTracker extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreenView(route, 'push', previousRoute);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackScreenView(previousRoute, 'pop', route);
    }
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackScreenView(newRoute, 'replace', oldRoute);
    }
  }
  
  void _trackScreenView(
    Route<dynamic> route,
    String action,
    Route<dynamic>? previousRoute,
  ) {
    final routeName = route.settings.name ?? 'unknown';
    final previousRouteName = previousRoute?.settings.name;
    
    ObslySDK.instance.trackScreenView(
      routeName,
      metadata: {
        'action': action,
        'previous_screen': previousRouteName,
        'route_arguments': route.settings.arguments?.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

// Usage in MaterialApp
MaterialApp(
  navigatorObservers: [ScreenTracker()],
  // ... rest of app configuration
)
```

## 🌐 HTTP Monitoring

### Manual HTTP Tracking

```dart
class TrackedHttpClient {
  final http.Client _client = http.Client();
  
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _trackRequest('GET', url, headers: headers, body: null);
  }
  
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _trackRequest('POST', url, headers: headers, body: body);
  }
  
  Future<http.Response> _trackRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final stopwatch = Stopwatch()..start();
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Track request start
    ObslySDK.instance.trackEvent(
      'http_request_started',
      metadata: {
        'request_id': requestId,
        'method': method,
        'url': _sanitizeUrl(url.toString()),
        'has_body': body != null,
        'headers_count': headers?.length ?? 0,
      },
      category: 'network',
    );
    
    try {
      http.Response response;
      
      switch (method) {
        case 'GET':
          response = await _client.get(url, headers: headers);
          break;
        case 'POST':
          response = await _client.post(url, headers: headers, body: body);
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }
      
      stopwatch.stop();
      
      // Track successful response
      ObslySDK.instance.trackEvent(
        'http_request_completed',
        metadata: {
          'request_id': requestId,
          'method': method,
          'url': _sanitizeUrl(url.toString()),
          'status_code': response.statusCode,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'response_size': response.bodyBytes.length,
          'success': response.statusCode < 400,
        },
        category: 'network',
      );
      
      return response;
    } catch (error) {
      stopwatch.stop();
      
      // Track failed request
      ObslySDK.instance.trackError(
        error,
        category: 'network_error',
        metadata: {
          'request_id': requestId,
          'method': method,
          'url': _sanitizeUrl(url.toString()),
          'duration_ms': stopwatch.elapsedMilliseconds,
        },
      );
      
      rethrow;
    }
  }
  
  String _sanitizeUrl(String url) {
    // Remove sensitive parameters
    final uri = Uri.parse(url);
    final sanitizedQuery = uri.queryParameters.map(
      (key, value) => MapEntry(
        key,
        _isSensitiveParameter(key) ? '[FILTERED]' : value,
      ),
    );
    
    return uri.replace(queryParameters: sanitizedQuery).toString();
  }
  
  bool _isSensitiveParameter(String key) {
    const sensitiveKeys = ['token', 'key', 'secret', 'password', 'auth'];
    return sensitiveKeys.any((sensitive) => 
      key.toLowerCase().contains(sensitive));
  }
  
  void dispose() {
    _client.close();
  }
}
```

### API Service with Tracking

```dart
class ApiService {
  final TrackedHttpClient _httpClient = TrackedHttpClient();
  static const String baseUrl = 'https://api.example.com';
  
  Future<User> getUser(String userId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        
        // Track successful user fetch
        ObslySDK.instance.trackEvent(
          'user_data_fetched',
          metadata: {
            'user_id': userId,
            'user_type': user.type,
            'cache_hit': false,
          },
          category: 'data_access',
        );
        
        return user;
      } else {
        throw ApiException('Failed to fetch user: ${response.statusCode}');
      }
    } catch (error) {
      // Error already tracked by TrackedHttpClient
      rethrow;
    }
  }
  
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    // Track profile update attempt
    ObslySDK.instance.trackEvent(
      'profile_update_attempt',
      metadata: {
        'user_id': userId,
        'fields_updated': data.keys.toList(),
        'update_count': data.length,
      },
      category: 'user_action',
    );
    
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        // Track successful update
        ObslySDK.instance.trackEvent(
          'profile_updated',
          metadata: {
            'user_id': userId,
            'fields_updated': data.keys.toList(),
          },
          category: 'user_action',
        );
      } else {
        throw ApiException('Profile update failed: ${response.statusCode}');
      }
    } catch (error) {
      // Track update failure
      ObslySDK.instance.trackEvent(
        'profile_update_failed',
        metadata: {
          'user_id': userId,
          'error': error.toString(),
        },
        category: 'user_action',
      );
      rethrow;
    }
  }
}
```

## 🚨 Error Handling

### Global Error Handler

```dart
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
    ObslySDK.instance.trackError(
      details.exception,
      stackTrace: details.stack,
      category: 'flutter_framework',
      metadata: {
        'library': details.library,
        'context': details.context?.toString(),
        'widget': details.informationCollector?.call()?.toString(),
        'silent': details.silent,
      },
      fatal: false,
    );
  }
  
  static void _handleAsyncError(Object error, StackTrace stack) {
    ObslySDK.instance.trackError(
      error,
      stackTrace: stack,
      category: 'async_error',
      fatal: false,
    );
  }
}
```

### Error Boundary Widget

```dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;
  final Function(Object error, StackTrace? stackTrace)? onError;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);
  
  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? 
        _DefaultErrorWidget(error: _error!);
    }
    
    return ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _error = details.exception;
        });
        
        // Track error
        ObslySDK.instance.trackError(
          details.exception,
          stackTrace: details.stack,
          category: 'widget_error',
          metadata: {
            'widget': widget.child.runtimeType.toString(),
            'library': details.library,
          },
        );
        
        widget.onError?.call(details.exception, details.stack);
      });
      
      return widget.child;
    };
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  
  const _DefaultErrorWidget({required this.error});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### Custom Exception Tracking

```dart
class BusinessLogicException implements Exception {
  final String message;
  final String category;
  final Map<String, dynamic>? metadata;
  
  BusinessLogicException(
    this.message, {
    required this.category,
    this.metadata,
  });
  
  @override
  String toString() => 'BusinessLogicException: $message';
}

class BusinessService {
  Future<void> processPayment(Payment payment) async {
    try {
      // Validate payment
      if (payment.amount <= 0) {
        throw BusinessLogicException(
          'Invalid payment amount',
          category: 'validation_error',
          metadata: {
            'payment_id': payment.id,
            'amount': payment.amount,
            'currency': payment.currency,
          },
        );
      }
      
      // Process payment logic
      await _processPaymentInternal(payment);
      
      // Track successful payment
      ObslySDK.instance.trackEvent(
        'payment_processed',
        metadata: {
          'payment_id': payment.id,
          'amount': payment.amount,
          'currency': payment.currency,
          'method': payment.method,
        },
        category: 'business_event',
      );
      
    } on BusinessLogicException catch (e) {
      // Track business logic error
      ObslySDK.instance.trackError(
        e,
        category: e.category,
        metadata: e.metadata,
        fatal: false,
      );
      rethrow;
    } catch (error, stackTrace) {
      // Track unexpected error
      ObslySDK.instance.trackError(
        error,
        stackTrace: stackTrace,
        category: 'payment_processing',
        metadata: {
          'payment_id': payment.id,
          'amount': payment.amount,
        },
        fatal: false,
      );
      rethrow;
    }
  }
}
```

## 🔐 Authentication Flows

### Login Tracking

```dart
class AuthService {
  Future<User> login(String email, String password) async {
    final loginAttemptId = DateTime.now().millisecondsSinceEpoch.toString();
    final startTime = DateTime.now();
    
    // Track login attempt
    ObslySDK.instance.trackEvent(
      'login_attempt',
      metadata: {
        'attempt_id': loginAttemptId,
        'email_domain': _getEmailDomain(email),
        'auth_method': 'email_password',
        'timestamp': startTime.toIso8601String(),
      },
      category: 'authentication',
    );
    
    try {
      // Perform authentication
      final response = await _performLogin(email, password);
      final duration = DateTime.now().difference(startTime);
      
      if (response.success) {
        final user = response.user;
        
        // Track successful login
        ObslySDK.instance.trackEvent(
          'login_success',
          metadata: {
            'attempt_id': loginAttemptId,
            'user_id': user.id,
            'user_type': user.type,
            'duration_ms': duration.inMilliseconds,
            'session_id': user.sessionId,
          },
          category: 'authentication',
        );
        
        // Start user session
        await ObslySDK.instance.startSession(
          userId: user.id,
          metadata: {
            'user_type': user.type,
            'login_method': 'email_password',
          },
        );
        
        return user;
      } else {
        // Track login failure
        ObslySDK.instance.trackEvent(
          'login_failed',
          metadata: {
            'attempt_id': loginAttemptId,
            'failure_reason': response.errorMessage,
            'duration_ms': duration.inMilliseconds,
          },
          category: 'authentication',
        );
        
        throw AuthException(response.errorMessage);
      }
    } catch (error, stackTrace) {
      // Track login error
      ObslySDK.instance.trackError(
        error,
        stackTrace: stackTrace,
        category: 'authentication_error',
        metadata: {
          'attempt_id': loginAttemptId,
          'email_domain': _getEmailDomain(email),
        },
      );
      rethrow;
    }
  }
  
  Future<void> logout() async {
    // Track logout
    ObslySDK.instance.trackEvent(
      'logout',
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
      },
      category: 'authentication',
    );
    
    // End session
    await ObslySDK.instance.endSession();
    
    // Clear user data
    await _clearUserData();
  }
  
  String _getEmailDomain(String email) {
    return email.split('@').last;
  }
}
```

### Biometric Authentication

```dart
class BiometricAuthService {
  Future<bool> authenticateWithBiometrics() async {
    final authAttemptId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Check biometric availability
    final isAvailable = await _checkBiometricAvailability();
    
    ObslySDK.instance.trackEvent(
      'biometric_auth_attempt',
      metadata: {
        'attempt_id': authAttemptId,
        'biometric_available': isAvailable,
        'device_type': Platform.isIOS ? 'ios' : 'android',
      },
      category: 'biometric_auth',
    );
    
    if (!isAvailable) {
      ObslySDK.instance.trackEvent(
        'biometric_auth_unavailable',
        metadata: {
          'attempt_id': authAttemptId,
          'reason': 'not_enrolled_or_unsupported',
        },
        category: 'biometric_auth',
      );
      return false;
    }
    
    try {
      final result = await _performBiometricAuth();
      
      ObslySDK.instance.trackEvent(
        result ? 'biometric_auth_success' : 'biometric_auth_failed',
        metadata: {
          'attempt_id': authAttemptId,
        },
        category: 'biometric_auth',
      );
      
      return result;
    } catch (error, stackTrace) {
      ObslySDK.instance.trackError(
        error,
        stackTrace: stackTrace,
        category: 'biometric_auth_error',
        metadata: {
          'attempt_id': authAttemptId,
        },
      );
      return false;
    }
  }
}
```

## 🛒 E-commerce Tracking

### Shopping Cart Events

```dart
class ShoppingCartService {
  final List<CartItem> _items = [];
  
  void addItem(Product product, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity: quantity,
      ));
    }
    
    // Track add to cart
    ObslySDK.instance.trackEvent(
      'add_to_cart',
      metadata: {
        'product_id': product.id,
        'product_name': product.name,
        'product_category': product.category,
        'price': product.price,
        'quantity': quantity,
        'cart_total_items': _items.length,
        'cart_total_value': _getTotalValue(),
      },
      category: 'e_commerce',
    );
  }
  
  void removeItem(String productId) {
    final removedItem = _items.firstWhere((item) => item.productId == productId);
    _items.removeWhere((item) => item.productId == productId);
    
    // Track remove from cart
    ObslySDK.instance.trackEvent(
      'remove_from_cart',
      metadata: {
        'product_id': productId,
        'product_name': removedItem.name,
        'price': removedItem.price,
        'quantity': removedItem.quantity,
        'cart_total_items': _items.length,
        'cart_total_value': _getTotalValue(),
      },
      category: 'e_commerce',
    );
  }
  
  void viewCart() {
    ObslySDK.instance.trackEvent(
      'view_cart',
      metadata: {
        'cart_items_count': _items.length,
        'cart_total_value': _getTotalValue(),
        'items': _items.map((item) => {
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
      },
      category: 'e_commerce',
    );
  }
  
  Future<void> checkout() async {
    final checkoutId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Track checkout started
    ObslySDK.instance.trackEvent(
      'checkout_started',
      metadata: {
        'checkout_id': checkoutId,
        'items_count': _items.length,
        'total_value': _getTotalValue(),
        'items': _items.map((item) => {
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
      },
      category: 'e_commerce',
    );
    
    try {
      // Process checkout
      final order = await _processCheckout();
      
      // Track purchase
      ObslySDK.instance.trackEvent(
        'purchase',
        metadata: {
          'checkout_id': checkoutId,
          'order_id': order.id,
          'total_value': order.totalAmount,
          'currency': order.currency,
          'payment_method': order.paymentMethod,
          'items_count': order.items.length,
          'discount_amount': order.discountAmount,
          'shipping_cost': order.shippingCost,
          'items': order.items.map((item) => {
            'product_id': item.productId,
            'quantity': item.quantity,
            'price': item.price,
          }).toList(),
        },
        category: 'e_commerce',
      );
      
      // Clear cart
      _items.clear();
      
    } catch (error, stackTrace) {
      // Track checkout failure
      ObslySDK.instance.trackError(
        error,
        stackTrace: stackTrace,
        category: 'checkout_error',
        metadata: {
          'checkout_id': checkoutId,
          'items_count': _items.length,
          'total_value': _getTotalValue(),
        },
      );
      rethrow;
    }
  }
  
  double _getTotalValue() {
    return _items.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }
}
```

### Product View Tracking

```dart
class ProductService {
  Future<Product> getProduct(String productId) async {
    final startTime = DateTime.now();
    
    try {
      final product = await _fetchProduct(productId);
      final loadTime = DateTime.now().difference(startTime);
      
      // Track product view
      ObslySDK.instance.trackEvent(
        'product_viewed',
        metadata: {
          'product_id': product.id,
          'product_name': product.name,
          'product_category': product.category,
          'price': product.price,
          'availability': product.inStock ? 'in_stock' : 'out_of_stock',
          'load_time_ms': loadTime.inMilliseconds,
          'view_source': 'product_page',
        },
        category: 'e_commerce',
      );
      
      return product;
    } catch (error, stackTrace) {
      ObslySDK.instance.trackError(
        error,
        stackTrace: stackTrace,
        category: 'product_loading_error',
        metadata: {
          'product_id': productId,
          'load_time_ms': DateTime.now().difference(startTime).inMilliseconds,
        },
      );
      rethrow;
    }
  }
  
  Future<List<Product>> searchProducts(String query) async {
    final searchId = DateTime.now().millisecondsSinceEpoch.toString();
    
    ObslySDK.instance.trackEvent(
      'product_search',
      metadata: {
        'search_id': searchId,
        'query': query,
        'query_length': query.length,
      },
      category: 'search',
    );
    
    try {
      final results = await _performSearch(query);
      
      ObslySDK.instance.trackEvent(
        'search_results',
        metadata: {
          'search_id': searchId,
          'query': query,
          'results_count': results.length,
          'has_results': results.isNotEmpty,
        },
        category: 'search',
      );
      
      return results;
    } catch (error, stackTrace) {
      ObslySDK.instance.trackError(
        error,
        stackTrace: stackTrace,
        category: 'search_error',
        metadata: {
          'search_id': searchId,
          'query': query,
        },
      );
      rethrow;
    }
  }
}
```

## 📊 Performance Monitoring

### App Launch Tracking

```dart
class AppPerformanceTracker {
  static DateTime? _appStartTime;
  static DateTime? _frameworkInitTime;
  static DateTime? _firstFrameTime;
  
  static void markAppStart() {
    _appStartTime = DateTime.now();
  }
  
  static void markFrameworkInit() {
    _frameworkInitTime = DateTime.now();
    
    if (_appStartTime != null) {
      final frameworkInitDuration = _frameworkInitTime!.difference(_appStartTime!);
      
      ObslySDK.instance.trackEvent(
        'app_framework_init',
        metadata: {
          'duration_ms': frameworkInitDuration.inMilliseconds,
        },
        category: 'performance',
      );
    }
  }
  
  static void markFirstFrame() {
    _firstFrameTime = DateTime.now();
    
    if (_appStartTime != null && _frameworkInitTime != null) {
      final totalLaunchTime = _firstFrameTime!.difference(_appStartTime!);
      final firstFrameDuration = _firstFrameTime!.difference(_frameworkInitTime!);
      
      ObslySDK.instance.trackEvent(
        'app_launch_complete',
        metadata: {
          'total_launch_time_ms': totalLaunchTime.inMilliseconds,
          'first_frame_duration_ms': firstFrameDuration.inMilliseconds,
          'cold_start': true, // You can determine this based on app state
        },
        category: 'performance',
      );
    }
  }
}

// Usage in main.dart
void main() {
  AppPerformanceTracker.markAppStart();
  
  WidgetsFlutterBinding.ensureInitialized();
  AppPerformanceTracker.markFrameworkInit();
  
  // ... SDK initialization ...
  
  runApp(MyApp());
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AppPerformanceTracker.markFirstFrame();
  });
}
```

### Screen Render Performance

```dart
class ScreenPerformanceTracker extends StatefulWidget {
  final Widget child;
  final String screenName;
  
  const ScreenPerformanceTracker({
    Key? key,
    required this.child,
    required this.screenName,
  }) : super(key: key);
  
  @override
  _ScreenPerformanceTrackerState createState() => 
    _ScreenPerformanceTrackerState();
}

class _ScreenPerformanceTrackerState extends State<ScreenPerformanceTracker>
    with WidgetsBindingObserver {
  late DateTime _screenStartTime;
  DateTime? _firstPaintTime;
  int _frameCount = 0;
  List<int> _frameDurations = [];
  
  @override
  void initState() {
    super.initState();
    _screenStartTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firstPaintTime = DateTime.now();
      _trackFirstPaint();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trackScreenPerformance();
    super.dispose();
  }
  
  void _trackFirstPaint() {
    if (_firstPaintTime != null) {
      final renderTime = _firstPaintTime!.difference(_screenStartTime);
      
      ObslySDK.instance.trackEvent(
        'screen_first_paint',
        metadata: {
          'screen_name': widget.screenName,
          'render_time_ms': renderTime.inMilliseconds,
        },
        category: 'performance',
      );
    }
  }
  
  void _trackScreenPerformance() {
    if (_frameDurations.isNotEmpty) {
      final avgFrameTime = _frameDurations.reduce((a, b) => a + b) / 
        _frameDurations.length;
      final maxFrameTime = _frameDurations.reduce((a, b) => a > b ? a : b);
      final fps = 1000 / avgFrameTime;
      
      ObslySDK.instance.trackEvent(
        'screen_performance',
        metadata: {
          'screen_name': widget.screenName,
          'total_frames': _frameCount,
          'avg_frame_time_ms': avgFrameTime,
          'max_frame_time_ms': maxFrameTime,
          'estimated_fps': fps,
          'session_duration_ms': DateTime.now().difference(_screenStartTime).inMilliseconds,
        },
        category: 'performance',
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

## 🎨 Custom Widgets

### Debug Widget

```dart
class ObslyDebugWidget extends StatefulWidget {
  @override
  _ObslyDebugWidgetState createState() => _ObslyDebugWidgetState();
}

class _ObslyDebugWidgetState extends State<ObslyDebugWidget> {
  List<Event> _recentEvents = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadRecentEvents();
  }
  
  Future<void> _loadRecentEvents() async {
    setState(() => _isLoading = true);
    
    try {
      final events = await ObslySDK.instance.getRecentEvents(limit: 50);
      setState(() => _recentEvents = events);
    } catch (error) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Obsly Debug'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRecentEvents,
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearEvents,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        _buildStatusCard(),
        Expanded(child: _buildEventsList()),
      ],
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SDK Status', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  ObslySDK.instance.isInitialized ? Icons.check_circle : Icons.error,
                  color: ObslySDK.instance.isInitialized ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(ObslySDK.instance.isInitialized ? 'Initialized' : 'Not Initialized'),
              ],
            ),
            SizedBox(height: 8),
            Text('Events: ${_recentEvents.length}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventsList() {
    return ListView.builder(
      itemCount: _recentEvents.length,
      itemBuilder: (context, index) {
        final event = _recentEvents[index];
        return ExpansionTile(
          title: Text(event.name),
          subtitle: Text(event.timestamp.toString()),
          children: [
            if (event.category != null)
              ListTile(
                title: Text('Category'),
                subtitle: Text(event.category!),
              ),
            if (event.metadata != null)
              ListTile(
                title: Text('Metadata'),
                subtitle: Text(event.metadata.toString()),
              ),
          ],
        );
      },
    );
  }
  
  Future<void> _clearEvents() async {
    await ObslySDK.instance.clearEvents();
    await _loadRecentEvents();
  }
}
```

## 🔄 Advanced Patterns

### Batch Event Processing

```dart
class BatchEventProcessor {
  final List<Map<String, dynamic>> _eventQueue = [];
  final int _batchSize;
  final Duration _flushInterval;
  Timer? _flushTimer;
  
  BatchEventProcessor({
    int batchSize = 10,
    Duration flushInterval = const Duration(seconds: 30),
  }) : _batchSize = batchSize,
       _flushInterval = flushInterval;
  
  void queueEvent(String eventName, Map<String, dynamic>? metadata) {
    _eventQueue.add({
      'name': eventName,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    if (_eventQueue.length >= _batchSize) {
      _flushEvents();
    } else {
      _scheduleFlush();
    }
  }
  
  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushInterval, _flushEvents);
  }
  
  void _flushEvents() {
    if (_eventQueue.isEmpty) return;
    
    final eventsToProcess = List<Map<String, dynamic>>.from(_eventQueue);
    _eventQueue.clear();
    _flushTimer?.cancel();
    
    // Process all events
    for (final event in eventsToProcess) {
      ObslySDK.instance.trackEvent(
        event['name'],
        metadata: event['metadata'],
      );
    }
  }
  
  void dispose() {
    _flushTimer?.cancel();
    _flushEvents(); // Flush remaining events
  }
}
```

### Event Deduplication

```dart
class DedupEventTracker {
  final Map<String, DateTime> _recentEvents = {};
  final Duration _dedupWindow;
  
  DedupEventTracker({
    this.dedupWindow = const Duration(seconds: 5),
  });
  
  Future<void> trackEventWithDedup(
    String eventName, {
    Map<String, dynamic>? metadata,
    String? category,
  }) async {
    final now = DateTime.now();
    final eventKey = _generateEventKey(eventName, metadata);
    
    // Check if this event was recently sent
    if (_recentEvents.containsKey(eventKey)) {
      final lastSent = _recentEvents[eventKey]!;
      if (now.difference(lastSent) < _dedupWindow) {
        // Skip duplicate event
        return;
      }
    }
    
    // Track the event
    await ObslySDK.instance.trackEvent(
      eventName,
      metadata: metadata,
      category: category,
    );
    
    // Record the event
    _recentEvents[eventKey] = now;
    
    // Clean up old entries
    _cleanupOldEvents(now);
  }
  
  String _generateEventKey(String eventName, Map<String, dynamic>? metadata) {
    // Create a unique key based on event name and relevant metadata
    final keyMetadata = metadata?.entries
        .where((e) => ['button_id', 'screen', 'action'].contains(e.key))
        .map((e) => '${e.key}:${e.value}')
        .join('|') ?? '';
    
    return '$eventName|$keyMetadata';
  }
  
  void _cleanupOldEvents(DateTime now) {
    _recentEvents.removeWhere((key, timestamp) => 
        now.difference(timestamp) > _dedupWindow);
  }
}
```

---

## 📞 Support

For more examples and help:

- 📖 [Setup Guide](SETUP.md)
- 🔧 [Integration Guide](INTEGRATION_GUIDE.md)
- 📋 [API Reference](API_REFERENCE.md)
- 💬 [Community Discord](https://discord.gg/obsly)

**Happy coding! 🚀**
