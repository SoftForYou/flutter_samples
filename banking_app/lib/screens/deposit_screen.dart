import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/models/piggybank.dart';
import 'package:banking_app/models/deposit.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:banking_app/screens/deposit_step1_screen.dart';
import 'package:banking_app/screens/deposit_step2_screen.dart';
import 'package:banking_app/screens/deposit_step3_screen.dart';
import 'package:banking_app/screens/deposit_result_screen.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class DepositScreen extends StatefulWidget {
  final PiggyBank piggyBank;

  const DepositScreen({
    super.key,
    required this.piggyBank,
  });

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  late DepositData _depositData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _depositData = DepositData(piggyBankId: widget.piggyBank.id);
    _setupObslyTracking();
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('deposit_flow');
      await ObslySDK.instance.setOperation('piggybank_deposit');
      await ObslySDK.instance.setFunctionalBlock('deposits');
      
      // Track deposit process start
      await _trackDepositStart();
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  /// Track deposit process start
  Future<void> _trackDepositStart() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'process_id', value: DateTime.now().millisecondsSinceEpoch.toString()),
        Tag(key: 'user_action', value: 'start_deposit_flow'),
        Tag(key: 'piggybank_id', value: widget.piggyBank.id),
        Tag(key: 'piggybank_name', value: widget.piggyBank.name),
        Tag(key: 'entry_point', value: 'piggybank_detail'),
      ], 'APPBANK.Deposit.StartProcess');

      debugPrint('🐷💰 Deposit process started - tracked in Obsly');
    } catch (e) {
      debugPrint('Error tracking deposit start: $e');
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

  void _exitDeposit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Exit Deposit?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to exit? Your progress will be lost.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Deposit'),
            ),
            TextButton(
              onPressed: () {
                // Track deposit cancellation
                _trackDepositCancel('user_exit', 'step_${_currentStep + 1}');
                
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Exit deposit
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

  /// Track deposit process cancellation/abandonment
  Future<void> _trackDepositCancel(String reason, String abandonPoint) async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'cancel_reason', value: reason),
        Tag(key: 'abandon_point', value: abandonPoint),
        Tag(key: 'steps_completed', value: _currentStep.toString()),
        Tag(key: 'user_action', value: 'cancel_deposit'),
        Tag(key: 'piggybank_id', value: widget.piggyBank.id),
        Tag(key: 'piggybank_name', value: widget.piggyBank.name),
        Tag(key: 'deposit_data_completed', value: _depositData.isValid.toString()),
      ], 'APPBANK.Deposit.CancelProcess');

      debugPrint('❌ Deposit cancelled at $abandonPoint - reason: $reason');
    } catch (e) {
      debugPrint('Error tracking deposit cancellation: $e');
    }
  }

  void _updateDepositData(DepositData data) {
    setState(() {
      _depositData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final accounts = appState.accounts;
        
        return WillPopScope(
          onWillPop: () async {
            if (_currentStep > 0) {
              _previousStep();
              return false;
            } else {
              // Track abandonment when user presses back on first step
              _trackDepositCancel('back_button', 'step_1');
              return true;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Add Money to ${widget.piggyBank.name}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitDeposit,
              ),
              actions: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _previousStep,
                    child: Text(
                      'Back',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                _buildProgressIndicator(),
                _buildPiggyBankSummary(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DepositStep1Screen(
                        accounts: accounts,
                        depositData: _depositData,
                        onNext: (data) {
                          _updateDepositData(data);
                          _nextStep();
                        },
                        onExit: _exitDeposit,
                      ),
                      DepositStep2Screen(
                        depositData: _depositData,
                        piggyBank: widget.piggyBank,
                        onNext: (data) {
                          _updateDepositData(data);
                          _nextStep();
                        },
                        onBack: _previousStep,
                      ),
                      DepositStep3Screen(
                        depositData: _depositData,
                        piggyBank: widget.piggyBank,
                        onConfirm: (data) {
                          _updateDepositData(data);
                          _nextStep();
                        },
                        onBack: _previousStep,
                      ),
                      DepositResultScreen(
                        depositData: _depositData,
                        piggyBank: widget.piggyBank,
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
                          ? Colors.green[600]
                          : Colors.grey[300],
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

  Widget _buildPiggyBankSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.savings,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.piggyBank.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Current: €${widget.piggyBank.balance.toStringAsFixed(2)} / €${widget.piggyBank.targetAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${(widget.piggyBank.progressPercentage * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
