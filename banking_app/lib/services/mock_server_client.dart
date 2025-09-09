import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:obsly_flutter/obsly_sdk.dart';

/// Client that simulates a complete banking server
/// Generates diverse HTTP traffic for automatic interception testing by HTTPIntegration
class MockServerClient {
  // Different public endpoints to simulate a complete banking system
  static const List<String> _endpoints = [
    'https://jsonplaceholder.typicode.com',
    'https://httpbin.org',
    'https://reqres.in/api',
    'https://api.github.com',
  ];

  // HTTP client - HTTPIntegration handles all interception automatically
  late final http.Client _client;
  final Random _random = Random();
  
  MockServerClient() {
    print('[MOCK] 🔧 CONSTRUCTOR: Inicializando MockServerClient...');
    print('[MOCK] 🔧 Platform: ${kIsWeb ? "WEB" : "NATIVE"}');
    
    if (kIsWeb) {
      print('[MOCK] 🌐 WEB: Verificando estado del SDK...');
      print('[MOCK] 🌐 WEB: SDK inicializado: ${ObslySDK.instance.isInitialized}');
      
      // Get intercepted HTTP client
      _client = ObslySDK.instance.httpClient;
      
      print('[MOCK] 🌐 WEB: Cliente HTTP obtenido: ${_client.runtimeType}');
      print('[MOCK] 🌐 WEB: Cliente hashCode: ${_client.hashCode}');
      print('[MOCK] 🌐 WEB: ¿Es ObslyHttpClient? ${_client.runtimeType.toString().contains('ObslyHttpClient')}');
    } else {
      // On native, standard client works (HttpOverrides intercepts automatically)
      print('[MOCK] 📱 NATIVE: Usando cliente HTTP estándar (intercepción automática via HttpOverrides)');
      _client = http.Client();
      print('[MOCK] 📱 NATIVE: Cliente HTTP: ${_client.runtimeType}');
      print('[MOCK] 📱 NATIVE: Cliente hashCode: ${_client.hashCode}');
    }
    
    print('[MOCK] ✅ CONSTRUCTOR: MockServerClient inicializado correctamente');
  }

  /// Simulates complete banking authentication flow
  Future<void> simulateAuthenticationFlow() async {
    print('[MOCK] Starting authentication flow...');
    
    // 1. Check server status
    await _makeRequest('GET', '${_endpoints[1]}/status/200', 
      headers: {'X-Auth-Step': 'server-check'});
    
    // 2. Get auth challenge
    await _makeRequest('POST', '${_endpoints[1]}/post', 
      body: {'action': 'get_challenge', 'user': 'test_user'},
      headers: {'X-Auth-Step': 'challenge'});
    
    // 3. Submit credentials
    await _makeRequest('POST', '${_endpoints[1]}/post', 
      body: {
        'username': 'test_user',
        'password': 'hashed_password_123',
        'challenge_response': 'challenge_token_456',
        'device_id': 'flutter_device_789'
      },
      headers: {'X-Auth-Step': 'credentials'});
    
    // 4. Validate 2FA
    await _makeRequest('POST', '${_endpoints[1]}/post', 
      body: {'token': '123456', 'session': 'temp_session_123'},
      headers: {'X-Auth-Step': '2fa-validation'});
    
    print('[MOCK] Authentication flow completed');
  }

  /// Simulates banking account operations
  Future<void> simulateBankingOperations() async {
    print('[MOCK] Starting banking operations...');
    
    // Get multiple accounts
    for (int i = 1; i <= 3; i++) {
      await _makeRequest('GET', '${_endpoints[0]}/posts/$i',
        headers: {
          'Authorization': 'Bearer auth_token_$i',
          'X-Account-Request': 'account-$i',
        });
    }
    
    // Simulated transfers
    await _makeRequest('POST', '${_endpoints[1]}/post',
      body: {
        'from_account': 'ES21-1234-5678-9012-3456',
        'to_account': 'ES21-9876-5432-1098-7654',
        'amount': '250.75',
        'concept': 'January 2024 Rent',
        'urgent': 'false'
      },
      headers: {'X-Transfer-Type': 'national'});
    
    // Pagos a proveedores
    await _makeRequest('POST', '${_endpoints[1]}/post',
      body: {
        'provider_id': 'PROV_001',
        'invoice_number': 'INV-2024-001',
        'amount': '1250.00',
        'due_date': '2024-02-15'
      },
      headers: {'X-Payment-Type': 'supplier'});
    
    print('[MOCK] Banking operations completed');
  }

  /// Simulates financial product queries
  Future<void> simulateFinancialProducts() async {
    print('[MOCK] Querying financial products...');
    
    // Credit cards
    await _makeRequest('GET', '${_endpoints[0]}/users/1/albums',
      headers: {'X-Product-Type': 'credit-cards'});
    
    // Préstamos activos
    await _makeRequest('GET', '${_endpoints[0]}/users/2/posts',
      headers: {'X-Product-Type': 'loans'});
    
    // Inversiones
    await _makeRequest('GET', '${_endpoints[2]}/users?page=1',
      headers: {'X-Product-Type': 'investments'});
    
    // Seguros
    await _makeRequest('GET', '${_endpoints[2]}/users?page=2',
      headers: {'X-Product-Type': 'insurance'});
    
    print('[MOCK] Financial products query completed');
  }

