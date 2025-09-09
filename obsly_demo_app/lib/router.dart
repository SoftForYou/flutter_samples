import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:obsly_flutter/obsly_sdk.dart';
import 'features/pages.dart';
import 'ui/main_scaffold.dart';

class AppRoutes {
  static const String home = '/';
  static const String cart = '/cart';
  static const String catalog = '/catalog';
  static const String checkout = '/checkout';
  static const String labNetwork = '/lab_network';
  static const String product = '/product/:id';
  static const String settings = '/settings';

  final routeTitles = {
    home: 'Home',
    cart: 'Cart',
    catalog: 'Catalog',
    checkout: 'Checkout',
    labNetwork: 'Lab Network',
    product: 'Product',
    settings: 'Settings',
  };

  static final GoRouter router = GoRouter(
    initialLocation: home,
    observers: ObslySDK.goRouterObservers,
    routes: <RouteBase>[
      GoRoute(
        name: cart,
        path: cart,
        builder: (BuildContext context, GoRouterState state) {
          return const CartScreen();
        },
      ),
      GoRoute(
        name: settings,
        path: settings,
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        name: product,
        path: product,
        builder: (BuildContext context, GoRouterState state) {
          return const ProductScreen();
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            name: home,
            path: home,
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
          ),
          GoRoute(
            path: catalog,
            builder: (BuildContext context, GoRouterState state) {
              return const CatalogScreen();
            },
          ),
          GoRoute(
            path: checkout,
            builder: (BuildContext context, GoRouterState state) {
              return const CheckoutScreen();
            },
          ),
          GoRoute(
            name: labNetwork,
            path: labNetwork,
            builder: (BuildContext context, GoRouterState state) {
              return const LabNetworkScreen();
            },
          ),
        ],
      ),
    ],
  );
}
