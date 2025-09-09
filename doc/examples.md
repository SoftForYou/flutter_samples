# Obsly Flutter Library - Usage Examples

This document provides comprehensive examples of how to use the Obsly Flutter library for different types of applications and use cases, focusing on event interception, rules engine, and analytics capabilities.

## Table of Contents

- [Basic Examples](#basic-examples)
- [Banking Applications](#banking-applications)
- [E-commerce](#e-commerce)
- [Health Apps](#health-apps)
- [Productivity Apps](#productivity-apps)
- [Gaming](#gaming)
- [Streaming & Media](#streaming--media)
- [Advanced Patterns](#advanced-patterns)

## Basic Examples

### Minimal Configuration

```dart
import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

void main() {
  ObslySDK.run(() {
    runApp(
      ObslySDK.wrapApp(
        app: const MyApp(),
        obslyKey: 'your-api-key', // Contact help@obsly.io for your key
        instanceURL: 'https://api.obsly.io',
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const HomeScreen(),
    );
  }
}
```

### Configuration with Error Handling

```dart
void main() {
  // Standard configuration with complete protection
  ObslySDK.run(() {
    runApp(
      ObslySDK.wrapApp(
        app: const MyApp(),
        obslyKey: 'your-api-key', // Contact help@obsly.io for your key
        instanceURL: 'https://api.obsly.io',
        debugMode: true,
        logLevel: LogLevel.debug,
        enableDebugTools: true,
        config: const ObslyConfig(
          enableUI: true,
          enableRequestLog: true,
          enableCrashes: true,
          enableLifeCycleLog: true,
          enableDebugTools: true,
          enableScreenshotOnUi: true,
        ),
      ),
    );
  });
}

// For cases requiring manual control
void mainAdvanced() async {
  WidgetsFlutterBinding.ensureInitialized();

  ObslySDK.run(() async {
    try {
      await ObslySDK.instance.init(InitParameters(
        obslyKey: 'your-api-key', // Contact help@obsly.io for your key
        instanceURL: 'https://api.obsly.io',
        appName: 'My Flutter App',
        appVersion: '1.0.0',
        config: const ObslyConfig(
          enableUI: true,
          enableRequestLog: true,
          enableCrashes: true,
          enableDebugTools: false,
        ),
      ));

      print('✅ Obsly library initialized');
      runApp(const MyApp());
    } catch (e) {
      print('❌ Error initializing Obsly: $e');
      // App continues without Obsly
      runApp(const MyApp());
    }
  });
}
```

## Banking Applications

### Banking Login System with Event Interception

```dart
class BankingLoginService {
  static Future<void> performLogin({
    required String username,
    required String loginMethod,
  }) async {
    // Iniciar transacción de performance
    await ObslySDK.instance.performance.startTransaction(
      'BANKING_LOGIN',
      'Complete banking login flow'
    );

    try {
      // Step 1: Validar credenciales
      await ObslySDK.instance.performance.startStep(
        'VALIDATE_CREDENTIALS',
        'BANKING_LOGIN',
        'Validating user credentials'
      );

      final isValid = await validateCredentials(username);

      await ObslySDK.instance.performance.finishStep(
        'VALIDATE_CREDENTIALS',
        'BANKING_LOGIN'
      );

      if (!isValid) {
        throw LoginException('Invalid credentials');
      }

      // Step 2: Verificación 2FA
      await ObslySDK.instance.performance.startStep(
        'TWO_FACTOR_AUTH',
        'BANKING_LOGIN',
        'Two factor authentication'
      );

      await performTwoFactorAuth();

      await ObslySDK.instance.performance.finishStep(
        'TWO_FACTOR_AUTH',
        'BANKING_LOGIN'
      );

      // Step 3: Cargar perfil de usuario
      await ObslySDK.instance.performance.startStep(
        'LOAD_USER_PROFILE',
        'BANKING_LOGIN',
        'Loading user profile and accounts'
      );

      final userProfile = await loadUserProfile(username);

      await ObslySDK.instance.performance.finishStep(
        'LOAD_USER_PROFILE',
        'BANKING_LOGIN'
      );

      // Configurar contexto de usuario
      await ObslySDK.instance.setUserID(username);
      await ObslySDK.instance.setPersonID(userProfile.personId);

      // Agregar tags de contexto
      await ObslySDK.instance.addTag([
        Tag(key: 'login_method', value: loginMethod),
        Tag(key: 'user_tier', value: userProfile.tier),
        Tag(key: 'account_count', value: userProfile.accounts.length.toString()),
        Tag(key: 'login_success', value: 'true'),
      ], 'Banking Authentication');

      // Métricas de éxito
      await ObslySDK.instance.metrics.incCounter(
        'LOGIN_SUCCESS', 'AUTH', 'LOGIN', 'LOGIN_SCREEN', 'SUCCESS'
      );

      await ObslySDK.instance.performance.endTransaction('BANKING_LOGIN');

    } catch (error, stackTrace) {
      // Capturar error de login
      await ObslySDK.instance.createErrorEvent(
        title: 'Banking Login Failed',
        message: 'Critical authentication failure',
        error: error,
        stackTrace: stackTrace,
        traceId: 'login-${DateTime.now().millisecondsSinceEpoch}',
      );

      // Métricas de error
      await ObslySDK.instance.metrics.incCounter(
        'LOGIN_FAILURE', 'AUTH', 'LOGIN', 'LOGIN_SCREEN', 'ERROR'
      );

      await ObslySDK.instance.performance.endTransaction('BANKING_LOGIN');
      rethrow;
    }
  }
}
```

### Transferencia Bancaria

```dart
class BankTransferService {
  static Future<TransferResult> performTransfer({
    required String fromAccount,
    required String toAccount,
    required double amount,
    required String currency,
  }) async {
    final transferId = 'transfer-${DateTime.now().millisecondsSinceEpoch}';

    await ObslySDK.instance.performance.startTransaction(
      'BANK_TRANSFER',
      'Process bank transfer between accounts'
    );

    // Capturar screenshot antes de operación crítica
    await ObslySDK.instance.addScreenshot();

    try {
      // Contexto de la transferencia
      await ObslySDK.instance.addTag([
        Tag(key: 'transfer_id', value: transferId),
        Tag(key: 'from_account', value: fromAccount),
        Tag(key: 'to_account', value: toAccount),
        Tag(key: 'amount', value: amount.toString()),
        Tag(key: 'currency', value: currency),
      ], 'Bank Transfer');

      // Step 1: Validar fondos
      await ObslySDK.instance.performance.startStep(
        'VALIDATE_FUNDS',
        'BANK_TRANSFER'
      );

      final hasEnoughFunds = await validateAccountFunds(fromAccount, amount);
      if (!hasEnoughFunds) {
        throw InsufficientFundsException('Not enough funds');
      }

      await ObslySDK.instance.performance.finishStep(
        'VALIDATE_FUNDS',
        'BANK_TRANSFER'
      );

      // Step 2: Procesar transferencia
      await ObslySDK.instance.performance.startStep(
        'PROCESS_TRANSFER',
        'BANK_TRANSFER'
      );

      final result = await processTransferInCore(
        fromAccount, toAccount, amount, currency
      );

      await ObslySDK.instance.performance.finishStep(
        'PROCESS_TRANSFER',
        'BANK_TRANSFER'
      );

      // Métricas de éxito
      await ObslySDK.instance.metrics.incCounter(
        'TRANSFER_SUCCESS', 'BANKING', 'TRANSFER', 'TRANSFER_SCREEN', 'SUCCESS'
      );

      await ObslySDK.instance.metrics.setGauge(
        'TRANSFER_AMOUNT', amount, fbl: 'BANKING', operation: 'TRANSFER', view: 'TRANSFER_SCREEN', state: 'SUCCESS'
      );

      await ObslySDK.instance.performance.endTransaction('BANK_TRANSFER');

      return result;

    } catch (error, stackTrace) {
      await ObslySDK.instance.createErrorEvent(
        title: 'Bank Transfer Failed',
        subtitle: 'Critical banking operation failure',
        message: 'Transfer failed: ${error.toString()}',
        error: error,
        stackTrace: stackTrace,
        traceId: transferId,
      );

      await ObslySDK.instance.metrics.incCounter(
        'TRANSFER_ERROR', 'BANKING', 'TRANSFER', 'TRANSFER_SCREEN', 'ERROR'
      );

      await ObslySDK.instance.performance.endTransaction('BANK_TRANSFER');
      rethrow;
    }
  }
}
```

## E-commerce

### Proceso de Checkout

```dart
class EcommerceCheckoutService {
  static Future<void> processCheckout({
    required List<CartItem> items,
    required PaymentMethod paymentMethod,
    required ShippingAddress address,
  }) async {
    final orderId = 'order-${DateTime.now().millisecondsSinceEpoch}';

    await ObslySDK.instance.performance.startTransaction(
      'ECOMMERCE_CHECKOUT',
      'Complete checkout process'
    );

    try {
      // Contexto del pedido
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.price);

      await ObslySDK.instance.addTag([
        Tag(key: 'order_id', value: orderId),
        Tag(key: 'item_count', value: items.length.toString()),
        Tag(key: 'total_amount', value: totalAmount.toString()),
        Tag(key: 'payment_method', value: paymentMethod.type),
        Tag(key: 'shipping_country', value: address.country),
      ], 'E-commerce Checkout');

      // Step 1: Validar inventario
      await ObslySDK.instance.performance.startStep(
        'VALIDATE_INVENTORY',
        'ECOMMERCE_CHECKOUT'
      );

      await validateInventory(items);

      await ObslySDK.instance.performance.finishStep(
        'VALIDATE_INVENTORY',
        'ECOMMERCE_CHECKOUT'
      );

      // Step 2: Procesar pago
      await ObslySDK.instance.performance.startStep(
        'PROCESS_PAYMENT',
        'ECOMMERCE_CHECKOUT'
      );

      final paymentResult = await processPayment(paymentMethod, totalAmount);

      await ObslySDK.instance.performance.finishStep(
        'PROCESS_PAYMENT',
        'ECOMMERCE_CHECKOUT'
      );

      // Step 3: Crear orden
      await ObslySDK.instance.performance.startStep(
        'CREATE_ORDER',
        'ECOMMERCE_CHECKOUT'
      );

      await createOrder(orderId, items, paymentResult, address);

      await ObslySDK.instance.performance.finishStep(
        'CREATE_ORDER',
        'ECOMMERCE_CHECKOUT'
      );

      // Métricas de éxito
      await ObslySDK.instance.metrics.incCounter(
        'CHECKOUT_SUCCESS', 'ECOMMERCE', 'PURCHASE', 'CHECKOUT', 'SUCCESS'
      );

      await ObslySDK.instance.metrics.setGauge(
        'ORDER_VALUE', totalAmount, fbl: 'ECOMMERCE', operation: 'PURCHASE', view: 'CHECKOUT', state: 'SUCCESS'
      );

      await ObslySDK.instance.performance.endTransaction('ECOMMERCE_CHECKOUT');

    } catch (error, stackTrace) {
      await ObslySDK.instance.createErrorEvent(
        title: 'Checkout Failed',
        message: 'E-commerce checkout process failed',
        error: error,
        stackTrace: stackTrace,
        traceId: orderId,
      );

      await ObslySDK.instance.performance.endTransaction('ECOMMERCE_CHECKOUT');
      rethrow;
    }
  }
}
```

### Búsqueda de Productos

```dart
class ProductSearchService {
  static Future<List<Product>> searchProducts(String query) async {
    await ObslySDK.instance.performance.startTransaction(
      'PRODUCT_SEARCH',
      'Search products in catalog'
    );

    // Iniciar timer para histograma
    await ObslySDK.instance.metrics.startHistogramTimer(
      'SEARCH_LATENCY', 'ECOMMERCE', 'SEARCH', 'CATALOG'
    );

    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'search_query', value: query),
        Tag(key: 'search_length', value: query.length.toString()),
      ], 'Product Search');

      final results = await performProductSearch(query);

      // Finalizar timer
      await ObslySDK.instance.metrics.endHistogramTimer(
        'SEARCH_LATENCY', 'ECOMMERCE', 'SEARCH', 'CATALOG', 'SUCCESS'
      );

      // Métricas de resultados
      await ObslySDK.instance.metrics.setGauge(
        'SEARCH_RESULTS', results.length, fbl: 'ECOMMERCE', operation: 'SEARCH', view: 'CATALOG', state: 'SUCCESS'
      );

      await ObslySDK.instance.performance.endTransaction('PRODUCT_SEARCH');

      return results;

    } catch (error, stackTrace) {
      await ObslySDK.instance.metrics.endHistogramTimer(
        'SEARCH_LATENCY', 'ECOMMERCE', 'SEARCH', 'CATALOG', 'ERROR'
      );

      await ObslySDK.instance.createErrorEvent(
        title: 'Product Search Failed',
        message: 'Failed to search products: $query',
        error: error,
        stackTrace: stackTrace,
      );

      await ObslySDK.instance.performance.endTransaction('PRODUCT_SEARCH');
      rethrow;
    }
  }
}
```

## Apps de Salud

### Monitorización de Signos Vitales

```dart
class HealthMonitoringService {
  static Future<void> recordVitalSigns({
    required double heartRate,
    required double bloodPressure,
    required double temperature,
  }) async {
    await ObslySDK.instance.performance.startTransaction(
      'RECORD_VITAL_SIGNS',
      'Record patient vital signs'
    );

    try {
      // Contexto médico
      await ObslySDK.instance.addTag([
        Tag(key: 'measurement_type', value: 'vital_signs'),
        Tag(key: 'heart_rate', value: heartRate.toString()),
        Tag(key: 'blood_pressure', value: bloodPressure.toString()),
        Tag(key: 'temperature', value: temperature.toString()),
        Tag(key: 'measurement_time', value: DateTime.now().toIso8601String()),
      ], 'Health Monitoring');

      // Métricas de salud
      await ObslySDK.instance.metrics.setGauge(
        'HEART_RATE', heartRate, fbl: 'HEALTH', operation: 'MONITOR', view: 'VITALS', state: 'RECORDED'
      );

      await ObslySDK.instance.metrics.setGauge(
        'BLOOD_PRESSURE', bloodPressure, fbl: 'HEALTH', operation: 'MONITOR', view: 'VITALS', state: 'RECORDED'
      );

      await ObslySDK.instance.metrics.setGauge(
        'BODY_TEMPERATURE', temperature, fbl: 'HEALTH', operation: 'MONITOR', view: 'VITALS', state: 'RECORDED'
      );

      // Alertas automáticas para valores críticos
      if (heartRate > 100 || heartRate < 60) {
        await ObslySDK.instance.createErrorEvent(
          title: 'Abnormal Heart Rate',
          message: 'Heart rate outside normal range: $heartRate bpm',
          traceId: 'vital-${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      await ObslySDK.instance.performance.endTransaction('RECORD_VITAL_SIGNS');

    } catch (error, stackTrace) {
      await ObslySDK.instance.createErrorEvent(
        title: 'Vital Signs Recording Failed',
        message: 'Failed to record patient vital signs',
        error: error,
        stackTrace: stackTrace,
      );

      await ObslySDK.instance.performance.endTransaction('RECORD_VITAL_SIGNS');
      rethrow;
    }
  }
}
```

## Apps de Productividad

### Sincronización de Documentos

```dart
class DocumentSyncService {
  static Future<void> syncDocuments() async {
    await ObslySDK.instance.performance.startTransaction(
      'DOCUMENT_SYNC',
      'Synchronize documents with cloud'
    );

    try {
      final pendingDocs = await getPendingDocuments();

      await ObslySDK.instance.addTag([
        Tag(key: 'pending_documents', value: pendingDocs.length.toString()),
        Tag(key: 'sync_trigger', value: 'automatic'),
      ], 'Document Sync');

      for (final doc in pendingDocs) {
        await ObslySDK.instance.performance.startStep(
          'SYNC_DOCUMENT_${doc.id}',
          'DOCUMENT_SYNC'
        );

        await syncSingleDocument(doc);

        await ObslySDK.instance.performance.finishStep(
          'SYNC_DOCUMENT_${doc.id}',
          'DOCUMENT_SYNC'
        );

        // Métricas por documento
        await ObslySDK.instance.metrics.incCounter(
          'DOCUMENT_SYNCED', 'PRODUCTIVITY', 'SYNC', 'DOCUMENTS', 'SUCCESS'
        );
      }

      await ObslySDK.instance.performance.endTransaction('DOCUMENT_SYNC');

    } catch (error, stackTrace) {
      await ObslySDK.instance.createErrorEvent(
        title: 'Document Sync Failed',
        message: 'Failed to synchronize documents',
        error: error,
        stackTrace: stackTrace,
      );

      await ObslySDK.instance.performance.endTransaction('DOCUMENT_SYNC');
      rethrow;
    }
  }
}
```

## Gaming

### Sistema de Puntuación

```dart
class GameScoreService {
  static Future<void> submitScore({
    required String playerId,
    required int score,
    required String gameMode,
    required int level,
  }) async {
    await ObslySDK.instance.performance.startTransaction(
      'SUBMIT_SCORE',
      'Submit player score to leaderboard'
    );

    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'player_id', value: playerId),
        Tag(key: 'game_mode', value: gameMode),
        Tag(key: 'level', value: level.toString()),
        Tag(key: 'score', value: score.toString()),
      ], 'Gaming Score');

      // Métricas de gaming
      await ObslySDK.instance.metrics.setGauge(
        'PLAYER_SCORE', score, fbl: 'GAMING', operation: 'SCORE', view: 'LEADERBOARD', state: 'SUBMITTED'
      );

      await ObslySDK.instance.metrics.setGauge(
        'PLAYER_LEVEL', level, fbl: 'GAMING', operation: 'PROGRESS', view: 'PLAYER', state: 'CURRENT'
      );

      // Detectar nuevo récord
      final currentBest = await getCurrentBestScore(playerId, gameMode);
      if (score > currentBest) {
        await ObslySDK.instance.addTag([
          Tag(key: 'new_record', value: 'true'),
          Tag(key: 'previous_best', value: currentBest.toString()),
        ], 'Gaming Achievement');

        await ObslySDK.instance.metrics.incCounter(
          'NEW_RECORD', 'GAMING', 'ACHIEVEMENT', 'LEADERBOARD', 'SUCCESS'
        );
      }

      await submitScoreToServer(playerId, score, gameMode, level);

      await ObslySDK.instance.performance.endTransaction('SUBMIT_SCORE');

    } catch (error, stackTrace) {
      await ObslySDK.instance.createErrorEvent(
        title: 'Score Submission Failed',
        message: 'Failed to submit player score',
        error: error,
        stackTrace: stackTrace,
      );

      await ObslySDK.instance.performance.endTransaction('SUBMIT_SCORE');
      rethrow;
    }
  }
}
```

## Streaming y Media

### Reproducción de Video

```dart
class VideoPlayerService {
  static Future<void> trackVideoPlayback({
    required String videoId,
    required String videoTitle,
    required Duration duration,
  }) async {
    await ObslySDK.instance.performance.startTransaction(
      'VIDEO_PLAYBACK',
      'Track video playback session'
    );

    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'video_id', value: videoId),
        Tag(key: 'video_title', value: videoTitle),
        Tag(key: 'video_duration', value: duration.inSeconds.toString()),
        Tag(key: 'playback_start', value: DateTime.now().toIso8601String()),
      ], 'Media Playback');

      // Iniciar tracking de tiempo de visualización
      await ObslySDK.instance.metrics.startHistogramTimer(
        'VIDEO_WATCH_TIME', 'MEDIA', 'PLAYBACK', 'VIDEO'
      );

      // Métricas de inicio de reproducción
      await ObslySDK.instance.metrics.incCounter(
        'VIDEO_STARTED', 'MEDIA', 'PLAYBACK', 'VIDEO', 'SUCCESS'
      );

      // Simular tracking durante reproducción
      final stopwatch = Stopwatch()..start();

      // Cuando el video termine o se pause
      await onVideoFinished(() async {
        stopwatch.stop();

        await ObslySDK.instance.metrics.endHistogramTimer(
          'VIDEO_WATCH_TIME', 'MEDIA', 'PLAYBACK', 'VIDEO', 'COMPLETED'
        );

        final watchPercentage = (stopwatch.elapsed.inSeconds / duration.inSeconds) * 100;

        await ObslySDK.instance.metrics.setGauge(
          'VIDEO_COMPLETION', watchPercentage, fbl: 'MEDIA', operation: 'PLAYBACK', view: 'VIDEO', state: 'COMPLETED'
        );

        await ObslySDK.instance.addTag([
          Tag(key: 'watch_time', value: stopwatch.elapsed.inSeconds.toString()),
          Tag(key: 'completion_percentage', value: watchPercentage.toString()),
        ], 'Media Completion');

        await ObslySDK.instance.performance.endTransaction('VIDEO_PLAYBACK');
      });

    } catch (error, stackTrace) {
      await ObslySDK.instance.createErrorEvent(
        title: 'Video Playback Failed',
        message: 'Failed to play video: $videoTitle',
        error: error,
        stackTrace: stackTrace,
      );

      await ObslySDK.instance.performance.endTransaction('VIDEO_PLAYBACK');
      rethrow;
    }
  }
}
```

## Patrones Avanzados

### Wrapper de Performance Automático

```dart
class ObslyPerformanceWrapper {
  static Future<T> track<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, String>? tags,
    String? description,
  }) async {
    await ObslySDK.instance.performance.startTransaction(
      operationName,
      description
    );

    if (tags != null) {
      await ObslySDK.instance.addTag(
        tags.entries.map((e) => Tag(key: e.key, value: e.value)).toList(),
        'Operation Context'
      );
    }

    try {
      final result = await operation();
      await ObslySDK.instance.performance.endTransaction(operationName);
      return result;
    } catch (error, stackTrace) {
      await ObslySDK.instance.createErrorEvent(
        title: '$operationName Failed',
        message: 'Operation failed during execution',
        error: error,
        stackTrace: stackTrace,
      );

      await ObslySDK.instance.performance.endTransaction(operationName);
      rethrow;
    }
  }
}

// Uso:
final result = await ObslyPerformanceWrapper.track(
  operationName: 'COMPLEX_CALCULATION',
  description: 'Perform complex mathematical calculation',
  tags: {
    'calculation_type': 'matrix_multiplication',
    'matrix_size': '1000x1000',
  },
  operation: () => performComplexCalculation(),
);
```

### Decorator para Métodos Críticos

```dart
mixin ObslyTrackingMixin {
  Future<T> trackCriticalOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, String>? context,
  }) async {
    final operationId = '${operationName.toLowerCase()}-${DateTime.now().millisecondsSinceEpoch}';

    await ObslySDK.instance.performance.startTransaction(operationName);

    // Capturar screenshot antes de operación crítica
    await ObslySDK.instance.addScreenshot();

    try {
      if (context != null) {
        await ObslySDK.instance.addTag([
          Tag(key: 'operation_id', value: operationId),
          ...context.entries.map((e) => Tag(key: e.key, value: e.value)),
        ], 'Critical Operation');
      }

      final result = await operation();

      await ObslySDK.instance.metrics.incCounter(
        '${operationName}_SUCCESS', 'CRITICAL', 'OPERATION', 'SYSTEM', 'SUCCESS'
      );

      await ObslySDK.instance.performance.endTransaction(operationName);

      return result;

    } catch (error, stackTrace) {
      await ObslySDK.instance.createErrorEvent(
        title: 'Critical Operation Failed',
        subtitle: operationName,
        message: 'Critical system operation failed',
        error: error,
        stackTrace: stackTrace,
        traceId: operationId,
      );

      await ObslySDK.instance.metrics.incCounter(
        '${operationName}_ERROR', 'CRITICAL', 'OPERATION', 'SYSTEM', 'ERROR'
      );

      await ObslySDK.instance.performance.endTransaction(operationName);
      rethrow;
    }
  }
}

// Uso en servicios:
class PaymentService with ObslyTrackingMixin {
  Future<PaymentResult> processPayment(PaymentData data) {
    return trackCriticalOperation(
      operationName: 'PROCESS_PAYMENT',
      context: {
        'payment_method': data.method,
        'amount': data.amount.toString(),
        'currency': data.currency,
      },
      operation: () => _performPayment(data),
    );
  }
}
```

### Sistema de Métricas de Negocio

```dart
class BusinessMetrics {
  static const String _fbl = 'BUSINESS';

  // Métricas de retención
  static Future<void> trackUserRetention({
    required String userId,
    required int daysSinceFirstUse,
  }) async {
    await ObslySDK.instance.metrics.setGauge(
      'USER_RETENTION_DAYS', daysSinceFirstUse, fbl: _fbl, operation: 'RETENTION', view: 'USER', state: 'ACTIVE'
    );

    if (daysSinceFirstUse >= 7) {
      await ObslySDK.instance.metrics.incCounter(
        'WEEKLY_RETAINED_USER', _fbl, 'RETENTION', 'USER', 'SUCCESS'
      );
    }

    if (daysSinceFirstUse >= 30) {
      await ObslySDK.instance.metrics.incCounter(
        'MONTHLY_RETAINED_USER', _fbl, 'RETENTION', 'USER', 'SUCCESS'
      );
    }
  }

  // Métricas de conversión
  static Future<void> trackConversionFunnel({
    required String funnelStep,
    required String userId,
  }) async {
    await ObslySDK.instance.metrics.incCounter(
      'FUNNEL_$funnelStep', _fbl, 'CONVERSION', 'FUNNEL', 'STEP'
    );

    await ObslySDK.instance.addTag([
      Tag(key: 'funnel_step', value: funnelStep),
      Tag(key: 'user_id', value: userId),
      Tag(key: 'timestamp', value: DateTime.now().millisecondsSinceEpoch.toString()),
    ], 'Conversion Funnel');
  }

  // Métricas de engagement
  static Future<void> trackUserEngagement({
    required String feature,
    required Duration sessionDuration,
  }) async {
    await ObslySDK.instance.metrics.setGauge(
      'SESSION_DURATION', sessionDuration.inMinutes, fbl: _fbl, operation: 'ENGAGEMENT', view: 'SESSION', state: 'COMPLETED'
    );

    await ObslySDK.instance.metrics.incCounter(
      'FEATURE_USAGE_$feature', _fbl, 'ENGAGEMENT', 'FEATURE', 'USED'
    );
  }
}

// Uso:
await BusinessMetrics.trackUserRetention(
  userId: 'user123',
  daysSinceFirstUse: 14,
);

await BusinessMetrics.trackConversionFunnel(
  funnelStep: 'SIGNUP_COMPLETED',
  userId: 'user123',
);
```

These examples demonstrate how to integrate the Obsly Flutter library into different types of applications and use cases, providing complete visibility into application behavior, user experience, and comprehensive event interception capabilities.

## Key Takeaways

- **Event Interception**: Automatic capture of UI, lifecycle, navigation, console, crash, and HTTP events
- **Rules Engine**: Dynamic event processing and filtering capabilities
- **Performance Monitoring**: Real-time performance tracking and analytics
- **Business Intelligence**: Custom metrics and business-specific event tracking
- **Error Handling**: Comprehensive crash detection and error reporting
- **Debug Tools**: Development and troubleshooting capabilities

## Support

For more examples and help:

- 📧 Email: [help@obsly.io](mailto:help@obsly.io)
- 📖 Documentation: [Complete docs](./)
