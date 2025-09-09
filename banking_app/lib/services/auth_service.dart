import 'dart:math';

import 'package:banking_app/services/api_service.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:obsly_flutter/obsly_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';

  bool _isLoggedIn = false;
  String _userEmail = '';
  String _userId = '';
  bool _isInitialized = false;

  // API service instance for HTTP calls
  final ApiService _apiService = ApiService();

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  String get userId => _userId;
  bool get isInitialized => _isInitialized;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Initialize the auth service by loading stored session data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      _userEmail = prefs.getString(_userEmailKey) ?? '';
      _userId = prefs.getString(_userIdKey) ?? '';

      // If user was logged in, restore the session in Obsly SDK and app state
      if (_isLoggedIn && _userId.isNotEmpty) {
        await ObslySDK.instance.setUserID(_userId);
        AppState().initializeUserData(_userEmail);
        debugPrint('Auth session restored for user: $_userId');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Login with email and password using real HTTP API calls
  Future<bool> login(String email, String password) async {
    try {
      // Track login attempt
      await ObslySDK.instance.incCounter('login_attempt');
      await ObslySDK.instance.startHistogramTimer('operation_duration');

      debugPrint('[AUTH] Attempting login for user: $email');

      // Use ApiService.authenticateUser for real HTTP authentication
      final authResult = await _apiService.authenticateUser(email, password);
      final random = Random();
      final delay = random.nextDouble() * 1.8 + 0.2;
      await Future.delayed(Duration(milliseconds: (delay * 1000).toInt()));

      debugPrint('[AUTH] Authentication result: $authResult');

      // Check if authentication was successful
      if (authResult['success'] == true) {
        // Successful login
        _userEmail = email.trim();
        _userId = authResult['user_id'] ?? email.trim();
        _isLoggedIn = true;

        // Save session to persistent storage
        await _saveSession();

        // Set user in Obsly SDK
        await ObslySDK.instance.setUserID(_userId);
        await ObslySDK.instance.addTag([
          Tag(key: 'login_method', value: 'http_api'),
          Tag(key: 'auth_result', value: 'success'),
          Tag(key: 'test_status', value: authResult['test_status'] ?? 'normal'),
        ], 'auth');
        await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'success');

        // Initialize app state with user data
        AppState().initializeUserData(_userEmail);

        notifyListeners();
        debugPrint('[AUTH] ✅ User logged in successfully: $_userId');
        return true;
      } else if (authResult['success'] == false) {
        // Failed login (400 status code case)
        debugPrint('[AUTH] ❌ Login failed: ${authResult['message']}');

        await ObslySDK.instance.addTag([
          Tag(key: 'login_method', value: 'http_api'),
          Tag(key: 'auth_result', value: 'failed'),
          Tag(key: 'error_code', value: authResult['error_code'] ?? 'unknown'),
          Tag(key: 'test_status', value: authResult['test_status'] ?? 'normal'),
        ], 'auth');
        if (email == "crash") {
          await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'crash');
          return false;
        } else {
          await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'failure');
          return false;
        }
      }

      // Should not reach here, but handle unexpected cases
      await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'failure');
      return false;
    } catch (e) {
      // Handle server errors (500 status code case) and other exceptions
      debugPrint('[AUTH] 💥 Login error: $e');
      if (email == "fail") {
        await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'failure');
      } else if (email == "crash") {
        await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'crash');
      }
      await ObslySDK.instance.addTag([
        Tag(key: 'login_method', value: 'http_api'),
        Tag(key: 'auth_result', value: 'error'),
        Tag(key: 'error_message', value: e.toString()),
      ], 'auth');
      return false;
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      // Track logout in Obsly before clearing session
      if (_isLoggedIn) {
        await ObslySDK.instance.addTag([Tag(key: 'logout_method', value: 'manual')], 'auth');
        await ObslySDK.instance.closeCurrentSession();
        await ObslySDK.instance.setUserID('');
      }

      // Clear local state
      _isLoggedIn = false;
      _userEmail = '';
      _userId = '';

      // Clear persistent storage
      await _clearSession();

      // Clear app state
      AppState().clearUserData();

      notifyListeners();
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if there's an error, clear local state
      _isLoggedIn = false;
      _userEmail = '';
      _userId = '';
      await _clearSession();
      AppState().clearUserData();
      notifyListeners();
    }
  }

  /// Check if user has a valid session
  Future<bool> checkAuthStatus() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _isLoggedIn;
  }

  /// Save session data to persistent storage
  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, _isLoggedIn);
      await prefs.setString(_userEmailKey, _userEmail);
      await prefs.setString(_userIdKey, _userId);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  /// Clear session data from persistent storage
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  /// Dispose resources when auth service is no longer needed
  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
