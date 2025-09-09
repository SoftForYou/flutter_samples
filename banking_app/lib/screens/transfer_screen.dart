import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/models/transfer.dart';
import 'package:banking_app/models/account.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:banking_app/screens/transfer_step1_screen.dart';
import 'package:banking_app/screens/transfer_step2_screen.dart';
import 'package:banking_app/screens/transfer_step4_screen.dart';
import 'package:banking_app/screens/transfer_result_screen.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class TransferScreen extends StatefulWidget {
  final List<Account>? accounts; // Make it optional since we'll use AppState

  const TransferScreen({
    super.key,
    this.accounts, // Optional now
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  late TransferData _transferData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _transferData = TransferData();
    _setupObslyTracking();
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('transfer_flow');
      await ObslySDK.instance.setOperation('money_transfer');
      await ObslySDK.instance.setFunctionalBlock('transfers');
      
      // Track transfer process start
      await _trackTransferStart();
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  /// Track transfer process start
  Future<void> _trackTransferStart() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'process_id', value: DateTime.now().millisecondsSinceEpoch.toString()),
        Tag(key: 'user_action', value: 'start_transfer'),
        Tag(key: 'entry_point', value: 'dashboard_quick_action'),
      ], 'APPBANK.Transfer.StartProcess');

      debugPrint('🚀 Transfer process started - tracked in Obsly');
    } catch (e) {
      debugPrint('Error tracking transfer start: $e');
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _exitTransfer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Exit Transfer?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to exit? Your progress will be lost.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Transfer'),
            ),
            TextButton(
              onPressed: () {
                // Track transfer cancellation
                _trackTransferCancel('user_exit', 'step_${_currentStep + 1}');
                
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Exit transfer
              },
              child: Text(
                'Exit',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Track transfer process cancellation/abandonment
  Future<void> _trackTransferCancel(String reason, String abandonPoint) async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'cancel_reason', value: reason),
        Tag(key: 'abandon_point', value: abandonPoint),
        Tag(key: 'steps_completed', value: _currentStep.toString()),
        Tag(key: 'user_action', value: 'cancel_transfer'),
        Tag(key: 'transfer_data_completed', value: _transferData.isComplete.toString()),
      ], 'APPBANK.Transfer.CancelProcess');

      debugPrint('❌ Transfer cancelled at $abandonPoint - reason: $reason');
    } catch (e) {
      debugPrint('Error tracking transfer cancellation: $e');
    }
  }

  void _updateTransferData(TransferData data) {
    setState(() {
      _transferData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final accounts = widget.accounts ?? appState.accounts;
        
        return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          _previousStep();
          return false;
        } else {
          // Track abandonment when user presses back on first step
          _trackTransferCancel('back_button', 'step_1');
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'New Transfer',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitTransfer,
          ),
          actions: [
            if (_currentStep > 0)
              TextButton(
                onPressed: _previousStep,
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  TransferStep1Screen(
                    accounts: accounts,
                    transferData: _transferData,
                    onNext: (data) {
                      _updateTransferData(data);
                      _nextStep();
                    },
                    onExit: _exitTransfer,
                  ),
                  TransferStep2Screen(
                    accounts: accounts,
                    transferData: _transferData,
                    onNext: (data) {
                      _updateTransferData(data);
                      _nextStep();
                    },
                    onBack: _previousStep,
                  ),

                  TransferStep4Screen(
                    accounts: accounts,
                    transferData: _transferData,
                    onConfirm: (data) {
                      _updateTransferData(data);
                      _nextStep();
                    },
                    onBack: _previousStep,
                  ),
                  TransferResultScreen(
                    transferData: _transferData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
