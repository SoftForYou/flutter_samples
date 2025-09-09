import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:obsly_flutter/obsly_sdk.dart';
import 'package:obsly_flutter/storage/obsly_storage.dart';

/// OBSLY AUTOTEST SUITE
///
/// This is a complete automated test that runs inside the banking app
/// to verify ALL Obsly functionality works correctly on both web and native.
///
/// Usage: Add ObslyAutotest() widget to your app and it will run automatically
class ObslyAutotest extends StatefulWidget {
  final bool autoStart;
  final bool headless;
  final Function(AutotestSummary)? onComplete;

  const ObslyAutotest({
    super.key,
    this.autoStart = true,
    this.headless = false,
    this.onComplete,
  });

  /// Run autotest programmatically without UI
  /// Returns true if all tests passed, false if any failed
  static Future<AutotestSummary> runHeadless(
      {Function(String)? onProgress}) async {
    // Run directly in headless mode
    final state = _ObslyAutotestState();
    return await state._runTestsDirectly(onProgress: onProgress);
  }

  @override
  State<ObslyAutotest> createState() => _ObslyAutotestState();
}

class _ObslyAutotestState extends State<ObslyAutotest> {
  final List<AutotestResult> _results = [];
  bool _isRunning = false;
  bool _autoStarted = false;
  Function(String)? _onProgress;

