import 'package:obsly_flutter/models/obsly_config.dart';

/// Example configuration showing how to enable developer logging
/// in the Obsly SDK for debugging purposes
class ObslyDeveloperConfig {
  /// Production configuration - minimal logging
  static ObslyConfig get production => const ObslyConfig(
        enableDebugTools: false,
      );

  /// Development configuration - enhanced logging for developers
  static ObslyConfig get development => const ObslyConfig(
        enableDebugTools: true,
        // HTTP interceptor settings for debugging
        captureBodyOnError: true,
        bufferSize: 500,
        messengerInterval: 30, // More frequent sends for testing
      );

  /// Testing configuration - full logging for QA
  static ObslyConfig get testing => const ObslyConfig(
        enableDebugTools: true,
        captureBodyOnError: true,
        bufferSize: 1000,
        messengerInterval: 10, // Immediate sends for testing
      );

  /// Debug configuration - maximum logging for troubleshooting
  static ObslyConfig get debug => const ObslyConfig(
        enableDebugTools: true,
        captureBodyOnError: true,
        bufferSize: 2000,
        messengerInterval: 10, // Minimum allowed is 10 seconds
      );

  /// Get configuration based on build mode
  static ObslyConfig getConfigForEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'production':
      case 'prod':
        return production;
      case 'development':
      case 'dev':
        return development;
      case 'testing':
      case 'test':
        return testing;
      case 'debug':
        return debug;
      default:
        return development; // Default to development
    }
  }
}

/// Example of how to configure Obsly with developer logging in main.dart:
/// 
/// ```dart
/// import 'package:flutter/foundation.dart';
/// import 'config/obsly_developer_config.dart';
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // Configure Obsly based on build mode
///   final config = kDebugMode 
///     ? ObslyDeveloperConfig.debug 
///     : ObslyDeveloperConfig.production;
///   
///   await ObslySDK.initialize(config);
///   
///   // Enable developer mode if in debug build
///   if (kDebugMode) {
///     ObslyLogger.enableDeveloperMode();
///   }
///   
///   runApp(MyApp());
/// }
/// ```
/// 
/// ## Available Logging Features:
/// 
/// ### 1. **Verbose Logging**
/// - Logs all SDK operations (HTTP, UI, Storage, Rules)
/// - Includes timing information and data flow details
/// - Can be enabled via config or debug panel
/// 
/// ### 2. **Stack Traces**
/// - Shows full stack traces on all errors
/// - Helps identify exact error locations
/// - Includes context information for debugging
/// 
/// ### 3. **Enhanced Error Context**
/// - Errors include component and operation information
/// - Additional context data (state, parameters, etc.)
/// - Circuit breaker status and fallback information
/// 
/// ### 4. **Rules Execution Logging**
/// - Detailed logging of rule evaluation steps
/// - Variable assignments and context access
/// - Performance metrics for rule execution
/// 
/// ### 5. **HTTP Logging**
/// - Request/response details with timing
/// - Body capture on error responses
/// - Network error details and retry logic
/// 
/// ### 6. **UI Event Logging**
/// - User interaction details
/// - Widget path and action information
/// - Event metadata and context
/// 
/// ### 7. **Storage Logging**
/// - Database operations with performance metrics
/// - Storage stats and cleanup operations
/// - Event persistence and retrieval details
/// 
/// ## Debug Panel Controls:
/// 
/// Access the debug panel by using the Obsly debug tools:
/// - **Verbose Logging Toggle**: Enable/disable detailed logging
/// - **Stack Traces Toggle**: Enable/disable full stack traces
/// - **Developer Mode Button**: Enable all debugging features
/// - **Current Log Level Display**: Shows active logging level
/// 
/// ## Performance Considerations:
/// 
/// - Verbose logging has minimal performance impact
/// - Stack traces add slight overhead on errors
/// - Consider disabling in production for optimal performance
/// - Use debug builds for development and testing
/// 
/// ## Troubleshooting Common Issues:
/// 
/// 1. **Rules not executing**: Enable verbose logging to see evaluation details
/// 2. **HTTP errors**: Check network logging for request/response details
/// 3. **UI events not captured**: Verify UI integration and event logging
/// 4. **Storage issues**: Monitor storage logging for database operations
/// 5. **Performance problems**: Use stack traces to identify bottlenecks
