import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  final Widget child;
  final VoidCallback? goBack;
  final String? title;
  final bool canGoBack;

  const PageScaffold({
    super.key,
    required this.child,
    this.goBack,
    this.title,
    this.canGoBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: canGoBack && goBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
                onPressed: goBack,
              )
            : null,
        title: Text(
          title ?? '',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: child,
    );
  }
}