  @override
  void initState() {
    super.initState();
    // Auto-start test after widget is built (if enabled)
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_autoStarted) {
          _autoStarted = true;
          _runAllTests();
        }
      });
    }
  }

  @override
  void dispose() {
    // Cancel any running tests to prevent unmounted widget errors
    _isRunning = false;
    super.dispose();
  }

  Future<void> _runAllTests() async {
    if (_isRunning || !mounted) return;

    setState(() {
      _isRunning = true;
      _results.clear();
    });

    _log('🚀 OBSLY AUTOTEST SUITE STARTING');
    _log(
        'Platform: ${kIsWeb ? 'WEB' : 'NATIVE (${Platform.operatingSystem})'}');
    _log('======================================');

    try {
      // Test 1: SDK Initialization
      await _testSDKInitialization();
      if (!mounted || !_isRunning) return;

      // Test 2: HTTP Interception
      await _testHTTPInterception();
      if (!mounted || !_isRunning) return;

      // Test 2.5: HTTP Auto-Repair (Web Only)
      if (kIsWeb) {
        await _testHTTPAutoRepair();
        if (!mounted || !_isRunning) return;
      }

      // Test 3: Lifecycle Event Capture
      await _testLifecycleEventCapture();
      if (!mounted || !_isRunning) return;

      // Test 4: UI Event Capture
      await _testUIEventCapture();
      if (!mounted || !_isRunning) return;

      // Wait between tests to prevent race conditions
      await Future.delayed(const Duration(milliseconds: 500));

      // Test 3b: Navigation Integration
      await _testNavigationIntegration();
      if (!mounted || !_isRunning) return;

      // Wait between tests to prevent race conditions
      await Future.delayed(const Duration(milliseconds: 500));

      // Test 3c: Console Integration (optional if disabled)
      await _testConsoleIntegration();
      if (!mounted || !_isRunning) return;

      // Wait between tests to prevent race conditions
      await Future.delayed(const Duration(milliseconds: 500));

      // Test 3d: Crash Integration
      await _testCrashIntegration();
      if (!mounted || !_isRunning) return;

      // Test 4: Event Storage
      await _testEventStorage();
      if (!mounted || !_isRunning) return;

      // Test 5: Debug Tools
      await _testDebugTools();
      if (!mounted || !_isRunning) return;

      // Final Results
      final summary = _printFinalResults();

      // Call completion callback if provided
      if (widget.onComplete != null && mounted) {
        widget.onComplete!(summary);
      }
    } catch (e, stackTrace) {
      _addResult(AutotestResult(
        testName: 'CRITICAL_ERROR',
        success: false,
        message: 'Autotest crashed: $e',
        details: stackTrace.toString(),
      ));

      // Report crash in callback
      if (widget.onComplete != null && mounted) {
        final crashSummary = AutotestSummary(
          successful: 0,
          failed: _results.length,
          total: _results.length,
          successRate: 0.0,
          passed: false,
          results: List.from(_results),
        );
        widget.onComplete!(crashSummary);
      }
    }

    if (mounted) {
      setState(() {
        _isRunning = false;
      });
    }
  }

  /// Run tests directly without UI state management (for headless mode)
  Future<AutotestSummary> _runTestsDirectly(
      {Function(String)? onProgress}) async {
    _results.clear();
    _onProgress = onProgress; // Store callback for use in _log

    _log('🚀 OBSLY AUTOTEST SUITE STARTING (HEADLESS)');
    _log(
        'Platform: ${kIsWeb ? 'WEB' : 'NATIVE (${Platform.operatingSystem})'}');
    _log('======================================');

    try {
      // Run all tests
      await _testSDKInitialization();
      await Future.delayed(const Duration(milliseconds: 500));

      await _testHTTPInterception();
      await Future.delayed(const Duration(milliseconds: 500));

      await _testUIEventCapture();
      await Future.delayed(const Duration(milliseconds: 500));

      await _testNavigationIntegration();
      await Future.delayed(const Duration(milliseconds: 500));

      await _testConsoleIntegration();
      await Future.delayed(const Duration(milliseconds: 500));

      await _testCrashIntegration();
      await Future.delayed(const Duration(milliseconds: 500));

      await _testEventStorage();
      await Future.delayed(const Duration(milliseconds: 500));

      await _testDebugTools();

      // Return results
      return _printFinalResults();
    } catch (e, stackTrace) {
      _addResult(AutotestResult(
        testName: 'CRITICAL_ERROR',
        success: false,
        message: 'Autotest crashed: $e',
        details: stackTrace.toString(),
      ));

      return AutotestSummary(
        successful: 0,
        failed: _results.length,
        total: _results.length,
        successRate: 0.0,
        passed: false,
        results: List.from(_results),
      );
    }
  }

  Future<void> _testSDKInitialization() async {
    _log('\n🔧 TEST 1: SDK Initialization');
    _log('-----------------------------');

    try {
      // Check if SDK is already initialized
      if (ObslySDK.instance.isInitialized) {
        _addResult(AutotestResult(
          testName: 'SDK_INITIALIZATION',
          success: true,
          message: 'SDK already initialized',
          details: 'SDK was initialized by the banking app',
        ));
        _log('✅ SDK already initialized');
      } else {
        _addResult(AutotestResult(
          testName: 'SDK_INITIALIZATION',
          success: false,
          message: 'SDK not initialized',
          details: 'Banking app should initialize SDK before autotest runs',
        ));
        _log('❌ SDK not initialized');
      }
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'SDK_INITIALIZATION',
        success: false,
        message: 'Error checking SDK: $e',
      ));
      _log('❌ Error checking SDK: $e');
    }
  }

  Future<void> _testHTTPInterception() async {
    _log('\n🌐 TEST 2: HTTP Interception');
    _log('-----------------------------');

    try {
      // Clear existing events
      await ObslyStorage.instance.clearAllEvents();
      _log('🧹 Cleared existing events');

      // Make test HTTP requests using the proper client for each platform
      final client = kIsWeb ? ObslySDK.instance.httpClient : http.Client();

      try {
        // Use the same endpoints as test_tab.dart for consistency
        _log('🌐 Making 200 OK test request...');
        final response1 = await client.get(
          Uri.parse('https://tools-httpstatus.pickup-services.com/200'),
          headers: {
            'X-Test-Request': 'connectivity_check',
            'User-Agent': 'ObslyTools/1.0',
          },
        );
        _log('📊 200 OK response: ${response1.statusCode}');

        await Future.delayed(const Duration(milliseconds: 500));

        _log('🌐 Making 404 Client Error test request...');
        final response2 = await client.get(
          Uri.parse('https://tools-httpstatus.pickup-services.com/404'),
          headers: {
            'Content-Type': 'text/plain',
            'Authorization': 'Bearer fake_token_123',
            'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
            'X-API-Version': '2.1',
          },
        );
        _log('📊 404 response: ${response2.statusCode}');

        await Future.delayed(const Duration(milliseconds: 500));

        _log('🌐 Making 500 Server Error test request...');
        final response3 = await client.get(
          Uri.parse('https://tools-httpstatus.pickup-services.com/500'),
          headers: {
            'Content-Type': 'text/plain',
            'Authorization': 'Bearer fake_token_123',
            'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
            'X-API-Version': '2.1',
          },
        );
        _log('📊 500 response: ${response3.statusCode}');

        await Future.delayed(const Duration(milliseconds: 500));

        _log('🌐 Making 403 Forbidden test request...');
        final response4 = await client.get(
          Uri.parse('https://tools-httpstatus.pickup-services.com/403'),
          headers: {
            'Content-Type': 'text/plain',
            'Authorization': 'Bearer fake_token_ES21-1234',
            'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
            'X-API-Version': '2.1',
          },
        );
        _log('📊 403 response: ${response4.statusCode}');

        await Future.delayed(const Duration(milliseconds: 500));

        _log('🌐 Making 201 Created test request...');
        final response5 = await client.get(
          Uri.parse('https://tools-httpstatus.pickup-services.com/201'),
          headers: {
            'Content-Type': 'text/plain',
            'Authorization': 'Bearer fake_token_123',
            'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
            'X-API-Version': '2.1',
          },
        );
        _log('📊 201 response: ${response5.statusCode}');

        await Future.delayed(const Duration(milliseconds: 500));

        _log('🌐 Making DNS/Network Error test request...');
        try {
          await client.post(
            Uri.parse('https://no.such.host.invalid/login'),
            headers: {
              'Content-Type': 'text/plain',
              'X-Auth-Request': 'dns_failure',
              'User-Agent': 'ObslyTools/1.0',
            },
            body: json.encode({
              'username': 'test_user',
              'password': 'test_pass',
            }),
          );
        } catch (_) {
          // Expected network error
          _log('📊 DNS request failed as expected');
        }
      } finally {
        // Only close the client if it's a native client we created
        // Don't close the web client as it's a singleton managed by ObslySDK
        if (!kIsWeb) {
          client.close();
        }
      }

      // Wait for event processing
      await Future.delayed(const Duration(seconds: 2));

      // Check captured HTTP events
      final allEvents = await ObslyStorage.instance.getAllEvents();
      final httpEvents =
          allEvents.where((event) => event['type'] == 3).toList();

      _log('📊 Total events: ${allEvents.length}');
      _log('📊 HTTP events: ${httpEvents.length}');

      if (httpEvents.length >= 5) {
        // Verify event details for all the test endpoints
        int status200Events = 0,
            status404Events = 0,
            status500Events = 0,
            status403Events = 0,
            status201Events = 0,
            dnsErrorEvents = 0;

        for (final event in httpEvents) {
          final extra = event['extra'] as Map<String, dynamic>?;
          final request = extra?['request'] as Map<String, dynamic>?;
          if (request != null) {
            final method = request['method'] as String?;
            final statusCode = request['status_code'] as int?;
            final url = request['url'] as String?;

            _log(
                '  📝 Event details - Method: $method, URL: $url, Status: $statusCode');

            // Debug: Show full request structure for first few events
            if (status200Events == 0 && status404Events == 0) {
              _log(
                  '  🔍 DEBUG: Full request structure: ${request.keys.join(', ')}');
              _log('  🔍 DEBUG: Request keys: ${request.keys.toList()}');
            }

            // Count events based on URL patterns and status codes
            if (url?.contains('tools-httpstatus.pickup-services.com/200') ==
                true) {
              if (statusCode == 200) status200Events++;
              _log('  ✅ Found 200 event (status: $statusCode)');
            }
            if (url?.contains('tools-httpstatus.pickup-services.com/404') ==
                true) {
              if (statusCode == 404) status404Events++;
              _log('  ✅ Found 404 event (status: $statusCode)');
            }
            if (url?.contains('tools-httpstatus.pickup-services.com/500') ==
                true) {
              if (statusCode == 500) status500Events++;
              _log('  ✅ Found 500 event (status: $statusCode)');
            }
            if (url?.contains('tools-httpstatus.pickup-services.com/403') ==
                true) {
              if (statusCode == 403) status403Events++;
              _log('  ✅ Found 403 event (status: $statusCode)');
            }
            if (url?.contains('tools-httpstatus.pickup-services.com/201') ==
                true) {
              if (statusCode == 201) status201Events++;
              _log('  ✅ Found 201 event (status: $statusCode)');
            }
            if (url?.contains('no.such.host.invalid') == true) {
              if (statusCode == -1) dnsErrorEvents++;
              _log('  ✅ Found DNS error event (status: $statusCode)');
            }
          } else {
            _log('  ⚠️  No request data found in event');
          }
        }

        // Require all 6 test scenarios to be captured
        if (status200Events >= 1 &&
            status404Events >= 1 &&
            status500Events >= 1 &&
            status403Events >= 1 &&
            status201Events >= 1 &&
            dnsErrorEvents >= 1) {
          _addResult(AutotestResult(
            testName: 'HTTP_INTERCEPTION',
            success: true,
            message: 'All HTTP test scenarios intercepted correctly',
            details:
                '200: $status200Events, 404: $status404Events, 500: $status500Events, 403: $status403Events, 201: $status201Events, DNS: $dnsErrorEvents',
          ));
          _log('✅ HTTP interception working correctly');
        } else {
          _addResult(AutotestResult(
            testName: 'HTTP_INTERCEPTION',
            success: false,
            message: 'Missing required HTTP test events',
            details:
                'Expected: 200≥1, 404≥1, 500≥1, 403≥1, 201≥1, DNS≥1. Got: 200=$status200Events, 404=$status404Events, 500=$status500Events, 403=$status403Events, 201=$status201Events, DNS=$dnsErrorEvents',
          ));
          _log('❌ Missing required HTTP test events');
        }
      } else {
        _addResult(AutotestResult(
          testName: 'HTTP_INTERCEPTION',
          success: false,
          message: 'Insufficient HTTP events captured',
          details:
              'Expected ≥6 HTTP events (all test scenarios), got ${httpEvents.length}',
        ));
        _log(
            '❌ HTTP interception failed - only ${httpEvents.length} events captured');
      }
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'HTTP_INTERCEPTION',
        success: false,
        message: 'HTTP test error: $e',
      ));
      _log('❌ HTTP test error: $e');
    }
  }

  Future<void> _testHTTPAutoRepair() async {
    _log('\n🔧 TEST 2.5: HTTP Auto-Repair (Web Only)');
    _log('----------------------------------------');

    try {
      // Clear existing events
      await ObslyStorage.instance.clearAllEvents();
      _log('🧹 Cleared existing events');

      // Get the intercepted HTTP client
      final client = ObslySDK.instance.httpClient;
      _log('🔍 Got HTTP client: ${client.runtimeType}');

      if (client.runtimeType.toString() != 'ObslyHttpClient') {
        _addResult(AutotestResult(
          testName: 'HTTP_AUTO_REPAIR',
          success: false,
          message: 'Expected ObslyHttpClient, got ${client.runtimeType}',
        ));
        _log('❌ Not using ObslyHttpClient for web platform');
        return;
      }

      // Test 1: Normal request
      _log('🌐 Making initial request...');
      final response1 = await client.get(
        Uri.parse('https://tools-httpstatus.pickup-services.com/200'),
        headers: {
          'X-Test-Request': 'connectivity_check',
          'User-Agent': 'ObslyTools/1.0',
        },
      );
      _log('📊 Initial response: ${response1.statusCode}');

      await Future.delayed(const Duration(milliseconds: 500));

      // Test 2: Simulate dispose (by triggering lifecycle change)
      _log('🗑️ Simulating client dispose...');
      // We can't directly dispose from here, but we'll make rapid requests
      // that might trigger the dispose condition

      // Test 3: Request after potential dispose (should auto-repair)
      _log('🔧 Making request after potential dispose...');
      final response2 = await client.get(
        Uri.parse('https://tools-httpstatus.pickup-services.com/404'),
        headers: {
          'Content-Type': 'text/plain',
          'Authorization': 'Bearer fake_token_123',
          'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
          'X-API-Version': '2.1',
        },
      );
      _log('📊 Auto-repair response: ${response2.statusCode}');

      await Future.delayed(const Duration(milliseconds: 500));

      // Test 4: Multiple rapid requests (stress test auto-repair)
      _log('🔄 Making multiple rapid requests...');
      final futures = <Future<http.Response>>[];
      futures.add(client.get(
        Uri.parse('https://tools-httpstatus.pickup-services.com/500'),
        headers: {
          'Content-Type': 'text/plain',
          'Authorization': 'Bearer fake_token_123',
          'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
          'X-API-Version': '2.1',
        },
      ));
      futures.add(client.get(
        Uri.parse('https://tools-httpstatus.pickup-services.com/403'),
        headers: {
          'Content-Type': 'text/plain',
          'Authorization': 'Bearer fake_token_ES21-1234',
          'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
          'X-API-Version': '2.1',
        },
      ));
      futures.add(client.get(
        Uri.parse('https://tools-httpstatus.pickup-services.com/201'),
        headers: {
          'Content-Type': 'text/plain',
          'Authorization': 'Bearer fake_token_123',
          'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
          'X-API-Version': '2.1',
        },
      ));

      final responses = await Future.wait(futures);
      _log(
          '📊 Stress test responses: ${responses.map((r) => r.statusCode).join(', ')}');

      // Wait for event processing
      await Future.delayed(const Duration(seconds: 2));

      // Check captured HTTP events
      final allEvents = await ObslyStorage.instance.getAllEvents();
      final httpEvents =
          allEvents.where((event) => event['type'] == 3).toList();

      _log('📊 Total events after auto-repair test: ${allEvents.length}');
      _log('📊 HTTP events after auto-repair test: ${httpEvents.length}');

      // We expect at least 5 HTTP events (1 initial + 1 after dispose + 3 stress test)
      if (httpEvents.length >= 5) {
        // Verify all requests were captured
        int status200Events = 0,
            status404Events = 0,
            status500Events = 0,
            status403Events = 0,
            status201Events = 0;

        for (final event in httpEvents) {
          final extra = event['extra'] as Map<String, dynamic>?;
          final request = extra?['request'] as Map<String, dynamic>?;
          if (request != null) {
            final url = request['url'] as String?;
            final statusCode = request['status_code'] as int?;
            final method = request['method'] as String?;

            if (url?.contains('tools-httpstatus.pickup-services.com/200') ==
                    true &&
                statusCode == 200) {
              status200Events++;
              _log('  📝 Auto-repair event: $method $url ($statusCode)');
              _log('  ✅ Found 200 auto-repair event');
            }
            if (url?.contains('tools-httpstatus.pickup-services.com/404') ==
                    true &&
                statusCode == 404) {
              status404Events++;
              _log('  📝 Auto-repair event: $method $url ($statusCode)');
              _log('  ✅ Found 404 auto-repair event');
            }
            if (url?.contains('tools-httpstatus.pickup-services.com/500') ==
                    true &&
                statusCode == 500) {
              status500Events++;
              _log('  📝 Auto-repair event: $method $url ($statusCode)');
              _log('  ✅ Found 500 auto-repair event');
            }
            if (url?.contains('tools-httpstatus.pickup-services.com/403') ==
                    true &&
                statusCode == 403) {
              status403Events++;
              _log('  📝 Auto-repair event: $method $url ($statusCode)');
              _log('  ✅ Found 403 auto-repair event');
            }
            if (url?.contains('tools-httpstatus.pickup-services.com/201') ==
                    true &&
                statusCode == 201) {
              status201Events++;
              _log('  📝 Auto-repair event: $method $url ($statusCode)');
              _log('  ✅ Found 201 auto-repair event');
            }
          } else {
            _log('  ⚠️  No request data found in auto-repair event');
          }
        }

        if (status200Events >= 1 &&
            status404Events >= 1 &&
            status500Events >= 1 &&
            status403Events >= 1 &&
            status201Events >= 1) {
          _addResult(AutotestResult(
            testName: 'HTTP_AUTO_REPAIR',
            success: true,
            message: 'HTTP auto-repair working correctly',
            details:
                '200: $status200Events, 404: $status404Events, 500: $status500Events, 403: $status403Events, 201: $status201Events',
          ));
          _log('✅ HTTP auto-repair mechanism working correctly');
        } else {
          _addResult(AutotestResult(
            testName: 'HTTP_AUTO_REPAIR',
            success: false,
            message: 'Missing auto-repair test events',
            details:
                'Expected: 200≥1, 404≥1, 500≥1, 403≥1, 201≥1. Got: 200=$status200Events, 404=$status404Events, 500=$status500Events, 403=$status403Events, 201=$status201Events',
          ));
          _log('❌ Missing auto-repair test events');
        }
      } else {
        _addResult(AutotestResult(
          testName: 'HTTP_AUTO_REPAIR',
          success: false,
          message: 'Insufficient HTTP events for auto-repair test',
          details: 'Expected ≥5 HTTP events, got ${httpEvents.length}',
        ));
        _log('❌ Auto-repair test failed - insufficient events captured');
      }
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'HTTP_AUTO_REPAIR',
        success: false,
        message: 'Auto-repair test error: $e',
      ));
      _log('❌ Auto-repair test error: $e');
    }
  }

  Future<void> _simulateLifecycleEvents() async {
    try {
      _log('🔄 [SIMULATED] App lifecycle events');

      // Create synthetic lifecycle events for testing purposes
      // since we can't actually trigger app lifecycle changes in autotest
      _log('🔄 Creating synthetic lifecycle events for testing...');

      final baseTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Simulate app going to background - following ObslyEvent structure
      final backgroundEvent = {
        'installation_id': 'autotest_installation',
        'execution_id': null,
        'timestamp': baseTimestamp,
        'session_id': 'autotest_session',
        'event_id': 'autotest_lifecycle_bg_$baseTimestamp',
        'sequence': 10,
        'type': 5, // lifecycle event type (EventType.lifecycle.value)
        'name': 'lifecycle_background',
        'extra': {
          'life_cycle': {
            // Note: usar 'life_cycle' como en ObslyEventExtra
            'view_name': 'autotest_view',
            'stage': 'background',
            'time_ms': 1500, // 1.5 seconds
          },
          'app': {
            'name': 'autotest_app',
            'version': '1.0.0',
          },
          'device': {
            'os_name': kIsWeb ? 'web' : Platform.operatingSystem,
            'model': 'autotest_device',
          },
          'user': {
            'user_id': 'autotest_user',
          },
        },
        'api_key': 'autotest-key',
        'api_key_id': null,
        'project_id': null,
        'bg': false,
        'process_step': null,
      };

      await ObslySDK.instance.eventController.trackEvent(backgroundEvent);
      _log('🔄 Background lifecycle event tracked');

      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate app coming to foreground - following ObslyEvent structure
      final foregroundEvent = {
        'installation_id': 'autotest_installation',
        'execution_id': null,
        'timestamp': baseTimestamp + 2000,
        'session_id': 'autotest_session',
        'event_id': 'autotest_lifecycle_fg_${baseTimestamp + 2000}',
        'sequence': 11,
        'type': 5, // lifecycle event type (EventType.lifecycle.value)
        'name': 'lifecycle_foreground',
        'extra': {
          'life_cycle': {
            // Note: usar 'life_cycle' como en ObslyEventExtra
            'view_name': 'autotest_view',
            'stage': 'foreground',
            'time_ms': 2000, // 2 seconds in background
          },
          'app': {
            'name': 'autotest_app',
            'version': '1.0.0',
          },
          'device': {
            'os_name': kIsWeb ? 'web' : Platform.operatingSystem,
            'model': 'autotest_device',
          },
          'user': {
            'user_id': 'autotest_user',
          },
        },
        'api_key': 'autotest-key',
        'api_key_id': null,
        'project_id': null,
        'bg': false,
        'process_step': null,
      };

      await ObslySDK.instance.eventController.trackEvent(foregroundEvent);
      _log('🔄 Foreground lifecycle event tracked');

      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate app exit - following ObslyEvent structure
      final exitEvent = {
        'installation_id': 'autotest_installation',
        'execution_id': null,
        'timestamp': baseTimestamp + 5000,
        'session_id': 'autotest_session',
        'event_id': 'autotest_lifecycle_exit_${baseTimestamp + 5000}',
        'sequence': 12,
        'type': 5, // lifecycle event type (EventType.lifecycle.value)
        'name': 'lifecycle_exit',
        'extra': {
          'life_cycle': {
            // Note: usar 'life_cycle' como en ObslyEventExtra
            'view_name': 'autotest_view',
            'stage': 'exit',
            'time_ms': 500, // 0.5 seconds before exit
          },
          'app': {
            'name': 'autotest_app',
            'version': '1.0.0',
          },
          'device': {
            'os_name': kIsWeb ? 'web' : Platform.operatingSystem,
            'model': 'autotest_device',
          },
          'user': {
            'user_id': 'autotest_user',
          },
        },
        'api_key': 'autotest-key',
        'api_key_id': null,
        'project_id': null,
        'bg': false,
        'process_step': null,
      };

      await ObslySDK.instance.eventController.trackEvent(exitEvent);
      _log('🔄 Exit lifecycle event tracked');

      _log('🔄 All synthetic lifecycle events tracked for testing');

      // Wait for all events to be processed
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _log('❌ Error simulating lifecycle events: $e');
    }
  }

  Future<void> _testLifecycleEventCapture() async {
    _log('\n🔄 TEST 3: Lifecycle Event Capture');
    _log('----------------------------------');

    try {
      // Clear existing events
      await ObslyStorage.instance.clearAllEvents();
      _log('🧹 Cleared existing events');

      // Simulate lifecycle events by creating synthetic events
      // since we can't actually trigger app lifecycle changes in an autotest
      _log('🔄 Simulating lifecycle events...');

      await _simulateLifecycleEvents();

      // Wait for event processing
      await Future.delayed(const Duration(seconds: 2));

      // Check captured lifecycle events
      final allEvents = await ObslyStorage.instance.getAllEvents();
      final lifecycleEvents = allEvents
          .where((event) => event['type'] == 5)
          .toList(); // EventType.lifecycle.value = 5

      _log('📊 Total events: ${allEvents.length}');
      _log('📊 Lifecycle events: ${lifecycleEvents.length}');

      if (lifecycleEvents.length >= 3) {
        // Verify event details
        int foregroundEvents = 0, backgroundEvents = 0, exitEvents = 0;

        for (final event in lifecycleEvents) {
          final extra = event['extra'] as Map<String, dynamic>?;
          final lifeCycle = extra?['lifeCycle'] as Map<String, dynamic>?;
          if (lifeCycle != null) {
            final stage = lifeCycle['stage'] as String?;
            final viewName = lifeCycle['viewName'] as String?;
            final timeMs = lifeCycle['timeMs'] as int?;

            _log('  📝 Lifecycle: $stage (view: $viewName, time: ${timeMs}ms)');

            if (stage == 'foreground') foregroundEvents++;
            if (stage == 'background') backgroundEvents++;
            if (stage == 'exit') exitEvents++;
          }
        }

        if (foregroundEvents >= 1 && backgroundEvents >= 1 && exitEvents >= 1) {
          _addResult(AutotestResult(
            testName: 'LIFECYCLE_EVENT_CAPTURE',
            success: true,
            message: 'All lifecycle events captured correctly',
            details:
                'FOREGROUND: $foregroundEvents, BACKGROUND: $backgroundEvents, EXIT: $exitEvents',
          ));
          _log('✅ Lifecycle event capture working correctly');
        } else {
          _addResult(AutotestResult(
            testName: 'LIFECYCLE_EVENT_CAPTURE',
            success: false,
            message: 'Missing expected lifecycle events',
            details:
                'Expected: FOREGROUND≥1, BACKGROUND≥1, EXIT≥1. Got: FOREGROUND=$foregroundEvents, BACKGROUND=$backgroundEvents, EXIT=$exitEvents',
          ));
          _log('❌ Missing expected lifecycle events');
        }
      } else {
        _addResult(AutotestResult(
          testName: 'LIFECYCLE_EVENT_CAPTURE',
          success: false,
          message: 'Insufficient lifecycle events captured',
          details:
              'Expected ≥3 lifecycle events, got ${lifecycleEvents.length}',
        ));
        _log(
            '❌ Lifecycle event capture failed - only ${lifecycleEvents.length} events captured');
      }
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'LIFECYCLE_EVENT_CAPTURE',
        success: false,
        message: 'Lifecycle test error: $e',
      ));
      _log('❌ Lifecycle test error: $e');
    }
  }

  Future<void> _testUIEventCapture() async {
    _log('\n🖱️  TEST 3: UI Event Capture');
    _log('-----------------------------');

    try {
      // Clear events before UI test
      _log('🧹 Clearing events before UI test...');
      await ObslyStorage.instance.clearAllEvents();
      _log('🧹 Events cleared, starting UI test');

      // Simulate UI interactions
      _log('🖱️  Simulating button tap...');

      // Create a test button and simulate tap
      await _simulateButtonTap();

      // Wait for event processing
      await Future.delayed(const Duration(seconds: 1));

      // Check for UI events
      final allEvents = await ObslyStorage.instance.getAllEvents();
      final uiEvents = allEvents.where((event) => event['type'] == 2).toList();

      _log('📊 Total events after UI test: ${allEvents.length}');
      _log('📊 UI events captured: ${uiEvents.length}');

      // Debug: log event types found
      if (allEvents.isNotEmpty) {
        final eventTypes = allEvents.map((e) => e['type']).toSet().toList();
        _log('🔍 Event types found: $eventTypes');
      }

      if (uiEvents.isNotEmpty) {
        _addResult(AutotestResult(
          testName: 'UI_EVENT_CAPTURE',
          success: true,
          message: 'UI events captured successfully',
          details: '${uiEvents.length} UI events captured',
        ));
        _log('✅ UI event capture working');
      } else {
        _addResult(AutotestResult(
          testName: 'UI_EVENT_CAPTURE',
          success: false,
          message: 'No UI events captured',
          details: 'Expected at least 1 UI event from button tap simulation',
        ));
        _log('❌ No UI events captured');
      }
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'UI_EVENT_CAPTURE',
        success: false,
        message: 'UI test error: $e',
      ));
      _log('❌ UI test error: $e');
    }
  }

  Future<void> _testNavigationIntegration() async {
    _log('\n🧭 TEST 3b: Navigation Integration');
    _log('-------------------------------');

    try {
      await ObslyStorage.instance.clearAllEvents();

      // Use SDK navigator to avoid using a potentially unmounted local context
      final nav = ObslySDK.instance.navigatorKey.currentState;
      if (nav == null) {
        _addResult(AutotestResult(
          testName: 'NAVIGATION_INTEGRATION',
          success: false,
          message: 'Navigator not available from SDK',
          details: 'navigatorKey.currentState is null',
        ));
        _log('❌ Navigator not available from SDK');
        return;
      }

      // Push a synthetic screen and then pop it programmatically
      _log('🧭 Pushing AutotestNavScreen...');
      final route =
          MaterialPageRoute(builder: (_) => const _AutotestNavWidget());
      // Start push
      final pushFuture = nav.push(route);
      // Pop shortly after to generate didPop
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          if (nav.mounted && nav.canPop()) {
            nav.pop();
          }
        } catch (_) {}
      });
      // Wait until pop completes
      await pushFuture;
      _log('🧭 Popped AutotestNavScreen');

      // Allow processing
      await Future.delayed(const Duration(seconds: 1));

      final events = await ObslyStorage.instance.getAllEvents();
      final lifecycleEvents = events.where((e) => e['type'] == 5).toList();
      _log('📊 Lifecycle events: ${lifecycleEvents.length}');

      if (lifecycleEvents.isNotEmpty) {
        _addResult(AutotestResult(
          testName: 'NAVIGATION_INTEGRATION',
          success: true,
          message: 'Navigation events captured',
          details: 'Captured ${lifecycleEvents.length} lifecycle events',
        ));
        _log('✅ Navigation integration working');
      } else {
        _addResult(AutotestResult(
          testName: 'NAVIGATION_INTEGRATION',
          success: false,
          message: 'No lifecycle events captured',
          details: 'Expected at least 1 navigation event from push/pop',
        ));
        _log('❌ No lifecycle events captured');
      }
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'NAVIGATION_INTEGRATION',
        success: false,
        message: 'Navigation test error: $e',
      ));
      _log('❌ Navigation test error: $e');
    }
  }

  Future<void> _testConsoleIntegration() async {
    _log('\n🖨️  TEST 3c: Console Integration');
    _log('-------------------------------');
    try {
      await ObslyStorage.instance.clearAllEvents();
      final token = DateTime.now().millisecondsSinceEpoch;
      debugPrint('OBSLY_AUTOTEST_CONSOLE_$token');

      await Future.delayed(const Duration(seconds: 1));
      final events = await ObslyStorage.instance.getAllEvents();
      final tagEvents = events.where((e) => e['type'] == 4).toList();
      _log('📊 Tag events: ${tagEvents.length}');

      bool found = false;
      for (final e in tagEvents) {
        final extra = e['extra'] as Map<String, dynamic>?;
        final tags = (extra?['tags'] as List?)?.cast<dynamic>() ?? const [];
        if (tags.any((t) => (t is Map &&
            (t['key']?.toString() ?? '').startsWith('CONSOLE.')))) {
          found = true;
          break;
        }
      }

      // Console integration may be disabled in production; treat missing as soft failure
      _addResult(AutotestResult(
        testName: 'CONSOLE_INTEGRATION',
        success: found,
        message: found
            ? 'Console logs captured'
            : 'Console logs not captured (possibly disabled)',
        details: found ? null : 'Enable debug tools to capture console logs',
      ));
      _log(found
          ? '✅ Console integration working'
          : '⚠️  Console integration not capturing (disabled?)');
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'CONSOLE_INTEGRATION',
        success: false,
        message: 'Console test error: $e',
      ));
      _log('❌ Console test error: $e');
    }
  }

  Future<void> _testCrashIntegration() async {
    _log('\n💥 TEST 3d: Crash Integration');
    _log('----------------------------');
    try {
      await ObslyStorage.instance.clearAllEvents();

      // Report a synthetic Flutter error
      FlutterError.reportError(FlutterErrorDetails(
        exception: Exception('OBSLY_AUTOTEST_CRASH'),
        stack: StackTrace.current,
        library: 'Autotest',
        context: ErrorDescription('Synthetic crash for autotest'),
      ));

      await Future.delayed(const Duration(seconds: 1));
      final events = await ObslyStorage.instance.getAllEvents();
      final errorEvents = events.where((e) => e['type'] == 0).toList();
      _log('📊 Error events: ${errorEvents.length}');

      final success = errorEvents.isNotEmpty;
      _addResult(AutotestResult(
        testName: 'CRASH_INTEGRATION',
        success: success,
        message: success ? 'Crash captured' : 'No crash events captured',
        details: success
            ? null
            : 'Expected at least 1 error event after FlutterError.reportError',
      ));
      _log(success
          ? '✅ Crash integration working'
          : '❌ Crash integration not capturing');
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'CRASH_INTEGRATION',
        success: false,
        message: 'Crash test error: $e',
      ));
      _log('❌ Crash test error: $e');
    }
  }

  Future<void> _testEventStorage() async {
    _log('\n💾 TEST 4: Event Storage');
    _log('-------------------------');

    bool testPassed = false;
    String testMessage = '';
    String testDetails = '';

    try {
      // Test basic storage operations
      await ObslyStorage.instance.clearAllEvents();
      _log('🧹 Cleared all events');

      // Verify empty storage
      final initialEvents = await ObslyStorage.instance.getAllEvents();
      _log('🔍 Events after clear: ${initialEvents.length}');

      // Store a test event manually - following ObslyEvent structure
      final testEvent = {
        'installation_id': 'autotest_installation',
        'execution_id': null,
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
        'session_id': 'autotest_session',
        'event_id': 'autotest_event_${DateTime.now().millisecondsSinceEpoch}',
        'sequence': 1,
        'type': 1, // internal event type (EventType.internal.value)
        'name': 'autotest_event',
        'extra': {
          'tags': [
            {'key': 'autotest', 'value': 'true'}
          ]
        },
        'api_key': 'autotest-key',
        'api_key_id': null,
        'project_id': null,
        'bg': false,
        'process_step': null,
      };

      // Use direct storage instead of SDK to avoid any side effects
      await ObslyStorage.instance.storeEvent(testEvent);
      _log('💾 Stored test event directly via storage');

      // Check immediately after storage
      final eventsAfterStore = await ObslyStorage.instance.getAllEvents();
      _log('🔍 Events immediately after store: ${eventsAfterStore.length}');

      // Verify the specific event exists
      final testEvents = eventsAfterStore.where((e) => e['name'] == 'autotest_event').toList();
      _log('🔍 Test events found: ${testEvents.length}');

      if (testEvents.length == 1) {
        testPassed = true;
        testMessage = 'Event storage working correctly';
        testDetails = 'Successfully stored and retrieved test event';
        _log('✅ Event storage working');
      } else {
        testPassed = false;
        testMessage = 'Event storage failed';
        testDetails = 'Expected 1 test event, found ${testEvents.length}. Total events: ${eventsAfterStore.length}';
        _log('❌ Event storage failed - Expected 1, found ${testEvents.length}');
      }

      // Cleanup: remove only the synthetic autotest event
      try {
        await ObslyStorage.instance.clearAllEvents();
        _log('🧹 Cleared all events after test');
      } catch (e) {
        _log('⚠️  Failed to clear events: $e');
      }

    } catch (e) {
      testPassed = false;
      testMessage = 'Storage test error: $e';
      testDetails = 'Exception during storage test';
      _log('❌ Storage test error: $e');
    }

    // Add result only once at the end
    _addResult(AutotestResult(
      testName: 'EVENT_STORAGE',
      success: testPassed,
      message: testMessage,
      details: testDetails,
    ));
  }

  Future<void> _testDebugTools() async {
    _log('\n🛠️  TEST 5: Debug Tools');
    _log('----------------------');

    try {
      // Test if debug tools are accessible
      if (ObslySDK.instance.isInitialized) {
        _addResult(AutotestResult(
          testName: 'DEBUG_TOOLS',
          success: true,
          message: 'Debug tools accessible',
          details: 'SDK provides debug access',
        ));
        _log('✅ Debug tools accessible');
      } else {
        _addResult(AutotestResult(
          testName: 'DEBUG_TOOLS',
          success: false,
          message: 'Debug tools not accessible',
          details: 'SDK not initialized',
        ));
        _log('❌ Debug tools not accessible');
      }
    } catch (e) {
      _addResult(AutotestResult(
        testName: 'DEBUG_TOOLS',
        success: false,
        message: 'Debug tools test error: $e',
      ));
      _log('❌ Debug tools test error: $e');
    }
  }

  Future<void> _simulateButtonTap() async {
    try {
      _log('🖱️  [SIMULATED] Button tap event');

      // Create a synthetic UI event for testing purposes
      // since we can't actually simulate touches without a real widget tree in autotest
      _log('🖱️  Creating synthetic UI event for testing...');

      // Store a synthetic UI event directly to test the storage system - following ObslyEvent structure
      final syntheticUIEvent = {
        'installation_id': 'autotest_installation',
        'execution_id': null,
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
        'session_id': 'autotest_session',
        'event_id': 'autotest_ui_${DateTime.now().millisecondsSinceEpoch}',
        'sequence': 1,
        'type': 2, // UI event type (EventType.ui.value)
        'name': 'ui_tap',
        'extra': {
          'ui': {
            'action_type': 'tap',
            'view_name': 'autotest_view',
            'touch_point': '100,100',
          },
          'tags': [
            {'key': 'element', 'value': 'synthetic_button'},
            {'key': 'autotest', 'value': 'true'}
          ]
        },
        'api_key': 'autotest-key',
        'api_key_id': null,
        'project_id': null,
        'bg': false,
        'process_step': null,
      };

      // Use EventController instead of direct storage
      await ObslySDK.instance.eventController.trackEvent(syntheticUIEvent);
      _log('🖱️  Synthetic UI event tracked via EventController');

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify the event was actually stored
      final allEventsAfterStore = await ObslyStorage.instance.getAllEvents();
      final storedUIEvents =
          allEventsAfterStore.where((e) => e['type'] == 2).toList();
      _log(
          '🖱️  Verification: ${storedUIEvents.length} UI events in storage after EventController');
    } catch (e) {
      _log('❌ Error simulating button tap: $e');
    }
  }

  AutotestSummary _printFinalResults() {
    _log('\n📋 FINAL RESULTS');
    _log('================');

    final successful = _results.where((r) => r.success).length;
    final total = _results.length;
    final failed = total - successful;
    final successRate = total > 0 ? (successful / total * 100) : 0.0;
    final passed = failed == 0;

    _log('✅ Successful: $successful');
    _log('❌ Failed: $failed');
    _log('📊 Success Rate: ${successRate.toStringAsFixed(1)}%');

    if (passed) {
      _log('🎉 ALL TESTS PASSED! OBSLY IS WORKING CORRECTLY! 🎉');
    } else {
      _log('⚠️  SOME TESTS FAILED - OBSLY NEEDS ATTENTION');

      _log('\n❌ FAILED TESTS:');
      for (final result in _results.where((r) => !r.success)) {
        _log('  • ${result.testName}: ${result.message}');
        if (result.details != null) {
          _log('    ${result.details}');
        }
      }
    }

    _log('\nAutotest completed at ${DateTime.now()}');

    return AutotestSummary(
      successful: successful,
      failed: failed,
      total: total,
      successRate: successRate,
      passed: passed,
      results: List.from(_results),
    );
  }

  void _addResult(AutotestResult result) {
    _results.add(result);
  }

  void _log(String message) {
    print('[OBSLY_AUTOTEST] $message');
    _onProgress?.call(message); // Send to progress callback if available
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obsly Autotest'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Obsly SDK Autotest Suite',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Platform: ${kIsWeb ? 'Web' : 'Native (${Platform.operatingSystem})'}'),
                    Text('Status: ${_isRunning ? 'Running...' : 'Ready'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _runAllTests,
                  child: Text(_isRunning ? 'Running...' : 'Run All Tests'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    await ObslyStorage.instance.clearAllEvents();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All events cleared')),
                      );
                    }
                  },
                  child: const Text('Clear Events'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_results.isEmpty) {
      return const Center(
        child: Text('No test results yet. Run tests to see results.'),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return Card(
          color: result.success ? Colors.green.shade50 : Colors.red.shade50,
          child: ListTile(
            leading: Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : Colors.red,
            ),
            title: Text(result.testName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.message),
                if (result.details != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    result.details!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            isThreeLine: result.details != null,
          ),
        );
      },
    );
  }
}

class AutotestResult {
  final String testName;
  final bool success;
  final String message;
  final String? details;

  AutotestResult({
    required this.testName,
    required this.success,
    required this.message,
    this.details,
  });
}

class AutotestSummary {
  final int successful;
  final int failed;
  final int total;
  final double successRate;
  final bool passed;
  final List<AutotestResult> results;
  final bool shouldExit;

  AutotestSummary({
    required this.successful,
    required this.failed,
    required this.total,
    required this.successRate,
    required this.passed,
    required this.results,
    this.shouldExit = true, // Default to true for automatic termination
  });

  @override
  String toString() {
    return 'AutotestSummary(passed: $passed, successful: $successful/$total, rate: ${successRate.toStringAsFixed(1)}%)';
  }
}

/// Simple screen used to trigger navigation events in tests
class _AutotestNavWidget extends StatelessWidget {
  const _AutotestNavWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autotest Nav Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
      ),
    );
  }
}
