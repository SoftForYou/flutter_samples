import 'package:cached_query/cached_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

import 'features/cart/cart.dart';
import 'router.dart';

void main() {
  ObslySDK.enableAsyncErrorCapture(
    global: true,
    preventConflicts: true, // Safe with Crashlytics, Sentry, etc.
  );
  ObslySDK.runWithAsyncErrorCapture(initializeApp);
}

void initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  CachedQuery.instance.config(config: QueryConfig(cacheDuration: const Duration(minutes: 10)));

  await ObslySDK.instance.init(
    const InitParameters(
      obslyKey: 'YOUR_OBSLY_API_KEY_HERE', // Replace with your actual Obsly API key
      instanceURL: 'https://api.int.obsly.io',
      debugMode: true,
      logLevel: LogLevel.debug,
      config: ObslyConfig(
        enableDebugTools: true,
        enableScreenshotOnUi: false,
        enableLifeCycleLog: true, // Enhanced navigation tracking
        automaticViewDetection: true, // Framework-agnostic view detection
        rageClick: RageClickConfig(active: true, screenshot: true, screenshotPercent: 0.25),
      ),
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(),
      child: ObslySDK.instance.wrapApp(
        app: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: AppRoutes.router,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
            drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
            cardTheme: const CardThemeData(color: Colors.white, elevation: 2),
          ),
          builder: (context, child) => child!,
          title: 'Obsly Demo App',
        ),
      ),
    );
  }
}