  /// Simulates banking notifications and alerts
  Future<void> simulateBankingNotifications() async {
    print('[MOCK] Fetching banking notifications...');
    
    // Alertas de seguridad
    await _makeRequest('GET', '${_endpoints[0]}/users/1/todos',
      headers: {'X-Notification-Type': 'security-alerts'});
    
    // Recent movements
    await _makeRequest('GET', '${_endpoints[0]}/users/2/todos',
      headers: {'X-Notification-Type': 'recent-movements'});
    
    // Promociones
    await _makeRequest('GET', '${_endpoints[2]}/users/3',
      headers: {'X-Notification-Type': 'promotions'});
    
    print('[MOCK] Banking notifications completed');
  }

  /// Simulates reports and analytics
  Future<void> simulateBankingReports() async {
    print('[MOCK] Generating banking reports...');
    
    // Reporte mensual
    await _makeRequest('POST', '${_endpoints[1]}/post',
      body: {
        'report_type': 'monthly',
        'period': '2024-01',
        'account_ids': ['ACC_001', 'ACC_002'],
        'include_categories': 'true'
      },
      headers: {'X-Report-Type': 'monthly-summary'});
    
    // Expense analytics
    await _makeRequest('POST', '${_endpoints[1]}/post',
      body: {
        'analysis_type': 'expense_patterns',
        'timeframe': '6_months',
        'categories': ['food', 'transport', 'utilities'],
      },
      headers: {'X-Analytics-Type': 'expense-analysis'});
    
    // Reporte de inversiones
    await _makeRequest('GET', '${_endpoints[3]}/repos/flutter/flutter',
      headers: {'X-Report-Type': 'investment-portfolio'});
    
    print('[MOCK] Banking reports completed');
  }

  /// Simulates errors and recovery
  Future<void> simulateErrorScenarios() async {
    print('[MOCK] Testing error scenarios...');
    
    try {
      // Error 400 - Bad Request
      await _makeRequest('GET', '${_endpoints[1]}/status/400',
        headers: {'X-Error-Test': 'bad-request'});
    } catch (e) {
      print('[MOCK] Handled 400 error: $e');
    }
    
    try {
      // Error 401 - Unauthorized
      await _makeRequest('GET', '${_endpoints[1]}/status/401',
        headers: {'X-Error-Test': 'unauthorized'});
    } catch (e) {
      print('[MOCK] Handled 401 error: $e');
    }
    
    try {
      // Error 500 - Server Error
      await _makeRequest('GET', '${_endpoints[1]}/status/500',
        headers: {'X-Error-Test': 'server-error'});
    } catch (e) {
      print('[MOCK] Handled 500 error: $e');
    }
    
    print('[MOCK] Error scenarios completed');
  }

  /// Executes a complete banking system simulation
  Future<void> runCompleteSimulation() async {
    print('[MOCK] ===== STARTING COMPLETE BANKING SIMULATION =====');
    
    try {
      await simulateAuthenticationFlow();
      await Future.delayed(const Duration(milliseconds: 500));
      
      await simulateBankingOperations();
      await Future.delayed(const Duration(milliseconds: 500));
      
      await simulateFinancialProducts();
      await Future.delayed(const Duration(milliseconds: 500));
      
      await simulateBankingNotifications();
      await Future.delayed(const Duration(milliseconds: 500));
      
      await simulateBankingReports();
      await Future.delayed(const Duration(milliseconds: 500));
      
      await simulateErrorScenarios();
      
      print('[MOCK] ===== BANKING SIMULATION COMPLETED =====');
    } catch (e) {
      print('[MOCK] Simulation error: $e');
    }
  }

  /// Ejecuta requests simultáneos (stress testing)
  Future<void> runConcurrentRequests() async {
    print('[MOCK] Running concurrent requests...');
    
    final futures = <Future>[];
    
    // 10 requests simultáneos
    for (int i = 0; i < 10; i++) {
      futures.add(_makeRequest('GET', '${_endpoints[0]}/posts/${i + 1}',
        headers: {'X-Concurrent-Test': 'request-$i'}));
    }
    
    await Future.wait(futures);
    print('[MOCK] Concurrent requests completed');
  }

  /// Helper para hacer requests con logging
  Future<http.Response> _makeRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final requestHeaders = {
      'Content-Type': 'application/json',
      'User-Agent': 'BankingApp/1.0 Mock',
      'X-Request-ID': 'req_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      'X-Session-ID': 'session_${_random.nextInt(10000)}',
      ...?headers,
    };

    print('[MOCK] 🚀 REQUEST: $method $url');
    print('[MOCK] 🔍 Cliente usado: ${_client.runtimeType} (hashCode: ${_client.hashCode})');
    print('[MOCK] 🔍 Headers: ${requestHeaders.length} headers');
    if (kIsWeb) {
      print('[MOCK] 🌐 WEB: Verifying HTTP interception...');
      print('[MOCK] 🌐 WEB: Client intercepted? ${_client.runtimeType.toString().contains('ObslyHttpClient')}');
    } else {
      print('[MOCK] 📱 NATIVE: HttpOverrides debería interceptar automáticamente');
    }
    
    http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await _client.get(uri, headers: requestHeaders);
        break;
      case 'POST':
        response = await _client.post(
          uri, 
          headers: requestHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await _client.put(
          uri, 
          headers: requestHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        response = await _client.delete(uri, headers: requestHeaders);
        break;
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
    
    print('[MOCK] ✅ RESPONSE: Status ${response.statusCode}, Body length: ${response.body.length}');
    print('[MOCK] ✅ Response headers: ${response.headers.length} headers');
    return response;
  }

  void dispose() {
    _client.close();
  }
}