import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class PerformanceTestScreen extends StatefulWidget {
  const PerformanceTestScreen({super.key});

  @override
  State<PerformanceTestScreen> createState() => _PerformanceTestScreenState();
}

class _PerformanceTestScreenState extends State<PerformanceTestScreen> {
  // Controllers for form inputs
  final _transactionNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepNameController = TextEditingController();
  final _stepDescriptionController = TextEditingController();
  final _autoFinishCountController = TextEditingController();

  // State tracking
  String _output = '';
  List<String> _activeTransactions = [];
  Map<String, List<String>> _activeSteps = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshActiveState();
  }

  @override
  void dispose() {
    _transactionNameController.dispose();
    _descriptionController.dispose();
    _stepNameController.dispose();
    _stepDescriptionController.dispose();
    _autoFinishCountController.dispose();
    super.dispose();
  }

  void _refreshActiveState() {
    setState(() {
      // Get current state from PerformanceController
      final summary = ObslySDK.instance.performance.getPerformanceSummary();
      _activeTransactions = List<String>.from(summary['transactions'] ?? []);
      
      // For steps, we'll track them locally since we need per-transaction info
      // This is a simplified view for the test screen
    });
  }

  void _addOutput(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _output += '[$timestamp] $message\n';
    });
  }

  void _clearOutput() {
    setState(() {
      _output = '';
    });
  }

  Future<void> _startTransaction() async {
    if (_transactionNameController.text.isEmpty) {
      _addOutput('❌ Transaction name is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transactionName = _transactionNameController.text.trim();
      final description = _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim();
      final autoFinishCount = _autoFinishCountController.text.trim().isEmpty 
          ? null 
          : int.tryParse(_autoFinishCountController.text.trim());

      await ObslySDK.instance.performance.startTransaction(
        transactionName,
        description,
        null, // startNanoTime
        autoFinishCount,
      );

      _addOutput('✅ Transaction started: $transactionName');
      if (description != null) _addOutput('   Description: $description');
      if (autoFinishCount != null) _addOutput('   Auto-finish after: $autoFinishCount steps');
      
      _refreshActiveState();
      
      // Clear form
      _transactionNameController.clear();
      _descriptionController.clear();
      _autoFinishCountController.clear();
      
    } catch (e) {
      _addOutput('❌ Error starting transaction: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _endTransaction() async {
    if (_transactionNameController.text.isEmpty) {
      _addOutput('❌ Transaction name is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transactionName = _transactionNameController.text.trim();
      final updatedDescription = _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim();

      await ObslySDK.instance.performance.endTransaction(
        transactionName,
        updatedDescription,
      );

      _addOutput('🏁 Transaction ended: $transactionName');
      if (updatedDescription != null) _addOutput('   Final description: $updatedDescription');
      
      _refreshActiveState();
      
      // Clear form
      _transactionNameController.clear();
      _descriptionController.clear();
      
    } catch (e) {
      _addOutput('❌ Error ending transaction: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startStep() async {
    if (_stepNameController.text.isEmpty || _transactionNameController.text.isEmpty) {
      _addOutput('❌ Step name and transaction name are required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final stepName = _stepNameController.text.trim();
      final transactionName = _transactionNameController.text.trim();
      final description = _stepDescriptionController.text.trim().isEmpty 
          ? null 
          : _stepDescriptionController.text.trim();

      await ObslySDK.instance.performance.startStep(
        stepName,
        transactionName,
        description,
      );

      _addOutput('🚀 Step started: $stepName in $transactionName');
      if (description != null) _addOutput('   Description: $description');
      
      // Track step locally
      setState(() {
        _activeSteps[transactionName] ??= [];
        if (!_activeSteps[transactionName]!.contains(stepName)) {
          _activeSteps[transactionName]!.add(stepName);
        }
      });
      
      // Clear step form
      _stepNameController.clear();
      _stepDescriptionController.clear();
      
    } catch (e) {
      _addOutput('❌ Error starting step: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _finishStep() async {
    if (_stepNameController.text.isEmpty || _transactionNameController.text.isEmpty) {
      _addOutput('❌ Step name and transaction name are required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final stepName = _stepNameController.text.trim();
      final transactionName = _transactionNameController.text.trim();
      final updatedDescription = _stepDescriptionController.text.trim().isEmpty 
          ? null 
          : _stepDescriptionController.text.trim();

      await ObslySDK.instance.performance.finishStep(
        stepName,
        transactionName,
        updatedDescription,
      );

      _addOutput('✅ Step finished: $stepName in $transactionName');
      if (updatedDescription != null) _addOutput('   Final description: $updatedDescription');
      
      // Remove step from local tracking
      setState(() {
        _activeSteps[transactionName]?.remove(stepName);
        if (_activeSteps[transactionName]?.isEmpty ?? false) {
          _activeSteps.remove(transactionName);
        }
      });
      
      _refreshActiveState();
      
      // Clear step form
      _stepNameController.clear();
      _stepDescriptionController.clear();
      
    } catch (e) {
      _addOutput('❌ Error finishing step: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPerformanceSummary() {
    try {
      final summary = ObslySDK.instance.performance.getPerformanceSummary();
      _addOutput('📊 Performance Summary:');
      _addOutput('   Active Transactions: ${summary['active_transactions']}');
      _addOutput('   Active Steps: ${summary['active_steps']}');
      _addOutput('   Transaction Names: ${summary['transactions']}');
      _addOutput('   Initialized: ${summary['is_initialized']}');
    } catch (e) {
      _addOutput('❌ Error getting summary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Tests'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshActiveState,
            tooltip: 'Refresh State',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showPerformanceSummary,
            tooltip: 'Show Summary',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active State Section
          if (_activeTransactions.isNotEmpty || _activeSteps.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active State',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_activeTransactions.isNotEmpty) ...[
                    Text('Transactions: ${_activeTransactions.join(', ')}'),
                  ],
                  if (_activeSteps.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...(_activeSteps.entries.map((entry) => 
                      Text('${entry.key}: ${entry.value.join(', ')}')
                    )),
                  ],
                ],
              ),
            ),

          // Controls Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Transaction Controls
                  _buildSectionCard(
                    title: 'Transaction Control',
                    color: Colors.blue,
                    children: [
                      TextField(
                        controller: _transactionNameController,
                        decoration: const InputDecoration(
                          labelText: 'Transaction Name *',
                          hintText: 'e.g., user_login, api_call',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          hintText: 'e.g., User authentication flow',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _autoFinishCountController,
                        decoration: const InputDecoration(
                          labelText: 'Auto-finish Step Count (optional)',
                          hintText: 'e.g., 3',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _startTransaction,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Transaction'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _endTransaction,
                              icon: const Icon(Icons.stop),
                              label: const Text('End Transaction'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Step Controls
                  _buildSectionCard(
                    title: 'Step Control',
                    color: Colors.purple,
                    children: [
                      TextField(
                        controller: _stepNameController,
                        decoration: const InputDecoration(
                          labelText: 'Step Name *',
                          hintText: 'e.g., validate_credentials, fetch_data',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _stepDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Step Description (optional)',
                          hintText: 'e.g., Validating user credentials',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _startStep,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Step'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _finishStep,
                              icon: const Icon(Icons.check),
                              label: const Text('Finish Step'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[300],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Actions
                  _buildSectionCard(
                    title: 'Quick Actions',
                    color: Colors.orange,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showPerformanceSummary,
                        icon: const Icon(Icons.analytics),
                        label: const Text('Show Performance Summary'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _clearOutput,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Output'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Example Workflows
                  _buildSectionCard(
                    title: 'Example Workflows',
                    color: Colors.teal,
                    children: [
                      _buildExampleButton(
                        'Simple Transaction',
                        'Basic transaction without steps',
                        () => _runSimpleExample(),
                      ),
                      const SizedBox(height: 8),
                      _buildExampleButton(
                        'Transaction with Steps',
                        'Transaction with multiple steps',
                        () => _runStepsExample(),
                      ),
                      const SizedBox(height: 8),
                      _buildExampleButton(
                        'Auto-finish Example',
                        'Transaction that auto-finishes after 3 steps',
                        () => _runAutoFinishExample(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Output Section
          Container(
            height: 200,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.terminal, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Output',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                        onPressed: _clearOutput,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _output.isEmpty ? 'No output yet. Try running some performance tests!' : _output,
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildExampleButton(String title, String description, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: _isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.teal[300]!),
        padding: const EdgeInsets.all(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.teal[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runSimpleExample() async {
    _addOutput('🚀 Running Simple Transaction Example...');
    
    try {
      await ObslySDK.instance.performance.startTransaction(
        'simple_example',
        'A simple transaction without steps',
      );
      
      _addOutput('   Transaction started, waiting 2 seconds...');
      await Future.delayed(const Duration(seconds: 2));
      
      await ObslySDK.instance.performance.endTransaction(
        'simple_example',
        'Simple transaction completed successfully',
      );
      
      _addOutput('✅ Simple example completed!');
      _refreshActiveState();
      
    } catch (e) {
      _addOutput('❌ Simple example failed: $e');
    }
  }

  Future<void> _runStepsExample() async {
    _addOutput('🚀 Running Transaction with Steps Example...');
    
    try {
      await ObslySDK.instance.performance.startTransaction(
        'steps_example',
        'Transaction with multiple steps',
      );
      
      _addOutput('   Starting Step 1...');
      await ObslySDK.instance.performance.startStep(
        'step_1',
        'steps_example',
        'First step',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      await ObslySDK.instance.performance.finishStep('step_1', 'steps_example');
      
      _addOutput('   Starting Step 2...');
      await ObslySDK.instance.performance.startStep(
        'step_2',
        'steps_example',
        'Second step',
      );
      await Future.delayed(const Duration(milliseconds: 300));
      await ObslySDK.instance.performance.finishStep('step_2', 'steps_example');
      
      _addOutput('   Ending transaction...');
      await ObslySDK.instance.performance.endTransaction(
        'steps_example',
        'Transaction with steps completed',
      );
      
      _addOutput('✅ Steps example completed!');
      _refreshActiveState();
      
    } catch (e) {
      _addOutput('❌ Steps example failed: $e');
    }
  }

  Future<void> _runAutoFinishExample() async {
    _addOutput('🚀 Running Auto-finish Example...');
    
    try {
      await ObslySDK.instance.performance.startTransaction(
        'auto_finish_example',
        'Will auto-finish after 3 steps',
        null, // startNanoTime
        3, // autofinishWithStepsCount
      );
      
      for (int i = 1; i <= 3; i++) {
        _addOutput('   Step $i of 3...');
        await ObslySDK.instance.performance.startStep(
          'auto_step_$i',
          'auto_finish_example',
          'Auto step $i',
        );
        await Future.delayed(const Duration(milliseconds: 200));
        await ObslySDK.instance.performance.finishStep(
          'auto_step_$i', 
          'auto_finish_example'
        );
        
        if (i == 3) {
          _addOutput('   🎯 Transaction should auto-finish now!');
        }
      }
      
      _addOutput('✅ Auto-finish example completed!');
      _refreshActiveState();
      
    } catch (e) {
      _addOutput('❌ Auto-finish example failed: $e');
    }
  }
}
