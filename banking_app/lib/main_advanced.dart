import 'package:banking_app/config/obsly_developer_config.dart';
import 'package:banking_app/screens/dashboard_screen.dart';
import 'package:banking_app/screens/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obsly_flutter/interceptors/rules_integration.dart';
import 'package:obsly_flutter/obsly_sdk.dart';
import 'package:obsly_flutter/rules/obsly_flutter_rules.dart' hide Colors;

/// Example main.dart showing how to use enhanced developer logging
/// with the Obsly SDK for debugging and development purposes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Obsly based on build mode with enhanced logging
  final config = _getObslyConfig();
  // Enable developer mode in debug builds
  if (kDebugMode) {
    print('🚀 Debug mode detected - enabling developer logging');
    ObslyLogger.enableDeveloperMode(
      level: LogLevel.verbose,
    );
  }

  // Initialize Rules Engine FIRST (before SDK)
  await _initializeRulesEngine();

  // Initialize Obsly SDK with enhanced configuration
  await _initializeObslySDK(config);

  // Run the app with logging
  ObslyLogger.log('🚀 Starting Banking App with enhanced developer logging');
  runApp(const MyApp());
}

/// Get Obsly configuration based on environment
ObslyConfig _getObslyConfig() {
  if (kDebugMode) {
    // Debug build - maximum logging
    ObslyLogger.log('🔧 Debug build detected, using debug configuration');
    return ObslyDeveloperConfig.debug;
  } else if (kProfileMode) {
    // Profile build - testing configuration
    ObslyLogger.log('🧪 Profile build detected, using testing configuration');
    return ObslyDeveloperConfig.testing;
  } else {
    // Release build - production configuration
    ObslyLogger.log(
        '🏭 Release build detected, using production configuration');
    return ObslyDeveloperConfig.production;
  }
}

/// Initialize Rules Engine with enhanced error handling
Future<void> _initializeRulesEngine() async {
  ObslyLogger.log('🔄 Starting Rules Engine initialization...');

  try {
    ObslyLogger.verbose('📦 Attempting to initialize RulesController...');
    final rulesController = await RulesController.initialize();

    ObslyLogger.log(
        '🎯 RulesController created: ${rulesController.runtimeType}');
    ObslyLogger.verbose(
        '🔍 Rules engine isActive: ${rulesController.isActive}');

    // Register the controller with the SDK
    ObslyLogger.verbose('🔗 Registering rules controller with SDK...');
    RulesIntegration.registerRulesController(rulesController);

    ObslyLogger.log(
        '✅ Rules engine initialized successfully: ${rulesController.isActive ? 'ACTIVE' : 'INACTIVE'}');

    // Verify state after registration
    ObslyLogger.verbose(
        '🔍 RulesIntegration isAvailable after registration: ${RulesIntegration.instance.isAvailable}');
  } catch (e, stackTrace) {
    ObslyLogger.errorWithContext(
      'RulesEngineInit',
      'initialize',
      'Rules engine initialization failed: $e',
      stackTrace,
      context: {
        'initializationType': 'RulesController',
        'hasRulesController': 'false',
      },
    );
  }
}

/// Initialize Obsly SDK with enhanced configuration
Future<void> _initializeObslySDK(ObslyConfig config) async {
  ObslyLogger.log('🔄 Starting Obsly SDK initialization...');

  try {
    // Convert new config to old InitParameters format
    // This is a bridge until the SDK is fully updated
    await ObslySDK.instance.init(
      InitParameters(
        obslyKey:
            'YOUR_OBSLY_API_KEY_HERE', // Replace with your actual Obsly API key
        instanceURL: 'https://api.int.obsly.io',
        debugMode: config.enableDebugTools ?? false,
        logLevel: LogLevel.debug,
        config: ObslyConfig(
          enableDebugTools: config.enableDebugTools,
          enableScreenshotOnUi: true,
          captureBodyOnError: config.captureBodyOnError,
          bufferSize: config.bufferSize,
          messengerInterval: config.messengerInterval,
          rageClick: const RageClickConfig(
            active: true,
            screenshot: true,
            screenshotPercent: 0.25,
          ),
        ),
      ),
    );

    ObslyLogger.log('✅ Obsly SDK initialized successfully');

    // Log current logging configuration
    ObslyLogger.verbose('📊 Current logging configuration:');
    ObslyLogger.verbose('   - Log Level: ${ObslyLogger.currentLevelString}');
    ObslyLogger.verbose('   - Debug Tools: ${config.enableDebugTools}');
  } catch (e, stackTrace) {
    ObslyLogger.errorWithContext(
      'ObslySDKInit',
      'initialize',
      'Obsly SDK initialization failed: $e',
      stackTrace,
      context: {
        'configType': config.runtimeType.toString(),
        'debugMode': config.enableDebugTools.toString(),
        'logLevel': LogLevel.debug,
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bankingApp = MaterialApp(
      title: 'Banking App - Developer Mode',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
      // Enhanced error handling with developer logging
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          // Log the error with context
          ObslyLogger.errorWithContext(
            'FlutterErrorWidget',
            'build',
            'Flutter widget error: ${details.exception}',
            details.stack,
            context: {
              'widget': details.library,
              'errorType': details.exception.runtimeType.toString(),
            },
          );

          // Return custom error widget in debug mode
          if (kDebugMode) {
            return _buildDeveloperErrorWidget(details);
          }

          // Fallback for production
          return const SizedBox.shrink();
        };

        return child ?? const SizedBox.shrink();
      },
    );

    // Wrap app with Obsly SDK for automatic capture
    return ObslySDK.instance.wrapApp(
      app: bankingApp,
      // Only enable in debug builds
    );
  }

  /// Custom error widget for developers with enhanced information
  Widget _buildDeveloperErrorWidget(FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Developer Error',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${details.exception}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (details.stack != null) ...[
                  const Text(
                    'Stack Trace:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          details.stack.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Example of how to programmatically enable developer mode:
///
/// ```dart
/// // Enable developer mode at runtime
/// void enableDeveloperMode() {
///   ObslyLogger.enableDeveloperMode(
///     level: LogLevel.verbose,
///     verbose: true,
///     stackTraces: true,
///   );
/// }
///
/// // Custom configuration for specific scenarios
/// void configureForTesting() {
///   ObslyLogger.setLevel(LogLevel.verbose);
///   ObslyLogger.setVerboseEnabled(true);
///   ObslyLogger.setStackTraceEnabled(true);
/// }
///
/// // Disable all logging for production
/// void configureForProduction() {
///   ObslyLogger.setLevel(LogLevel.error);
///   ObslyLogger.setVerboseEnabled(false);
///   ObslyLogger.setStackTraceEnabled(false);
/// }
/// ```
