import 'package:demo_app/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/cart/widgets/cart_icon_with_badge.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          const CartIconWithBadge(),
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.black,
            onPressed: () {
              context.push(AppRoutes.settings);
            },
          ),
        ],
        title: const Text(
          'Demo Store',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        elevation: 16.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: const Text('Drawer Header'),
            ),

            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('Home'),
                    onTap: () {
                      context.go(AppRoutes.home);

                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Catalog'),
                    onTap: () {
                      context.go('/catalog');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Footer Content',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
