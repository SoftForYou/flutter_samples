import 'dart:async';
import 'dart:io';

import 'package:banking_app/models/account.dart';
import 'package:banking_app/models/card.dart';
import 'package:banking_app/screens/account_details_screen.dart';
import 'package:banking_app/screens/card_details_screen.dart';
import 'package:banking_app/screens/metrics_test_screen.dart';
import 'package:banking_app/screens/performance_test_screen.dart';
import 'package:banking_app/screens/piggybanks_screen.dart';
import 'package:banking_app/screens/transfer_screen.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:banking_app/services/auth_service.dart';
import 'package:banking_app/utils/screen_timing_observer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obsly_flutter/obsly_sdk.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with ScreenTimingMixin {
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupObslyTracking();

    // 🎯 Detectar si llegamos por deeplink y medir timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScreenTimingObserver().detectAndMeasureInitialRoute(context);
    });
  }

  void _setupObslyTracking() async {
    // 🕐 Ejemplo de uso del mixin ScreenTimingMixin para medir cuando la pantalla es usable
    // Mide el tiempo hasta que el usuario puede interactuar - PageLoadUsable
    await measureFunction(() async {
      try {
        // Set up tracking for the main dashboard
        await ObslySDK.instance.setView('dashboard_screen');
        await ObslySDK.instance.setOperation('financial_overview');
        await ObslySDK.instance.setFunctionalBlock('dashboard');

        // Simular carga de datos que hace la pantalla usable
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        debugPrint('Error setting up Obsly tracking: $e');
        rethrow; // Importante para que measureFunction capture el error
      }
    }, 'dashboard_usable', state: 'ready');
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home - do nothing
        break;
      case 1:
        // Navigation to Accounts (placeholder for now)
        _showFeatureNotImplemented('Accounts');
        break;
      case 2:
        // Navigation to Profile (placeholder for now)
        _showFeatureNotImplemented('Profile');
        break;
      case 3:
        // Show testing menu (Metrics and Performance)
        _showTestingMenu();
        break;
    }
  }

  void _showTestingMenu() {
    // Reset navigation index
    setState(() {
      _currentBottomNavIndex = 0;
    });

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SDK Testing',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: const Text('Metrics Tests'),
                subtitle: const Text('Test counters, gauges, and histograms'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/metrics-test'),
                      builder: (context) => const MetricsTestScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.speed, color: Colors.orange),
                title: const Text('Performance Tests'),
                subtitle: const Text('Test transactions and steps'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/performance-test'),
                      builder: (context) => const PerformanceTestScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: const Text('Error Tests'),
                subtitle: const Text('Test async error capture with Zone'),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorTestDialog();
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFeatureNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"$feature" feature not implemented yet',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorTestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '🚨 Error Tests',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose the type of error to generate to test Zone capture:',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildErrorTestButton(
                icon: Icons.timer,
                title: 'Future Timeout',
                subtitle: 'Asynchronous error in Future',
                onPressed: () {
                  Navigator.pop(context);
                  _testAsyncFutureError();
                },
              ),
              const SizedBox(height: 8),
              _buildErrorTestButton(
                icon: Icons.stream,
                title: 'Stream Error',
                subtitle: 'Asynchronous error in Stream',
                onPressed: () {
                  Navigator.pop(context);
                  _testAsyncStreamError();
                },
              ),
              const SizedBox(height: 8),
              _buildErrorTestButton(
                icon: Icons.access_time,
                title: 'Timer Error',
                subtitle: 'Asynchronous error in Timer',
                onPressed: () {
                  Navigator.pop(context);
                  _testAsyncTimerError();
                },
              ),
              const SizedBox(height: 8),
              _buildErrorTestButton(
                icon: Icons.network_check,
                title: 'HTTP Error',
                subtitle: 'Simulated asynchronous HTTP error',
                onPressed: () {
                  Navigator.pop(context);
                  _testAsyncHttpError();
                },
              ),
              const SizedBox(height: 8),
              _buildErrorTestButton(
                icon: Icons.bug_report,
                title: 'Simple Zone Test',
                subtitle: 'Basic test with scheduleMicrotask',
                onPressed: () {
                  Navigator.pop(context);
                  _testSimpleZoneError();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorTestButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: Colors.red, size: 20),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        onTap: onPressed,
      ),
    );
  }

  // ============== ERROR TEST METHODS ==============

  /// Test 1: Future Error - Unhandled error in Future
  void _testAsyncFutureError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔥 Generating Future Error in 2 seconds...', style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange,
      ),
    );

    // Generate asynchronous error in Future (unhandled)
    Future.delayed(const Duration(seconds: 2), () {
      throw StateError('ZONE TEST: Unhandled Future Error - ${DateTime.now()}');
    });
  }

  /// Test 2: Stream Error - Unhandled error in Stream
  void _testAsyncStreamError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔥 Generating Stream Error in 2 seconds...', style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange,
      ),
    );

    // Generate asynchronous error in Stream (unhandled)
    Stream.periodic(const Duration(seconds: 1), (count) {
      if (count >= 2) {
        throw ArgumentError('ZONE TEST: Unhandled Stream Error - ${DateTime.now()}');
      }
      return count;
    }).listen((_) {}, onError: null); // No onError so it remains unhandled
  }

  /// Test 3: Timer Error - Unhandled error in Timer
  void _testAsyncTimerError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔥 Generating Timer Error in 2 seconds...', style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange,
      ),
    );

    // Generate asynchronous error in Timer (unhandled)
    Timer(const Duration(seconds: 2), () {
      throw FormatException('ZONE TEST: Unhandled Timer Error - ${DateTime.now()}');
    });
  }

  /// Test 4: HTTP-like async Error - Simulate asynchronous network error
  void _testAsyncHttpError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔥 Generating HTTP Error in 2 seconds...', style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange,
      ),
    );

    // Simulate HTTP-type asynchronous error
    _simulateNetworkCall().catchError((error) {
      // Re-throw so it's unhandled and goes to the Zone
      throw error;
    });
  }

  /// Simulates a network call that fails
  Future<String> _simulateNetworkCall() async {
    await Future.delayed(const Duration(seconds: 2));
    throw HttpException('ZONE TEST: Unhandled Network Error - ${DateTime.now()}');
  }

  /// Test 5: Simple Zone Test - The most basic possible
  void _testSimpleZoneError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔥 Generating async errors for Zone testing...', style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
    );

    // Method 1: Immediate error in microtask
    scheduleMicrotask(() {
      throw Exception('ZONE TEST: Microtask error - ${DateTime.now()}');
    });

    // Method 2: Very short Future.delayed
    Future.delayed(const Duration(milliseconds: 100), () {
      throw StateError('ZONE TEST: Future.delayed error - ${DateTime.now()}');
    });

    // Method 3: Immediate Timer
    Timer(const Duration(milliseconds: 50), () {
      throw ArgumentError('ZONE TEST: Timer error - ${DateTime.now()}');
    });

    // Method 4: Simple Future without await
    Future(() => throw FormatException('ZONE TEST: Future simple error - ${DateTime.now()}'));
  }

  void _logout() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Use AuthService to handle logout (includes Obsly cleanup)
      await authService.logout();

      // Navigate back to login using named route
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');

      // Even if there's an error, navigate to login
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final accounts = appState.accounts;
        final cards = appState.cards;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'My Bank',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            actions: [
              Semantics(
                label: 'Notifications',
                button: true,
                child: IconButton(
                  key: const Key('notifications_button'),
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ),
              // Dark mode toggle button
              Consumer<AppState>(
                builder: (context, appState, child) {
                  return Semantics(
                    label: appState.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
                    button: true,
                    child: IconButton(
                      key: const Key('theme_toggle_button'),
                      icon: Icon(
                        appState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      ),
                      onPressed: () {
                        appState.toggleDarkMode();
                      },
                    ),
                  );
                },
              ),
              Semantics(
                label: 'Sign out',
                button: true,
                child: IconButton(
                  key: const Key('logout_button'),
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    // Mostrar dialog de confirmación
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _logout();
                              },
                              child: const Text('Sign Out'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${appState.userName.isNotEmpty ? appState.userName : 'User'}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildBalanceCard(context, accounts),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, accounts),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'My Cards'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      itemBuilder: (context, index) => _buildCreditCard(context, cards[index]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Monthly Expenses'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildExpensesChart(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Semantics(
            label: 'Main navigation',
            child: BottomNavigationBar(
              key: const Key('main_navigation'),
              currentIndex: _currentBottomNavIndex,
              type: BottomNavigationBarType.fixed,
              onTap: _onBottomNavTap,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet),
                  label: 'Accounts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bug_report),
                  label: 'Testing',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context, List<Account> accounts) {
    final totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);

    return Semantics(
      label: 'Total balance card',
      value: 'Total balance: €${totalBalance.toStringAsFixed(2)}',
      child: Card(
        key: const Key('balance_card'),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Balance label',
                child: Text(
                  'Total Balance',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Total balance value',
                value: '€${totalBalance.toStringAsFixed(2)}',
                child: Text(
                  '€${totalBalance.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ...accounts.map((account) => _buildAccountItem(context, account)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, Account account) {
    return Semantics(
      label: 'Bank account ${account.type}',
      value: 'Number: ${account.accountNumber}, Balance: €${account.balance.toStringAsFixed(2)}',
      button: true,
      child: Container(
        key: Key('account_item_${account.id}'),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key('account_tap_${account.id}'),
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/account-details'),
                  builder: (context) => AccountDetailsScreen(
                    account: account,
                    transactions: Provider.of<AppState>(context, listen: false).getTransactionsForAccount(account.id),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.type,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          account.accountNumber,
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${account.currency} ${account.balance.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Tap to view details',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, CreditCard card) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: Key('card_tap_${card.id}'),
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/card-details'),
                builder: (context) => CardDetailsScreen(
                  card: card,
                  transactions: Provider.of<AppState>(context, listen: false).getTransactionsForCard(card.id),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with card type and icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.type,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      card.type == 'Visa' ? Icons.credit_card : Icons.credit_score,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
                const Spacer(),
                // Card number
                Text(
                  card.cardNumber,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                // Bottom section with cardholder, expiry date and view details button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left column: cardholder and expiry
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.cardHolder,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.expiryDate,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side: View details button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View details',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, List<Account> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Quick Actions'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.send,
                label: 'Transfer',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/transfer'),
                      builder: (context) => const TransferScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.payment,
                label: 'Pay Bills',
                color: Colors.orange,
                onTap: () {
                  // Generate uncaught Dart exception for testing purposes
                  debugPrint('[PAY BILLS] 💥 Generating uncaught exception...');

                  // This will throw an uncaught exception that cannot be wrapped in try-catch
                  // because it's called asynchronously without proper error handling
                  Future.microtask(() {
                    throw Exception(
                        'Pay Bills functionality crashed! This is an intentional uncaught exception for testing error handling and crash reporting.');
                  });

                  // Also throw synchronously to ensure immediate crash
                  throw StateError('Pay Bills feature intentionally crashed - uncaught exception test');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.savings,
                label: 'Piggy Banks',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/piggybanks'),
                      builder: (context) => const PiggyBanksScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.more_horiz,
                label: 'More',
                color: Colors.grey,
                onTap: () {
                  _showFeatureNotImplemented('More Options');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildExpensesChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                final index = value.toInt();

                // Solo mostrar etiquetas en intervalos para evitar solapamiento
                // En pantallas grandes, mostrar todas las etiquetas
                // En pantallas pequeñas, mostrar cada 2 etiquetas
                final screenWidth = MediaQuery.of(context).size.width;
                final showAllLabels = screenWidth > 600; // Consideramos pantalla grande si es mayor a 600px

                if (index < labels.length) {
                  // Si es pantalla grande, mostrar todas las etiquetas
                  if (showAllLabels) {
                    return Text(
                      labels[index],
                      style: GoogleFonts.poppins(fontSize: 12),
                    );
                  } else {
                    // Si es pantalla pequeña, mostrar solo etiquetas en posiciones pares
                    if (index % 2 == 0) {
                      return Text(
                        labels[index],
                        style: GoogleFonts.poppins(fontSize: 12),
                      );
                    }
                  }
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 1500),
              FlSpot(1, 2000),
              FlSpot(2, 1800),
              FlSpot(3, 2200),
              FlSpot(4, 2100),
              FlSpot(5, 2400),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
