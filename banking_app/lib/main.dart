import 'package:banking_app/guards/auth_guard.dart';
import 'package:banking_app/models/account.dart';
import 'package:banking_app/models/card.dart';
import 'package:banking_app/models/piggybank.dart';
import 'package:banking_app/models/transaction.dart';
import 'package:banking_app/screens/account_details_screen.dart';
import 'package:banking_app/screens/card_details_screen.dart';
import 'package:banking_app/screens/dashboard_screen.dart';
import 'package:banking_app/screens/deposit_screen.dart';
import 'package:banking_app/screens/login_screen.dart';
import 'package:banking_app/screens/piggybank_detail_screen.dart';
import 'package:banking_app/screens/piggybanks_screen.dart';
import 'package:banking_app/screens/transfer_screen.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:banking_app/services/auth_service.dart';
import 'package:banking_app/utils/screen_timing_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obsly_flutter/obsly_sdk.dart';
import 'package:provider/provider.dart';

void main() async {
  // 🔥 Framework-Agnostic Initialization (Crashlytics-style)
  // Optional: Configure async error capture with conflict prevention
  ObslySDK.enableAsyncErrorCapture(
    global: true,
    preventConflicts: true, // Safe with Crashlytics, Sentry, etc.
  );

  // 🔥 Enhanced async error capture with framework-agnostic support
  ObslySDK.runWithAsyncErrorCapture(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Framework-agnostic initialization - works with any Flutter architecture
    await ObslySDK.instance.init(
      InitParameters(
        obslyKey:
            'YOUR_OBSLY_API_KEY_HERE', // Replace with your actual Obsly API key
        instanceURL: 'https://api.int.obsly.io',
        debugMode: true,
        logLevel: LogLevel.debug,
        config: ObslyConfig(
          enableDebugTools: true,
          enableScreenshotOnUi: true,
          enableLifeCycleLog: true, // Enhanced navigation tracking
          automaticViewDetection: true, // Framework-agnostic view detection
          rageClick: const RageClickConfig(
            active: true,
            screenshot: true,
            screenshotPercent: 0.25,
          ),
          // Banking-specific PII filtering configuration
          anonymization: AnonymizationConfig(
            enablePiiFiltering: true,
            piiFilterRules: [
              PiiFilterRule(
                id: 'any_number',
                name: 'Digit Anonymization',
                pattern: r'[0-9]',
                replacement: '*',
              ),
            ],
          ),
        ),
      ),
    );

    // Initialize auth service
    await AuthService().initialize();

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Generate dynamic routes for deep linking
  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Root route - go directly to login
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const PublicRoute(child: LoginScreen()),
        );

      case '/login':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const PublicRoute(child: LoginScreen()),
        );

      case '/dashboard':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ProtectedRoute(child: DashboardScreen()),
        );

      case '/card-details':
        // For deep linking, create a dummy card
        // In a real app, you could extract ID from the URL and load data
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProtectedRoute(
            child: CardDetailsScreen(
              card: CreditCard(
                id: 'deep-link-card',
                cardNumber: '**** **** **** 1234',
                cardHolder: 'Deep Link User',
                expiryDate: '12/25',
                type: 'VISA',
                limit: 5000.0,
                currentBalance: 0.0,
              ),
              transactions: [
                Transaction(
                  id: 'deep-link-transaction',
                  description: 'Direct access via URL',
                  amount: 0.0,
                  date: DateTime.now(),
                  type: 'info',
                  category: 'deep-link',
                  reference: 'DL001',
                ),
              ],
            ),
          ),
        );

      case '/account-details':
        // For deep linking, create a dummy account
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProtectedRoute(
            child: AccountDetailsScreen(
              account: Account(
                id: 'deep-link-account',
                accountNumber: '**** **** 1234',
                type: 'Direct Access',
                balance: 0.0,
                currency: 'EUR',
              ),
              transactions: [
                Transaction(
                  id: 'deep-link-transaction',
                  description: 'Direct access via URL',
                  amount: 0.0,
                  date: DateTime.now(),
                  type: 'info',
                  category: 'deep-link',
                  reference: 'DL001',
                ),
              ],
            ),
          ),
        );

      case '/transfer':
        // TransferScreen now uses AppState directly
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ProtectedRoute(
            child: TransferScreen(),
          ),
        );

      case '/piggybanks':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ProtectedRoute(
            child: PiggyBanksScreen(),
          ),
        );

      case '/piggybank-detail':
        // For deep linking, create a dummy piggy bank
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProtectedRoute(
            child: PiggyBankDetailScreen(
              piggyBank: PiggyBank(
                id: 'deep-link-piggybank',
                name: 'Deep Link Savings',
                description: 'Direct access via URL',
                balance: 0.0,
                targetAmount: 1000.0,
                currency: 'EUR',
                createdDate: DateTime.now(),
              ),
            ),
          ),
        );

      case '/deposit':
        // For deep linking, create a dummy piggy bank and deposit screen
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProtectedRoute(
            child: DepositScreen(
              piggyBank: PiggyBank(
                id: 'deep-link-piggybank',
                name: 'Deep Link Savings',
                description: 'Direct access via URL',
                balance: 0.0,
                targetAmount: 1000.0,
                currency: 'EUR',
                createdDate: DateTime.now(),
              ),
            ),
          ),
        );

      default:
        return null; // Allow onUnknownRoute to handle routes not found
    }
  }

  // Handle unknown routes
  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const PublicRoute(child: LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        ChangeNotifierProvider<AppState>(
          create: (context) => AppState(),
        ),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          final bankingApp = MaterialApp(
            title: 'Banking App',
            // English localization configuration
            locale: const Locale('en', 'US'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('es', 'ES'), // Spanish as fallback
            ],
            // Dynamic theme based on AppState
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
              // Improved light theme customizations
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: false,
                titleTextStyle:
                    GoogleFonts.poppinsTextTheme().titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.dark().textTheme,
              ),
              // Improved dark theme customizations
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: false,
                titleTextStyle: GoogleFonts.poppinsTextTheme(
                  ThemeData.dark().textTheme,
                ).titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // Better contrast for dark mode
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
            ),
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const PublicRoute(child: LoginScreen()),
              '/login': (context) => const PublicRoute(child: LoginScreen()),
              '/dashboard': (context) =>
                  const ProtectedRoute(child: DashboardScreen()),
            },
            onGenerateRoute: _generateRoute,
            onUnknownRoute: _unknownRoute,
            // 🕐 Activar medición automática de tiempos de carga de pantallas
            // Métrica: PageLoadComplete usando histogram de Obsly
            navigatorObservers: [
              ScreenTimingObserver(),
            ],
          );

          // Wrap the app with Obsly SDK
          return ObslySDK.instance.wrapApp(
            app: bankingApp,
          );
        },
      ),
    );
  }
}
