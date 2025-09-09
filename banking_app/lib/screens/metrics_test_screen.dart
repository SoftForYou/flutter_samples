import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class MetricsTestScreen extends StatefulWidget {
  const MetricsTestScreen({super.key});

  @override
  State<MetricsTestScreen> createState() => _MetricsTestScreenState();
}

class _MetricsTestScreenState extends State<MetricsTestScreen> {
  int _counterValue = 0;
  double _gaugeValue = 0.0;
  bool _histogramRunning = false;
  String _lastResult = '';

  @override
  void initState() {
    super.initState();
    _setupObslyTracking();
  }

  void _setupObslyTracking() async {
    try {
      // Configurar tracking para la pantalla de test de métricas
      await ObslySDK.instance.setView('metrics_test_screen');
      await ObslySDK.instance.setOperation('metrics_testing');
      await ObslySDK.instance.setFunctionalBlock('testing');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test de Métricas Obsly',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildCounterSection(),
            const SizedBox(height: 24),
            _buildGaugeSection(),
            const SizedBox(height: 24),
            _buildHistogramSection(),
            const SizedBox(height: 24),
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Métricas SDK Test',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This screen allows you to test the different types of metrics available in Obsly SDK:\n\n'
              '• Counter: Increments numeric values\n'
              '• Gauge: Sets instantaneous values\n'
              '• Histogram: Measures durations and times',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Counter Test',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Valor actual: $_counterValue',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _incrementCounter,
                    icon: const Icon(Icons.add),
                    label: const Text('Incrementar Counter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Gauge Test',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Último valor: ${_gaugeValue.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _setRandomGauge,
                icon: const Icon(Icons.casino),
                label: const Text('Establecer Gauge Aleatorio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistogramSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Histogram Test',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Estado: ${_histogramRunning ? "Timer activo" : "Inactivo"}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _histogramRunning ? Colors.orange : Colors.grey[600],
                fontWeight: _histogramRunning ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _histogramRunning ? null : _startHistogram,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Histogram'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _histogramRunning ? _endHistogram : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('End Histogram'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Último Resultado',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _lastResult.isEmpty ? 'Ninguna métrica enviada aún' : _lastResult,
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos para probar las métricas
  void _incrementCounter() async {
    try {
      setState(() {
        _counterValue++;
      });

      // Usar el método incCounter del SDK
      await ObslySDK.instance.incCounter(
        'test_button_clicks',
        fbl: 'testing',
        operation: 'user_interaction',
        view: 'metrics_test_screen',
        state: 'active',
      );

      setState(() {
        _lastResult = 'Counter incrementado: $_counterValue\n'
            'Key: test_button_clicks\n'
            'FBL: testing\n'
            'Operation: user_interaction\n'
            'View: metrics_test_screen\n'
            'State: active';
      });

      _showSuccessSnackBar('Counter incrementado exitosamente!');
    } catch (e) {
      _showErrorSnackBar('Error incrementando counter: $e');
    }
  }

  void _resetCounter() {
    setState(() {
      _counterValue = 0;
      _lastResult = 'Counter reseteado a 0';
    });
  }

  void _setRandomGauge() async {
    try {
      final random = Random();
      final value = (random.nextDouble() * 100).roundToDouble();

      setState(() {
        _gaugeValue = value;
      });

      // Usar el método setGauge del SDK
      await ObslySDK.instance.setGauge(
        'random_value_metric', // key
        value, // value
        fbl: 'testing', // fbl
        operation: 'random_generation', // operation
        view: 'metrics_test_screen', // view
        state: 'active', // state
      );

      setState(() {
        _lastResult = 'Gauge establecido: ${value.toStringAsFixed(2)}\n'
            'Key: random_value_metric\n'
            'FBL: testing\n'
            'Operation: random_generation\n'
            'View: metrics_test_screen\n'
            'State: active';
      });

      _showSuccessSnackBar('Gauge establecido: ${value.toStringAsFixed(2)}');
    } catch (e) {
      _showErrorSnackBar('Error estableciendo gauge: $e');
    }
  }

  void _startHistogram() async {
    try {
      setState(() {
        _histogramRunning = true;
      });

      // Usar el método startHistogramTimer del SDK
      await ObslySDK.instance.startHistogramTimer(
        'user_action_duration',
        fbl: 'testing',
        operation: 'timing_measurement',
        view: 'metrics_test_screen',
      );

      setState(() {
        _lastResult = 'Histogram timer iniciado\n'
            'Key: user_action_duration\n'
            'FBL: testing\n'
            'Operation: timing_measurement\n'
            'View: metrics_test_screen';
      });

      _showSuccessSnackBar('Histogram timer iniciado!');
    } catch (e) {
      setState(() {
        _histogramRunning = false;
      });
      _showErrorSnackBar('Error iniciando histogram: $e');
    }
  }

  void _endHistogram() async {
    try {
      // Usar el método endHistogramTimer del SDK
      await ObslySDK.instance.endHistogramTimer(
        'user_action_duration',
        fbl: 'testing',
        operation: 'timing_measurement',
        view: 'metrics_test_screen',
        state: 'completed',
      );

      setState(() {
        _histogramRunning = false;
        _lastResult = 'Histogram timer finalizado\n'
            'Key: user_action_duration\n'
            'FBL: testing\n'
            'Operation: timing_measurement\n'
            'View: metrics_test_screen\n'
            'State: completed';
      });

      _showSuccessSnackBar('Histogram timer finalizado!');
    } catch (e) {
      setState(() {
        _histogramRunning = false;
      });
      _showErrorSnackBar('Error finalizando histogram: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
