import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/models/piggybank.dart';
import 'package:banking_app/models/deposit.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class DepositStep2Screen extends StatefulWidget {
  final DepositData depositData;
  final PiggyBank piggyBank;
  final Function(DepositData) onNext;
  final VoidCallback onBack;

  const DepositStep2Screen({
    super.key,
    required this.depositData,
    required this.piggyBank,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<DepositStep2Screen> createState() => _DepositStep2ScreenState();
}

class _DepositStep2ScreenState extends State<DepositStep2Screen> {
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _conceptFocusNode = FocusNode();
  String? _amountError;
  String? _conceptError;

  @override
  void initState() {
    super.initState();
    if (widget.depositData.amount != null) {
      _amountController.text = widget.depositData.amount!.toStringAsFixed(2);
    }
    if (widget.depositData.concept != null) {
      _conceptController.text = widget.depositData.concept!;
    }
    _setupObslyTracking();
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'view_deposit_step2'),
        Tag(key: 'step_name', value: 'enter_amount_concept'),
        Tag(key: 'piggybank_current_balance', value: widget.piggyBank.balance.toString()),
        Tag(key: 'piggybank_target', value: widget.piggyBank.targetAmount.toString()),
      ], 'APPBANK.Deposit.Step2View');
    } catch (e) {
      debugPrint('Error tracking deposit step 2: $e');
    }
  }

  bool _validateAmount() {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _amountError = 'Please enter an amount';
      });
      return false;
    }

    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Please enter a valid amount greater than 0';
      });
      return false;
    }

    if (amount > 10000) {
      setState(() {
        _amountError = 'Maximum amount is €10,000 per deposit';
      });
      return false;
    }

    setState(() {
      _amountError = null;
    });
    return true;
  }

  bool _validateConcept() {
    final text = _conceptController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _conceptError = 'Please enter a concept for this deposit';
      });
      return false;
    }

    if (text.length < 3) {
      setState(() {
        _conceptError = 'Concept must be at least 3 characters';
      });
      return false;
    }

    setState(() {
      _conceptError = null;
    });
    return true;
  }

  void _continue() {
    final isAmountValid = _validateAmount();
    final isConceptValid = _validateConcept();

    if (!isAmountValid || !isConceptValid) {
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final concept = _conceptController.text.trim();

    final updatedData = widget.depositData.copyWith(
      amount: amount,
      concept: concept,
    );

    // Track step completion
    _trackStepCompletion(amount, concept);

    widget.onNext(updatedData);
  }

  Future<void> _trackStepCompletion(double amount, String concept) async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'complete_deposit_step2'),
        Tag(key: 'deposit_amount', value: amount.toString()),
        Tag(key: 'concept_length', value: concept.length.toString()),
        Tag(key: 'step_result', value: 'success'),
      ], 'APPBANK.Deposit.Step2Complete');
    } catch (e) {
      debugPrint('Error tracking step 2 completion: $e');
    }
  }

  void _addQuickAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
    _validateAmount();
    
    // Track quick amount selection
    _trackQuickAmountSelection(amount);
  }

  Future<void> _trackQuickAmountSelection(double amount) async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'select_quick_amount'),
        Tag(key: 'quick_amount', value: amount.toString()),
      ], 'APPBANK.Deposit.QuickAmount');
    } catch (e) {
      debugPrint('Error tracking quick amount selection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingToGoal = widget.piggyBank.remainingAmount;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 2: Enter Amount & Concept',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How much would you like to deposit?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Amount section
          Text(
            'Amount',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (_) => _validateAmount(),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '€ ',
              prefixStyle: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green[600],
              ),
              errorText: _amountError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green[600]!, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick amounts
          Text(
            'Quick amounts',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuickAmountButton(10),
              const SizedBox(width: 8),
              _buildQuickAmountButton(25),
              const SizedBox(width: 8),
              _buildQuickAmountButton(50),
              const SizedBox(width: 8),
              _buildQuickAmountButton(100),
              if (remainingToGoal > 0 && remainingToGoal != 10 && remainingToGoal != 25 && remainingToGoal != 50 && remainingToGoal != 100) ...[
                const SizedBox(width: 8),
                _buildQuickAmountButton(remainingToGoal, label: 'Complete Goal'),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Concept section
          Text(
            'Concept',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _conceptController,
            focusNode: _conceptFocusNode,
            maxLength: 50,
            onChanged: (_) => _validateConcept(),
            decoration: InputDecoration(
              hintText: 'e.g., Monthly savings, Birthday money...',
              errorText: _conceptError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green[600]!, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Goal progress info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal Progress',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[600],
                        ),
                      ),
                      Text(
                        remainingToGoal > 0 
                            ? '€${remainingToGoal.toStringAsFixed(2)} remaining to reach your goal'
                            : 'Goal already completed! 🎉',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount, {String? label}) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _addQuickAmount(amount),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: BorderSide(color: Colors.green[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          label ?? '€${amount.toInt()}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.green[700],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _amountFocusNode.dispose();
    _conceptFocusNode.dispose();
    super.dispose();
  }
}
