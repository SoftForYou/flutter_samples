# Advanced Features - Obsly Flutter Library

## Table of Contents

- [Rules Engine System](#rules-engine-system)
- [Event Interception System](#event-interception-system)
- [Remote Configuration System](#remote-configuration-system)
- [Advanced Event Processing](#advanced-event-processing)
- [Performance Optimization](#performance-optimization)
- [Advanced Session Management](#advanced-session-management)
- [Security & Privacy](#security--privacy)
- [Multi-Environment Setup](#multi-environment-setup)
- [Screen Timing Measurements](#screen-timing-measurements)
- [Advanced Testing](#advanced-testing)

## Rules Engine System

The Obsly library includes a powerful rules engine that enables dynamic event processing, filtering, and transformation without requiring app updates.

### Core Concepts

#### Rule Types

1. **Filter Rules**: Include or exclude events based on conditions
2. **Transform Rules**: Modify event data and add metadata
3. **Alert Rules**: Generate notifications and alerts
4. **Routing Rules**: Direct events to different destinations

#### Rule Structure

```dart
class Rule {
  final String id;
  final String name;
  final String condition;          // JavaScript-like expression
  final List<RuleAction> actions;  // Actions to execute
  final bool enabled;
  final Map<String, dynamic>? metadata;
}
```

### Basic Rule Examples

#### Filter Rule - Exclude Test Events

```dart
final filterTestRule = Rule(
  id: 'filter_test_events',
  name: 'Filter Test Environment Events',
  condition: '''
    event.metadata && 
    event.metadata.environment === "test"
  ''',
  actions: [
    ExcludeAction(), // Exclude matching events
  ],
  enabled: true,
);

await ObslySDK.instance.addRule(filterTestRule);
```

#### Alert Rule - Critical Errors

```dart
final criticalErrorRule = Rule(
  id: 'critical_error_alert',
  name: 'Critical Error Detection',
  condition: '''
    event.type === "crash" || 
    (event.type === "error" && event.severity === "critical")
  ''',
  actions: [
    AlertAction(
      severity: 'high',
      message: 'Critical error detected in ${event.screen}',
      channels: ['email', 'slack'],
      metadata: {
        'error_type': '${event.type}',
        'user_id': '${event.userId}',
      },
    ),
    TransformAction(
      addMetadata: {
        'alert_triggered': true,
        'alert_timestamp': '${now()}',
      },
    ),
  ],
  enabled: true,
);
```

#### Transform Rule - Enrich User Events

```dart
final enrichUserRule = Rule(
  id: 'enrich_user_events',
  name: 'Enrich User Interaction Events',
  condition: '''
    event.type === "ui" && 
    event.userId != null
  ''',
  actions: [
    TransformAction(
      addMetadata: {
        'user_segment': '${getUserSegment(event.userId)}',
        'session_duration_minutes': '${getSessionDuration()}',
        'is_premium_user': '${isPremiumUser(event.userId)}',
      },
    ),
  ],
  enabled: true,
);
```

### Advanced Rule Patterns

#### Business Logic Rules

```dart
// E-commerce: Track high-value transactions
final highValueTransactionRule = Rule(
  id: 'high_value_transaction',
  name: 'High Value Transaction Alert',
  condition: '''
    event.type === "purchase" && 
    event.metadata.amount > 1000
  ''',
  actions: [
    AlertAction(
      severity: 'medium',
      message: 'High value transaction: $${event.metadata.amount}',
      channels: ['webhook'],
    ),
    TransformAction(
      addMetadata: {
        'high_value': true,
        'requires_review': true,
      },
    ),
  ],
);

// Banking: Detect suspicious login patterns
final suspiciousLoginRule = Rule(
  id: 'suspicious_login_pattern',
  name: 'Detect Suspicious Login Patterns',
  condition: '''
    event.type === "login_attempt" && 
    (event.metadata.failed_attempts > 3 || 
     event.metadata.new_device === true)
  ''',
  actions: [
    AlertAction(
      severity: 'high',
      message: 'Suspicious login detected for user ${event.userId}',
      channels: ['security_team'],
    ),
    TransformAction(
      addMetadata: {
        'security_flag': 'suspicious_login',
        'review_required': true,
      },
    ),
  ],
);
```

#### Performance Monitoring Rules

```dart
// Detect slow API responses
final slowApiRule = Rule(
  id: 'slow_api_response',
  name: 'Slow API Response Detection',
  condition: '''
    event.type === "http" && 
    event.metadata.duration_ms > 5000
  ''',
  actions: [
    AlertAction(
      severity: 'medium',
      message: 'Slow API response: ${event.metadata.url} (${event.metadata.duration_ms}ms)',
    ),
    TransformAction(
      addMetadata: {
        'performance_issue': 'slow_response',
        'needs_optimization': true,
      },
    ),
  ],
);

// Memory usage alerts
final highMemoryRule = Rule(
  id: 'high_memory_usage',
  name: 'High Memory Usage Alert',
  condition: '''
    event.type === "performance" && 
    event.metadata.memory_usage_mb > 500
  ''',
  actions: [
    AlertAction(
      severity: 'medium',
      message: 'High memory usage detected: ${event.metadata.memory_usage_mb}MB',
    ),
  ],
);
```

### Rule Management

#### Dynamic Rule Updates

```dart
class RulesManager {
  // Add new rule
  static Future<void> addRule(Rule rule) async {
    await ObslySDK.instance.addRule(rule);
    print('✅ Rule added: ${rule.name}');
  }

  // Update existing rule
  static Future<void> updateRule(String ruleId, Rule newRule) async {
    await ObslySDK.instance.updateRule(ruleId, newRule);
    print('✅ Rule updated: ${newRule.name}');
  }

  // Enable/disable rule
  static Future<void> toggleRule(String ruleId, bool enabled) async {
    await ObslySDK.instance.setRuleEnabled(ruleId, enabled);
    print('✅ Rule ${enabled ? "enabled" : "disabled"}: $ruleId');
  }

  // Remove rule
  static Future<void> removeRule(String ruleId) async {
    await ObslySDK.instance.deleteRule(ruleId);
    print('✅ Rule removed: $ruleId');
  }

  // Get all rules
  static Future<List<Rule>> getAllRules() async {
    return await ObslySDK.instance.getRules();
  }
}
```

#### Conditional Rule Activation

```dart
class ConditionalRulesService {
  static Future<void> setupEnvironmentRules() async {
    final isProduction = const bool.fromEnvironment('dart.vm.product');
    
    if (isProduction) {
      // Production-only rules
      await _activateProductionRules();
    } else {
      // Development-only rules
      await _activateDevelopmentRules();
    }
  }

  static Future<void> _activateProductionRules() async {
    // Strict error monitoring
    await RulesManager.addRule(Rule(
      id: 'prod_error_monitoring',
      name: 'Production Error Monitoring',
      condition: 'event.type === "error" || event.type === "crash"',
      actions: [
        AlertAction(
          severity: 'high',
          channels: ['production_alerts'],
        ),
      ],
    ));

    // Performance monitoring
    await RulesManager.addRule(Rule(
      id: 'prod_performance_monitoring',
      name: 'Production Performance Monitoring',
      condition: 'event.type === "performance" && event.metadata.duration_ms > 3000',
      actions: [
        AlertAction(
          severity: 'medium',
          channels: ['performance_team'],
        ),
      ],
    ));
  }

  static Future<void> _activateDevelopmentRules() async {
    // Debug information enhancement
    await RulesManager.addRule(Rule(
      id: 'dev_debug_enhancement',
      name: 'Development Debug Enhancement',
      condition: 'true', // Apply to all events
      actions: [
        TransformAction(
          addMetadata: {
            'debug_mode': true,
            'build_number': '${getBuildNumber()}',
            'developer_id': '${getDeveloperId()}',
          },
        ),
      ],
    ));
  }
}
```

## Event Interception System

The Obsly library provides comprehensive event interception capabilities across all major event types.

### UI Event Interception

#### Automatic UI Event Capture

The library automatically captures:
- Button taps and widget interactions
- Form submissions and input changes
- Gesture events (swipes, pinch, rotate)
- Scroll events and list interactions

```dart
// Configuration for UI event capture
const uiConfig = ObslyConfig(
  enableUI: true,
  enableScreenshotOnUi: true,
  rageClick: RageClickConfig(
    active: true,
    screenshot: true,
    screenshotPercent: 0.2,
  ),
);
```

#### Custom UI Event Rules

```dart
// Rule to detect rage clicks
final rageClickRule = Rule(
  id: 'rage_click_detection',
  name: 'Rage Click Pattern Detection',
  condition: '''
    event.type === "ui" && 
    event.metadata.clickCount > 5 && 
    event.metadata.timeWindow < 2000
  ''',
  actions: [
    AlertAction(
      severity: 'medium',
      message: 'User frustration detected (rage clicking)',
    ),
    TransformAction(
      addMetadata: {
        'user_frustration': true,
        'ux_issue': 'potential_ui_problem',
      },
    ),
  ],
);

// Rule to track form abandonment
final formAbandonmentRule = Rule(
  id: 'form_abandonment',
  name: 'Form Abandonment Detection',
  condition: '''
    event.type === "navigation" && 
    event.metadata.formStarted === true && 
    event.metadata.formCompleted !== true
  ''',
  actions: [
    AlertAction(
      message: 'Form abandonment detected on ${event.metadata.screen}',
    ),
    TransformAction(
      addMetadata: {
        'conversion_issue': 'form_abandonment',
        'completion_rate': '${event.metadata.completionPercentage}',
      },
    ),
  ],
);
```

### HTTP Event Interception

#### Automatic Network Monitoring

```dart
const httpConfig = ObslyConfig(
  enableRequestLog: true,
  captureBodyOnError: true,
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
      headers: ['content-type', 'x-correlation-id', 'x-request-id'],
    ),
  ],
);
```

#### HTTP Event Rules

```dart
// API Error Detection
final apiErrorRule = Rule(
  id: 'api_error_detection',
  name: 'API Error Pattern Detection',
  condition: '''
    event.type === "http" && 
    event.metadata.statusCode >= 500
  ''',
  actions: [
    AlertAction(
      severity: 'high',
      message: 'API server error: ${event.metadata.url} (${event.metadata.statusCode})',
      channels: ['backend_team'],
    ),
    TransformAction(
      addMetadata: {
        'api_health_issue': true,
        'service_affected': '${extractServiceName(event.metadata.url)}',
      },
    ),
  ],
);

// Authentication Failure Detection
final authFailureRule = Rule(
  id: 'auth_failure_detection',
  name: 'Authentication Failure Detection',
  condition: '''
    event.type === "http" && 
    event.metadata.statusCode === 401 && 
    event.metadata.url.includes("/auth")
  ''',
  actions: [
    AlertAction(
      severity: 'medium',
      message: 'Authentication failure detected for user ${event.userId}',
    ),
    TransformAction(
      addMetadata: {
        'security_event': 'auth_failure',
        'requires_investigation': true,
      },
    ),
  ],
);
```

### Console Event Interception

#### Debug Log Processing

```dart
const consoleConfig = ObslyConfig(
  captureConsole: true,
);

// Rule to detect error patterns in logs
final errorLogRule = Rule(
  id: 'error_log_pattern',
  name: 'Error Pattern in Console Logs',
  condition: '''
    event.type === "console" && 
    (event.message.includes("ERROR") || 
     event.message.includes("FATAL") ||
     event.level === "error")
  ''',
  actions: [
    AlertAction(
      severity: 'medium',
      message: 'Error detected in console: ${event.message}',
    ),
    TransformAction(
      addMetadata: {
        'log_level_issue': true,
        'requires_debugging': true,
      },
    ),
  ],
);
```

### Crash Event Interception

#### Automatic Crash Detection

```dart
const crashConfig = ObslyConfig(
  enableCrashes: true,
);

// Critical crash handling rule
final criticalCrashRule = Rule(
  id: 'critical_crash_handling',
  name: 'Critical Application Crash',
  condition: 'event.type === "crash"',
  actions: [
    AlertAction(
      severity: 'critical',
      message: 'Application crash detected: ${event.error}',
      channels: ['emergency_alerts', 'development_team'],
    ),
    TransformAction(
      addMetadata: {
        'incident_priority': 'P1',
        'immediate_action_required': true,
        'crash_context': '${event.metadata}',
      },
    ),
  ],
);
```

### Lifecycle Event Interception

#### App State Monitoring

```dart
const lifecycleConfig = ObslyConfig(
  enableLifeCycleLog: true,
);

// Session quality rule
final sessionQualityRule = Rule(
  id: 'session_quality_monitoring',
  name: 'Session Quality Monitoring',
  condition: '''
    event.type === "lifecycle" && 
    event.metadata.state === "background" && 
    event.metadata.sessionDuration < 30000
  ''',
  actions: [
    AlertAction(
      severity: 'low',
      message: 'Short session detected (${event.metadata.sessionDuration}ms)',
    ),
    TransformAction(
      addMetadata: {
        'session_quality': 'poor',
        'engagement_issue': true,
      },
    ),
  ],
);
```

## Remote Configuration System

### Basic Configuration

```dart
await ObslySDK.instance.init(InitParameters(
  obslyKey: 'your-api-key', // Contact help@obsly.io for your key
  instanceURL: 'https://api.obsly.io',
  remoteConfigURL: 'https://config.obsly.io/v1/config',
  // Local configuration as fallback
  config: const ObslyConfig(
    enableUI: true,
    enableRequestLog: true,
    enableCrashes: true,
    enableDebugTools: false,
  ),
));
```

### Hybrid Configuration (Local + Remote)

```dart
class ConfigurationManager {
  static Future<void> setupHybridConfig() async {
    // Base local configuration
    const localConfig = ObslyConfig(
      enableAutomaticCapture: true,
      enableDebugTools: false,
      logLevel: LogLevel.error,
      // Conservative rate limits as fallback
      rateLimits: RateLimits(
        error: RateLimitConfig(bucketSize: 5),
        ui: RateLimitConfig(bucketSize: 10),
      ),
    );

    await ObslySDK.instance.init(InitParameters(
      obslyKey: Environment.obslyApiKey,
      instanceURL: Environment.obslyInstanceUrl,
      remoteConfigURL: Environment.remoteConfigUrl,
      config: localConfig, // Fallback if remote fails
      proEnv: Environment.isProduction,
    ));

    // Final configuration will be local + remote
    // Remote takes precedence over local
  }
}
```

### Configuration Hot Reload

```dart
class ConfigurationService {
  static Future<void> forceConfigRefresh() async {
    try {
      // Force remote configuration update
      await ConfigController.instance.forceRefresh();

      print('✅ Configuration updated from server');

      // New configuration is automatically applied
      // to all controllers and interceptors

    } catch (e) {
      print('❌ Error updating configuration: $e');
      // SDK continues with current configuration
    }
  }

  // Listen to configuration changes
  static void listenToConfigChanges() {
    ConfigController.instance.onConfigChanged.listen((newConfig) {
      print('🔄 Configuration changed:');
      print('  - Debug Tools: ${newConfig.enableDebugTools}');
      print('  - Screenshots: ${newConfig.enableScreenshotOnUi}');
      print('  - Rate Limits: ${newConfig.rateLimits}');
    });
  }
}
```

## Advanced Rate Limiting

### Granular Configuration per Event Type

```dart
const advancedRateLimits = RateLimits(
  // Critical errors: very restrictive
  error: RateLimitConfig(
    interval: 10000,        // 10 seconds
    bucketSize: 3,          // Maximum 3 errors
    trailing: true,         // Send at end of period
    emptyBucketDelay: 5000, // Wait 5s before emptying
    rejectWhenBucketFull: true, // Reject if full
  ),

  // Console logs: moderately restrictive
  console: RateLimitConfig(
    interval: 2000,         // 2 seconds
    bucketSize: 10,         // 10 logs per period
    trailing: false,        // Don't send at end
    rejectWhenBucketFull: true,
  ),

  // UI events: permissive but controlled
  ui: RateLimitConfig(
    interval: 1000,         // 1 second
    bucketSize: 25,         // 25 UI events
    trailing: true,
    emptyBucketDelay: 1000,
    rejectWhenBucketFull: false, // Don't reject UI events
  ),

  // HTTP requests: very permissive
  request: RateLimitConfig(
    interval: 1000,
    bucketSize: 50,         // 50 requests per second
    trailing: true,
    emptyBucketDelay: 500,
  ),

  // Metrics: highly permissive
  metric: RateLimitConfig(
    interval: 500,          // 500ms
    bucketSize: 100,        // 100 metrics per period
    trailing: true,
  ),

  // Performance: moderate
  performance: RateLimitConfig(
    interval: 2000,
    bucketSize: 20,
    trailing: true,
  ),
);
```

### Dynamic Rate Limiting

```dart
class DynamicRateLimitManager {
  static void adjustRateLimitsBasedOnContext() {
    // Get current configuration
    final currentConfig = ConfigController.instance.config;

    // Adjust based on conditions
    if (isLowBatteryMode()) {
      // Reduce rate limits to save battery
      updateRateLimits(conservativeRateLimits);
    } else if (isHighTrafficScenario()) {
      // Increase limits to capture more data
      updateRateLimits(aggressiveRateLimits);
    }
  }

  static const conservativeRateLimits = RateLimits(
    error: RateLimitConfig(bucketSize: 2, interval: 15000),
    ui: RateLimitConfig(bucketSize: 5, interval: 2000),
    request: RateLimitConfig(bucketSize: 10, interval: 2000),
  );

  static const aggressiveRateLimits = RateLimits(
    error: RateLimitConfig(bucketSize: 10, interval: 5000),
    ui: RateLimitConfig(bucketSize: 50, interval: 1000),
    request: RateLimitConfig(bucketSize: 100, interval: 1000),
  );
}
```

## Selective Request Capture

### Advanced Headers Configuration

```dart
const advancedRequestConfig = ObslyConfig(
  requestHeadersWhitelist: [
    // Critical APIs: capture everything on errors
    RequestHeadersConfig(
      url: 'https://api.critical-service.com/*',
      fromStatus: 400,
      toStatus: 599,
      headers: [
        'content-type',
        'authorization',
        'x-request-id',
        'x-correlation-id',
        'x-trace-id',
        'user-agent',
        'accept',
        'cache-control',
        '*', // Capture all headers for this URL
      ],
    ),

    // Third-party APIs: only essential headers
    RequestHeadersConfig(
      url: 'https://*.third-party.com/*',
      fromStatus: 500,
      toStatus: 599,
      headers: ['x-request-id', 'content-type'],
    ),

    // Public APIs: capture on success too for debugging
    RequestHeadersConfig(
      url: 'https://public-api.myservice.com/*',
      fromStatus: 200,
      toStatus: 599,
      headers: ['x-version', 'x-rate-limit-*'], // Wildcards
    ),
  ],
);
```

### Selective Body Capture

```dart
const bodyCapture = ObslyConfig(
  requestBodyWhitelist: [
    // Authentication: only request body on client errors
    RequestBodyConfig(
      url: 'https://auth.myservice.com/*',
      fromStatus: 400,
      toStatus: 499,
      captureRequestBody: true,   // Capture request for debugging
      captureResponseBody: false, // No response for security
    ),

    // Payment APIs: don't capture anything for security
    // (Not including in whitelist = no capture)

    // Data APIs: capture everything on server errors
    RequestBodyConfig(
      url: 'https://data.myservice.com/*',
      fromStatus: 500,
      toStatus: 599,
      captureRequestBody: true,
      captureResponseBody: true,
    ),

    // Development APIs: capture everything
    RequestBodyConfig(
      url: 'https://dev-api.myservice.com/*',
      fromStatus: 200,
      toStatus: 599,
      captureRequestBody: true,
      captureResponseBody: true,
    ),
  ],
);
```

### Dynamic Filters

```dart
class RequestCaptureManager {
  static bool shouldCaptureRequest(String url, int statusCode) {
    // Dynamic logic to decide capture

    if (isProductionEnvironment() && url.contains('payment')) {
      // Never capture payment data in production
      return false;
    }

    if (statusCode >= 500) {
      // Always capture server errors
      return true;
    }

    if (isDebugMode() && statusCode >= 400) {
      // In debug, capture all errors
      return true;
    }

    return false;
  }

  static List<String> getHeadersToCapture(String url) {
    if (url.contains('auth')) {
      return ['content-type', 'x-request-id'];
    }

    if (url.contains('api/v2')) {
      return ['content-type', 'x-api-version', 'x-rate-limit-remaining'];
    }

    return ['content-type']; // Minimum by default
  }
}
```

## Rules Engine System

### Rules Configuration

```dart
class RulesManager {
  static Future<void> setupRules() async {
    try {
      // Configure rules manager
      await RulesManager.instance.initialize();

      // Add manual rules
      await addManualRules();

      // Remote rules are loaded automatically
      print('✅ Rules engine configured');

    } catch (e) {
      print('❌ Error configuring rules: $e');
    }
  }

  static Future<void> addManualRules() async {
    // Rule to detect login failures
    final loginFailureRule = Rule(
      id: 'detect_login_failure',
      name: 'Detect Login Failures',
      condition: '''
        event.type === 'error' &&
        event.title?.includes('Login') &&
        event.message?.includes('failed')
      ''',
      actions: [
        AlertAction(
          severity: 'high',
          message: 'Multiple login failures detected',
        ),
        TagAction(
          tags: {'security_alert': 'login_failure'},
        ),
      ],
    );

    await RulesManager.instance.addRule(loginFailureRule);

    // Rule to detect rage clicks
    final rageClickRule = Rule(
      id: 'detect_rage_clicks',
      name: 'Detect Rage Clicks',
      condition: '''
        event.type === 'ui' &&
        event.clickCount > 5 &&
        event.timeWindow < 2000
      ''',
      actions: [
        ScreenshotAction(),
        TagAction(
          tags: {'user_frustration': 'rage_click'},
        ),
      ],
    );

    await RulesManager.instance.addRule(rageClickRule);
  }
}
```

### Dynamic Rules

```dart
class DynamicRulesService {
  static Future<void> updateRulesBasedOnContext() async {
    final currentHour = DateTime.now().hour;

    if (currentHour >= 22 || currentHour <= 6) {
      // Night time: more restrictive rules
      await activateNightModeRules();
    } else {
      // Day time: normal rules
      await activateDayModeRules();
    }
  }

  static Future<void> activateNightModeRules() async {
    // Disable noisy rules during night
    await RulesManager.instance.disableRule('verbose_ui_tracking');

    // Activate only critical rules
    await RulesManager.instance.enableRule('critical_errors_only');
    await RulesManager.instance.enableRule('security_alerts');
  }

  static Future<void> activateDayModeRules() async {
    // Activate all rules during day
    await RulesManager.instance.enableAllRules();
  }
}
```

## Performance Optimization

### Smart Batching

```dart
class PerformanceOptimizer {
  static void configureOptimalBatching() {
    // Configure batching based on network conditions
    final networkType = getCurrentNetworkType();

    BatchConfig batchConfig;

    switch (networkType) {
      case NetworkType.wifi:
        batchConfig = const BatchConfig(
          maxBatchSize: 50,
          maxWaitTime: Duration(seconds: 2),
          compressionEnabled: true,
        );
        break;

      case NetworkType.cellular4G:
        batchConfig = const BatchConfig(
          maxBatchSize: 20,
          maxWaitTime: Duration(seconds: 5),
          compressionEnabled: true,
        );
        break;

      case NetworkType.cellular3G:
        batchConfig = const BatchConfig(
          maxBatchSize: 10,
          maxWaitTime: Duration(seconds: 10),
          compressionEnabled: true,
        );
        break;

      default:
        batchConfig = const BatchConfig(
          maxBatchSize: 5,
          maxWaitTime: Duration(seconds: 15),
          compressionEnabled: true,
        );
    }

    EventController.instance.updateBatchConfig(batchConfig);
  }
}
```

### Memory Management

```dart
class MemoryOptimizer {
  static Future<void> configureMemoryManagement() async {
    // Configure memory limits
    const memoryConfig = MemoryConfig(
      maxEventsInMemory: 1000,
      maxScreenshotsInMemory: 10,
      enableAutomaticCleanup: true,
      cleanupThreshold: 0.8, // 80% of limit
    );

    await ObslyStorage.instance.configure(memoryConfig);

    // Configure automatic cleanup every 5 minutes
    Timer.periodic(Duration(minutes: 5), (_) {
      performMemoryCleanup();
    });
  }

  static Future<void> performMemoryCleanup() async {
    final memoryUsage = await getMemoryUsage();

    if (memoryUsage > 0.8) {
      // Clean old events
      await ObslyStorage.instance.cleanupOldEvents();

      // Clean old screenshots
      await ObslyScreenshotCapture.instance.cleanupOldScreenshots();

      // Force garbage collection
      await forceGarbageCollection();

      print('🧹 Memory cleanup performed');
    }
  }
}
```

### Battery Optimization

```dart
class BatteryOptimizer {
  static Future<void> configureBatteryOptimization() async {
    // Monitor battery level
    final batteryLevel = await Battery().batteryLevel;

    if (batteryLevel < 20) {
      // Low power mode
      await enableLowPowerMode();
    } else if (batteryLevel > 80) {
      // Normal mode
      await enableNormalMode();
    }

    // Listen to battery changes
    Battery().onBatteryStateChanged.listen((BatteryState state) {
      if (state == BatteryState.charging) {
        enableNormalMode();
      } else {
        adjustForBatteryLevel();
      }
    });
  }

  static Future<void> enableLowPowerMode() async {
    // Reduce capture frequency
    await ObslySDK.instance.updateConfig(const ObslyConfig(
      enableScreenshotOnUi: false,
      rateLimits: RateLimits(
        ui: RateLimitConfig(bucketSize: 5, interval: 5000),
        request: RateLimitConfig(bucketSize: 10, interval: 3000),
      ),
    ));

    print('🔋 Low power mode activated');
  }
}
```

## Advanced Session Management

### Smart Sessions

```dart
class SmartSessionManager {
  static Future<void> configureSmartSessions() async {
    // Configure smart timeouts
    await SessionController.instance.configure(
      SessionConfig(
        maxLengthMins: 60,                    // 1 hour maximum
        inactivityTimeoutMins: 15,           // 15 min of inactivity
        backgroundTimeoutMins: 5,            // 5 min in background
        enableSmartTimeout: true,            // Smart timeout
        enableCrossSessionTracking: true,    // Cross-session tracking
      ),
    );

    // Configure new session triggers
    setupSessionTriggers();
  }

  static void setupSessionTriggers() {
    // New session on user change
    AuthService.onUserChanged.listen((newUser) {
      ObslySDK.instance.startNewSession();
    });

    // New session after prolonged period
    AppLifecycleController.onResumed.listen((_) {
      final lastActivity = SessionStorage.instance.lastActivity;
      final now = DateTime.now();

      if (now.difference(lastActivity).inHours > 4) {
        ObslySDK.instance.startNewSession();
      }
    });

    // New session on significant context change
    LocationService.onSignificantLocationChange.listen((_) {
      ObslySDK.instance.addTag([
        Tag(key: 'location_change', value: 'significant'),
      ], 'Session Context');
    });
  }
}
```

### Session Analytics

```dart
class SessionAnalytics {
  static Future<void> trackSessionMetrics() async {
    final session = ObslySDK.instance.getSessionInfo();
    if (session == null) return;

    final sessionDuration = DateTime.now().difference(session.startTime);

    // Duration metrics
    await ObslySDK.instance.metrics.setGauge(
      'SESSION_DURATION_MINUTES',
      sessionDuration.inMinutes,
      fbl: 'SESSION',
      operation: 'ANALYTICS',
      view: 'METRICS',
      state: 'CURRENT'
    );

    // Activity metrics
    final eventCount = await getEventCountForSession(session.sessionId);
    await ObslySDK.instance.metrics.setGauge(
      'SESSION_EVENT_COUNT',
      eventCount,
      fbl: 'SESSION',
      operation: 'ANALYTICS',
      view: 'METRICS',
      state: 'CURRENT'
    );

    // Detect anomalous sessions
    if (sessionDuration.inHours > 8) {
      await ObslySDK.instance.createErrorEvent(
        title: 'Abnormally Long Session',
        message: 'Session duration exceeds normal bounds',
        traceId: 'session-${session.sessionId}',
      );
    }
  }
}
```

## Security & Privacy

### Data Sanitization

```dart
class DataSanitizer {
  static Map<String, dynamic> sanitizeEventData(Map<String, dynamic> eventData) {
    final sanitized = Map<String, dynamic>.from(eventData);

    // Remove sensitive data
    const sensitiveKeys = [
      'password',
      'token',
      'secret',
      'key',
      'authorization',
      'credit_card',
      'ssn',
      'email', // optional depending on policies
    ];

    for (final key in sensitiveKeys) {
      sanitized.removeWhere((k, v) =>
        k.toLowerCase().contains(key.toLowerCase()));
    }

    // Sanitize URLs
    if (sanitized.containsKey('url')) {
      sanitized['url'] = sanitizeUrl(sanitized['url']);
    }

    // Sanitize form data
    if (sanitized.containsKey('formData')) {
      sanitized['formData'] = sanitizeFormData(sanitized['formData']);
    }

    return sanitized;
  }

  static String sanitizeUrl(String url) {
    final uri = Uri.parse(url);

    // Remove sensitive parameters
    final filteredParams = Map<String, String>.from(uri.queryParameters);
    filteredParams.removeWhere((key, value) =>
      key.toLowerCase().contains('token') ||
      key.toLowerCase().contains('secret') ||
      key.toLowerCase().contains('password'));

    return uri.replace(queryParameters: filteredParams).toString();
  }
}
```

### Encryption in Transit

```dart
class SecurityManager {
  static Future<void> configureSecureCommunication() async {
    // Configure certificate pinning
    final secureClient = createSecureHttpClient();

    await ObslySDK.instance.configure(
      securityConfig: SecurityConfig(
        enableCertificatePinning: true,
        certificateHashes: [
          'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        ],
        enableRequestSigning: true,
        encryptSensitiveData: true,
      ),
      httpClient: secureClient,
    );
  }

  static http.Client createSecureHttpClient() {
    return http.Client()..interceptors.add(
      SecurityInterceptor(
        onRequest: (request) {
          // Add security headers
          request.headers['X-SDK-Version'] = '0.2.0';
          request.headers['X-Client-Type'] = 'flutter';

          // Sign request if necessary
          if (shouldSignRequest(request.url)) {
            final signature = signRequest(request);
            request.headers['X-Signature'] = signature;
          }

          return request;
        },
      ),
    );
  }
}
```

## Multi-Environment Setup

### Environment Configuration

```dart
class EnvironmentConfig {
  static const development = ObslyConfig(
    enableDebugTools: true,
    enableScreenshotOnUi: true,
    logLevel: LogLevel.debug,
    enableAutomaticCapture: true,
    rateLimits: RateLimits(
      error: RateLimitConfig(bucketSize: 100),
      ui: RateLimitConfig(bucketSize: 200),
    ),
  );

  static const staging = ObslyConfig(
    enableDebugTools: false,
    enableScreenshotOnUi: true,
    logLevel: LogLevel.warn,
    enableAutomaticCapture: true,
    rateLimits: RateLimits(
      error: RateLimitConfig(bucketSize: 50),
      ui: RateLimitConfig(bucketSize: 100),
    ),
  );

  static const production = ObslyConfig(
    enableDebugTools: false,
    enableScreenshotOnUi: false,
    logLevel: LogLevel.error,
    enableAutomaticCapture: true,
    rateLimits: RateLimits(
      error: RateLimitConfig(bucketSize: 10, rejectWhenBucketFull: true),
      ui: RateLimitConfig(bucketSize: 20),
    ),
  );

  static ObslyConfig getConfigForEnvironment(Environment env) {
    switch (env) {
      case Environment.development:
        return development;
      case Environment.staging:
        return staging;
      case Environment.production:
        return production;
    }
  }
}

// Usage:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = Environment.fromString(
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development')
  );

  await ObslySDK.instance.init(InitParameters(
    obslyKey: Environment.getApiKey(environment),
    instanceURL: Environment.getInstanceUrl(environment),
    config: EnvironmentConfig.getConfigForEnvironment(environment),
  ));

  runApp(MyApp());
}
```

## Screen Timing Measurements

The Obsly SDK provides automatic screen timing measurements using histograms to monitor page load performance across your Flutter application.

### Core Metrics

#### `PageLoadComplete` (Automatic)
- **What it measures**: Technical rendering time from navigation to complete screen load
- **When**: From navigation start to `addPostFrameCallback`  
- **Usage**: Automatic measurement via `ScreenTimingObserver`

#### `PageLoadUsable` (Manual)
- **What it measures**: Time until user can interact with the screen
- **When**: From start until data/UI is ready for use
- **Usage**: Manual measurement via `ScreenTimingMixin`

Both use Obsly's histogram system, enabling:
- Percentile analysis (P50, P95, P99)
- Distribution by timing buckets
- Historical performance comparison
- Alerts when times exceed thresholds

### Automatic Implementation

#### 1. Global RouteObserver (`ScreenTimingObserver`)

Automatically activates in `main.dart` and captures:
- ✅ Navigation between screens (push/pop/replace)
- ✅ Time from navigation start to complete load
- ✅ Automatic route names
- ✅ Automatic timer cleanup on session changes

**Automatic configuration:**
```dart
// In main.dart - already configured
navigatorObservers: [
  ScreenTimingObserver(),
],
```

#### 2. Metric Structure

**PageLoadComplete (Automatic)**
```dart
Metric: PageLoadComplete
FBL: screen_timing  
Operation: technical_render
View: [screen_name] // e.g., "dashboard", "login", "transfer"
State: rendered
```

**PageLoadUsable (Manual)**
```dart
Metric: PageLoadUsable
FBL: screen_timing  
Operation: [custom_operation] // e.g., "dashboard_usable", "data_loading"
View: [screen_name]
State: ready | success | error
```

### Advanced Usage with Mixin

For specific measurements within screens, use `ScreenTimingMixin`:

#### Example 1: Measure specific function
```dart
class _MyScreenState extends State<MyScreen> with ScreenTimingMixin {
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() async {
    // Automatically measures data loading time
    await measureFunction(() async {
      // Your data loading logic
      await ApiService.loadUserData();
      await DatabaseService.loadLocalData();
    }, 'data_loading');
  }
}
```

#### Example 2: Manual timing control
```dart
void _complexOperation() async {
  // Start manual measurement
  startManualTiming('complex_operation');
  
  try {
    // Your complex operation
    await doSomethingComplex();
    
    // End with success
    endManualTiming(state: 'success');
  } catch (e) {
    // End with error
    endManualTiming(state: 'error');
  }
}
```

#### Example 3: Custom view measurement
```dart
await measureFunction(() async {
  // Specific operation
  await processPayment();
}, 'payment_processing', customView: 'payment_flow');
```

### Data Captured

#### Automatic Information:
- **Start/end timestamps**
- **Duration in milliseconds**
- **Histogram bucket** (100ms, 300ms, 500ms, 1000ms, 3000ms, 5000ms, 30000ms)
- **Screen name**
- **Application context** (app, platform, version)

#### Event Structure:
```json
{
  "metric_type": 3, // histogram
  "key": "PageLoadComplete",
  "value": 1, // count
  "duration": 245, // milliseconds
  "dimensions": {
    "fbl": "screen_timing",
    "operation": "page_load",
    "view": "dashboard",
    "state": "completed",
    "le": 300.0, // bucket where measurement falls
    "app": "Banking App",
    "platform": "android",
    "version": "1.0.0"
  }
}
```

### Histogram Buckets

The timing measurements use UX-appropriate buckets:

- **100ms**: Instant feel ⚡
- **300ms**: Responsive feel 🚀  
- **500ms**: Acceptable interaction ✅
- **1000ms**: Noticeable delay ⏳
- **3000ms**: Slow but tolerable 🐌
- **5000ms**: Very slow/problematic ⚠️
- **30000ms**: Extreme/timeout cases 🔴

### Monitoring and Debug

#### View runtime statistics:
```dart
// Get observer stats
final stats = ScreenTimingObserver().getStats();
print('Active timers: ${stats['active_timers']}');

// In mixin, verify manual timing
if (mounted) {
  print('Manual timing active: ${_currentOperation}');
}
```

#### Automatic logs:
```
🕐 Started timing for screen: dashboard
✅ Completed timing for screen: dashboard (245ms)
🕐 Started manual timing: data_loading on DashboardScreen
✅ Ended manual timing: data_loading on DashboardScreen (156ms)
```

### Performance and Optimizations

#### Efficiency features:
- ✅ **Zero overhead** when metrics are disabled
- ✅ **Automatic cleanup** of timers on session changes
- ✅ **Robust error handling** - never crashes the app
- ✅ **Memory management** - uses local Map with cleanup
- ✅ **Thread safe** - uses DateTime.now() and async/await

#### Rate limiting configuration:
Metrics respect the SDK's rate limiting configuration:

```dart
// In obsly_config if you need to adjust limits
RateLimitConfig(
  metrics: RateLimitConfig(
    maxEventsPerMinute: 100,  // adjustable based on need
  ),
)
```

### Typical Use Cases

#### 1. General Performance Monitoring
- **Automatic** - All screens measured without additional code
- **Alerts** - Configure alerts in Obsly when P95 > threshold
- **Trends** - See how performance changes with new versions

#### 2. Targeted Optimization
- **Identify** slow screens with high P95
- **A/B Testing** - Compare performance between variants
- **Regression Detection** - Detect performance degradation

#### 3. User Experience
- **SLA Monitoring** - Ensure X% of screens load < Y seconds
- **Geographic Analysis** - Performance by region/device
- **Error Correlation** - Relate errors to high load times

### Important Notes

1. **Single metric**: All measurements use `PageLoadComplete`
2. **Consistency**: Same format for automatic and manual measurements
3. **No duplication**: Observer and mixin can coexist without conflict
4. **Session safety**: Timers automatically cleaned between sessions
5. **Production ready**: Robust system with complete error handling

## Advanced Testing

### Test Harness

```dart
class ObslyTestHarness {
  static Future<void> setupTestEnvironment() async {
    // Configure SDK for testing
    await ObslySDK.instance.init(InitParameters(
      obslyKey: 'test-api-key',
      instanceURL: 'https://test.obsly.com',
      config: const ObslyConfig(
        enableDebugTools: true,
        enableAutomaticCapture: false, // Manual control in tests
      ),
    ));

    // Configure test interceptors
    setupTestInterceptors();
  }

  static void setupTestInterceptors() {
    // Intercept events for verification
    EventController.instance.onEventCaptured.listen((event) {
      TestEventCollector.instance.recordEvent(event);
    });

    // Intercept network sends
    NetworkController.instance.onNetworkRequest.listen((request) {
      TestNetworkCollector.instance.recordRequest(request);
    });
  }

  static Future<void> verifyEventCapture({
    required String expectedEventType,
    required Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<void>();

    Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError('Timeout waiting for event: $expectedEventType');
      }
    });

    final subscription = TestEventCollector.instance.events.listen((event) {
      if (event.type == expectedEventType && !completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      await completer.future;
    } finally {
      subscription.cancel();
    }
  }
}

// Usage in tests:
testWidgets('should capture button tap event', (tester) async {
  await ObslyTestHarness.setupTestEnvironment();

  await tester.pumpWidget(MyApp());

  // Trigger action
  await tester.tap(find.byKey(Key('submit-button')));

  // Verify event capture
  await ObslyTestHarness.verifyEventCapture(
    expectedEventType: 'ui',
    timeout: Duration(seconds: 3),
  );
});
```

### Performance Testing

```dart
class PerformanceTestSuite {
  static Future<void> runPerformanceTests() async {
    await testMemoryUsage();
    await testEventProcessingLatency();
    await testBatchingPerformance();
  }

  static Future<void> testMemoryUsage() async {
    final initialMemory = await getMemoryUsage();

    // Generate 1000 events
    for (int i = 0; i < 1000; i++) {
      await ObslySDK.instance.trackEvent({
        'type': 'test_event',
        'iteration': i,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    final finalMemory = await getMemoryUsage();
    final memoryIncrease = finalMemory - initialMemory;

    // Verify memory increase is acceptable
    expect(memoryIncrease, lessThan(50 * 1024 * 1024)); // < 50MB
  }

  static Future<void> testEventProcessingLatency() async {
    final stopwatch = Stopwatch()..start();

    await ObslySDK.instance.trackEvent({
      'type': 'latency_test',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    stopwatch.stop();

    // Verify processing is fast
    expect(stopwatch.elapsedMilliseconds, lessThan(10)); // < 10ms
  }
}
```

These advanced features provide granular control over library behavior, comprehensive event interception capabilities, intelligent rules-based processing, and sophisticated tools for monitoring, debugging, and optimizing Flutter applications.

## Key Benefits

- **Rules Engine**: Dynamic event processing without app updates
- **Comprehensive Interception**: UI, lifecycle, navigation, console, crash, and HTTP events
- **Real-time Processing**: Immediate event evaluation and action execution
- **Advanced Analytics**: Performance monitoring and business intelligence
- **Security & Privacy**: Configurable data filtering and protection
- **Developer Tools**: Debug interfaces and testing capabilities

## Support

For questions about advanced features:

- 📧 Email: [help@obsly.io](mailto:help@obsly.io)
- 📖 Documentation: [Complete docs](./)
