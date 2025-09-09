import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obsly_flutter/obsly_sdk.dart';
import '../widgets/counter.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  void _setupObslyTracking() async {
    try {
      // Configurar tracking para la pantalla de ejemplo/demo
      await ObslySDK.instance.setView('example_screen');
      await ObslySDK.instance.setOperation('demo_interaction');
      await ObslySDK.instance.setFunctionalBlock('demo');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _setupObslyTracking();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ejemplo SDK',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 40),
            const Counter(),
            const SizedBox(height: 40),
            Text(
              'Este es un ejemplo de integración del SDK',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
