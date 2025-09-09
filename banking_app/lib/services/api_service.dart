import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:obsly_flutter/obsly_sdk.dart';

/// Servicio de API para la aplicación bancaria
/// Contiene llamadas HTTP reales que serán interceptadas automáticamente por Obsly HTTPIntegration
class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _mockBankingApi = 'https://httpbin.org';

  // HTTP client - Platform-specific interception:
  // Web: Must use ObslySDK.instance.httpClient (special intercepted client required)
  // Native: Can use standard http.Client() (HttpOverrides intercepts automatically)
  late final http.Client _client;
  final Random _random = Random();

  /// Constructor - initializes HTTP client based on platform
  ApiService() {
    // Initialize API service with platform-specific HTTP client
    debugPrint('[API] Initializing ApiService for ${kIsWeb ? "WEB" : "NATIVE"} platform');

    if (kIsWeb) {
      // On web, MUST use the intercepted client from ObslySDK
      debugPrint('[API] WEB: SDK initialized: ${ObslySDK.instance.isInitialized}');

      // Get intercepted HTTP client
      _client = ObslySDK.instance.httpClient;

      debugPrint('[API] WEB: HTTP client type: ${_client.runtimeType}');
    } else {
      // On native, standard client works (HttpOverrides intercepts automatically)
      debugPrint('[API] NATIVE: Using standard HTTP client (automatic interception via HttpOverrides)');
      _client = http.Client();
      debugPrint('[API] NATIVE: HTTP client type: ${_client.runtimeType}');
    }

    debugPrint('[API] ApiService initialized successfully');
  }

  /// Generates a unique x-request-id to demonstrate header capture
  String _generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'req_${timestamp}_$randomPart';
  }

  /// Get account balance (simulated)
  Future<Map<String, dynamic>> getAccountBalance(String accountId) async {
    debugPrint('[API] Requesting balance for account: $accountId');
    final uri = Uri.parse('$_baseUrl/posts/$accountId');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer fake_token_$accountId',
        'X-Banking-Session': 'session_${DateTime.now().millisecondsSinceEpoch}',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    debugPrint('[API] Response: Status ${response.statusCode}, Body length: ${response.body.length}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'account_id': accountId,
        'balance': (data['id'] * 1000.50).toStringAsFixed(2),
        'currency': 'EUR',
        'last_updated': DateTime.now().toIso8601String(),
        'account_type': 'checking',
        'status': 'active',
      };
    } else {
      throw Exception('Failed to load balance: ${response.statusCode}');
    }
  }

  /// Get transaction history (simulated)
  Future<List<Map<String, dynamic>>> getTransactionHistory(String accountId) async {
    final uri = Uri.parse('$_baseUrl/posts?userId=$accountId');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer fake_token_$accountId',
        'X-Transaction-Request': 'history',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> posts = json.decode(response.body);
      return posts
          .take(5)
          .map((post) => {
                'transaction_id': 'tx_${post['id']}',
                'amount': (post['id'] * 25.75).toStringAsFixed(2),
                'description': '${post['title'].toString().substring(0, 30)}...',
                'date': DateTime.now().subtract(Duration(days: post['id'])).toIso8601String(),
                'type': post['id'] % 2 == 0 ? 'debit' : 'credit',
                'category': ['groceries', 'transport', 'entertainment', 'utilities'][post['id'] % 4],
              })
          .toList();
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode}');
    }
  }

  /// User authentication (simulated) - now with specific status code testing
  Future<Map<String, dynamic>> authenticateUser(String username, String password) async {
    // Determine status code based on username for testing purposes
    int statusCode = 200; // Default success
    String endpoint = 'post'; // Default endpoint

    // Special test cases using httpbin status endpoints
    if (username == 'failure') {
      statusCode = 400;
      endpoint = 'status/400'; // Use httpbin status endpoint for 400
    } else if (username == 'crash') {
      statusCode = 500;
      endpoint = 'status/500'; // Use httpbin status endpoint for 500
    } else {
      // For any other user (success case), use status/200
      endpoint = 'status/200';
    }

    final uri = Uri.parse('$_mockBankingApi/$endpoint');

    final requestBody = {
      'username': username,
      'password': password,
      'client_id': 'banking_app_flutter',
      'grant_type': 'password',
    };

    debugPrint('[API] Testing login for user: $username (expecting status: $statusCode)');

    http.Response response;

    if (endpoint.startsWith('status/')) {
      // For status endpoints, use GET request (httpbin requirement)
      response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Auth-Request': 'user_login_test',
          'X-Test-User': username,
          'User-Agent': 'BankingApp/1.0 Flutter',
          'x-request-id': _generateRequestId(),
          'X-API-Version': '2.1',
          'X-Expected-Status': statusCode.toString(),
        },
      );
    } else {
      // For normal endpoints, use POST request
      response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Auth-Request': 'user_login',
          'User-Agent': 'BankingApp/1.0 Flutter',
          'x-request-id': _generateRequestId(),
          'X-API-Version': '2.1',
        },
        body: json.encode(requestBody),
      );
    }

    debugPrint('[API] Login response: Status ${response.statusCode} for user $username');

    // Handle responses based on status code
    if (response.statusCode == 200) {
      return {
        'success': true,
        'access_token': 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': username.hashCode.toString(),
        'expires_in': 3600,
        'user_name': username,
        'account_number': 'ES21 1234 5678 9012 3456 7890',
        'test_status': 'SUCCESS - Status 200',
      };
    } else if (response.statusCode == 400) {
      return {
        'success': false,
        'error': 'Invalid credentials',
        'error_code': 'AUTH_FAILED',
        'message': 'Usuario NO_AUTH no autorizado',
        'test_status': 'ERROR - Status 400',
      };
    } else if (response.statusCode == 500) {
      throw Exception('Server error during authentication: Status 500 - Usuario CRASH causó error del servidor');
    } else {
      throw Exception('Authentication failed: ${response.statusCode}');
    }
  }

  /// Money transfer (simulated)
  Future<Map<String, dynamic>> transferMoney({
    required String fromAccount,
    required String toAccount,
    required double amount,
    required String description,
  }) async {
    final uri = Uri.parse('$_mockBankingApi/post');

    final requestBody = {
      'from_account': fromAccount,
      'to_account': toAccount,
      'amount': amount,
      'description': description,
      'currency': 'EUR',
      'transfer_type': 'instant',
      'timestamp': DateTime.now().toIso8601String(),
    };

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer fake_token_$fromAccount',
        'X-Transfer-Request': 'money_transfer',
        'X-Security-Level': 'high',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'transaction_id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'from_account': fromAccount,
        'to_account': toAccount,
        'amount': amount,
        'status': 'completed',
        'processing_time': '${(amount * 0.1).round()}ms',
      };
    } else {
      throw Exception('Transfer failed: ${response.statusCode}');
    }
  }

  /// Get card information (simulated)
  Future<List<Map<String, dynamic>>> getCards(String userId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/albums');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer fake_token_$userId',
        'X-Cards-Request': 'user_cards',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> albums = json.decode(response.body);
      return albums
          .take(3)
          .map((album) => {
                'card_id': 'card_${album['id']}',
                'card_number': '**** **** **** ${1000 + album['id']}',
                'card_type': ['visa', 'mastercard', 'amex'][album['id'] % 3],
                'balance': (album['id'] * 150.25).toStringAsFixed(2),
                'status': 'active',
                'expiry_date': '12/26',
              })
          .toList();
    } else {
      throw Exception('Failed to load cards: ${response.statusCode}');
    }
  }

  /// Get banking notifications (simulated)
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/todos');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer fake_token_$userId',
        'X-Notifications-Request': 'banking_alerts',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> todos = json.decode(response.body);
      return todos
          .take(5)
          .map((todo) => {
                'notification_id': 'notif_${todo['id']}',
                'title': todo['completed'] ? 'Payment Processed' : 'Payment Pending',
                'message': todo['title'],
                'type': todo['completed'] ? 'success' : 'warning',
                'timestamp': DateTime.now().subtract(Duration(hours: todo['id'])).toIso8601String(),
                'read': todo['completed'],
              })
          .toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  /// API connectivity test
  Future<Map<String, dynamic>> testApiConnectivity() async {
    final uri = Uri.parse('$_mockBankingApi/status/200');

    final response = await _client.get(
      uri,
      headers: {
        'X-Test-Request': 'connectivity_check',
        'User-Agent': 'BankingApp/1.0 Flutter Connectivity Test',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    return {
      'status': response.statusCode == 200 ? 'connected' : 'error',
      'status_code': response.statusCode,
      'response_time': DateTime.now().millisecondsSinceEpoch,
      'api_version': '1.0',
    };
  }

  /// Send multiple simultaneous requests (for interception testing)
  Future<List<Map<String, dynamic>>> performBulkApiCalls(String userId) async {
    debugPrint('[API] Starting bulk API calls for user: $userId');
    final futures = <Future<Map<String, dynamic>>>[];

    // Request simultáneos
    futures.add(getAccountBalance(userId));
    futures.add(authenticateUser('test_user', 'test_pass'));
    futures.add(testApiConnectivity());

    try {
      final results = await Future.wait(futures);
      debugPrint('[API] Bulk API calls completed: ${results.length} responses');
      return results;
    } catch (e) {
      debugPrint('[API] ❌ Error en bulk API calls: $e');
      throw Exception('Bulk API calls failed: $e');
    }
  }

  /// Simulate API error
  Future<void> simulateApiError() async {
    final uri = Uri.parse('$_mockBankingApi/status/500');

    final response = await _client.get(
      uri,
      headers: {
        'X-Test-Request': 'error_simulation',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Simulated API error: ${response.statusCode}');
    }
  }

  // ========== MÉTODOS DE PRUEBA HTTP ESPECÍFICOS ==========

  /// Test HTTP Login with Status 200 (Success) - Any user except NO_AUTH and CRASH
  Future<Map<String, dynamic>> testLoginSuccess(String username, String password) async {
    debugPrint('[API] 🧪 Testing successful login (Status 200) for user: $username');

    final uri = Uri.parse('$_mockBankingApi/status/200');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Request': 'test_login_success',
        'X-Test-User': username,
        'X-Test-Type': 'LOGIN_200',
        'User-Agent': 'BankingApp/1.0 Flutter',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    debugPrint('[API] ✅ Login success test response: Status ${response.statusCode}');

    if (response.statusCode == 200) {
      return {
        'success': true,
        'access_token': 'test_token_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': username.hashCode.toString(),
        'expires_in': 3600,
        'user_name': username,
        'account_number': 'ES21 1234 5678 9012 3456 7890',
        'test_type': 'LOGIN_SUCCESS_200',
        'test_result': 'PASSED',
      };
    } else {
      throw Exception('Test login success failed: Expected 200, got ${response.statusCode}');
    }
  }

  /// Test HTTP Login with Status 400 (Bad Request) - User NO_AUTH
  Future<Map<String, dynamic>> testLoginBadRequest() async {
    debugPrint('[API] 🧪 Testing login with Status 400 for NO_AUTH user');

    final uri = Uri.parse('$_mockBankingApi/status/400');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Request': 'test_login_400',
        'X-Test-User': 'NO_AUTH',
        'X-Test-Type': 'LOGIN_400',
        'User-Agent': 'BankingApp/1.0 Flutter',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    debugPrint('[API] ❌ Login 400 test response: Status ${response.statusCode}');

    if (response.statusCode == 400) {
      return {
        'success': false,
        'error': 'Bad Request',
        'error_code': 'INVALID_CREDENTIALS',
        'message': 'Usuario NO_AUTH no está autorizado',
        'test_type': 'LOGIN_BAD_REQUEST_400',
        'test_result': 'PASSED',
        'status_code': 400,
      };
    } else {
      throw Exception('Test login 400 failed: Expected 400, got ${response.statusCode}');
    }
  }

  /// Test HTTP Login with Status 500 (Server Error) - User CRASH
  Future<Map<String, dynamic>> testLoginServerError() async {
    debugPrint('[API] 🧪 Testing login with Status 500 for CRASH user');

    final uri = Uri.parse('$_mockBankingApi/status/500');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Request': 'test_login_500',
        'X-Test-User': 'CRASH',
        'X-Test-Type': 'LOGIN_500',
        'User-Agent': 'BankingApp/1.0 Flutter',
        'x-request-id': _generateRequestId(),
        'X-API-Version': '2.1',
      },
    );

    debugPrint('[API] 💥 Login 500 test response: Status ${response.statusCode}');

    if (response.statusCode == 500) {
      throw Exception('Server Error: Usuario CRASH causó error del servidor (Status 500) - Test PASSED');
    } else {
      throw Exception('Test login 500 failed: Expected 500, got ${response.statusCode}');
    }
  }

  /// Run all HTTP login tests sequentially
  Future<Map<String, dynamic>> runAllLoginTests() async {
    debugPrint('[API] 🧪 Running all HTTP login tests...');

    final results = <String, dynamic>{};

    try {
      // Test 1: Success (200)
      final successResult = await testLoginSuccess('test_user', 'test_pass');
      results['test_200'] = {
        'status': 'PASSED',
        'result': successResult,
        'description': 'Login with Status 200 for any user'
      };
    } catch (e) {
      results['test_200'] = {
        'status': 'FAILED',
        'error': e.toString(),
        'description': 'Login with Status 200 for any user'
      };
    }

    try {
      // Test 2: Bad Request (400)
      final badRequestResult = await testLoginBadRequest();
      results['test_400'] = {
        'status': 'PASSED',
        'result': badRequestResult,
        'description': 'Login with Status 400 for NO_AUTH user'
      };
    } catch (e) {
      results['test_400'] = {
        'status': 'FAILED',
        'error': e.toString(),
        'description': 'Login with Status 400 for NO_AUTH user'
      };
    }

    try {
      // Test 3: Server Error (500)
      await testLoginServerError();
      results['test_500'] = {
        'status': 'FAILED',
        'error': 'Expected exception but none was thrown',
        'description': 'Login with Status 500 for CRASH user'
      };
    } catch (e) {
      if (e.toString().contains('Status 500') && e.toString().contains('Test PASSED')) {
        results['test_500'] = {
          'status': 'PASSED',
          'result': 'Exception thrown as expected',
          'description': 'Login with Status 500 for CRASH user'
        };
      } else {
        results['test_500'] = {
          'status': 'FAILED',
          'error': e.toString(),
          'description': 'Login with Status 500 for CRASH user'
        };
      }
    }

    final passedTests = results.values.where((test) => test['status'] == 'PASSED').length;
    final totalTests = results.length;

    debugPrint('[API] ✅ HTTP login tests completed: $passedTests/$totalTests passed');

    return {
      'summary': {
        'total_tests': totalTests,
        'passed_tests': passedTests,
        'failed_tests': totalTests - passedTests,
        'success_rate': '${((passedTests / totalTests) * 100).toStringAsFixed(1)}%'
      },
      'tests': results,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose del cliente HTTP
  void dispose() {
    _client.close();
  }
}
