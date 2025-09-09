import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/models/piggybank.dart';
import 'package:banking_app/models/deposit.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:banking_app/screens/piggybank_detail_screen.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class DepositResultScreen extends StatefulWidget {
  final DepositData depositData;
  final PiggyBank piggyBank;

  const DepositResultScreen({
    super.key,
    required this.depositData,
    required this.piggyBank,
  });

  @override
  State<DepositResultScreen> createState() => _DepositResultScreenState();
}

class _DepositResultScreenState extends State<DepositResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _successAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _successAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupObslyTracking();
    _startAnimations();
  }

  void _setupAnimations() {
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'view_deposit_result'),
        Tag(key: 'deposit_amount', value: widget.depositData.amount?.toString() ?? '0'),
        Tag(key: 'deposit_successful', value: widget.depositData.isComplete.toString()),
        Tag(key: 'piggybank_id', value: widget.piggyBank.id),
      ], 'APPBANK.Deposit.ViewResult');
    } catch (e) {
      debugPrint('Error tracking deposit result: $e');
    }
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _successAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _progressAnimationController.forward();
    });
  }

  void _goToPiggyBankDetail() {
    // Track navigation to piggy bank detail
    _trackNavigationToPiggyBank();
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/piggybank-detail'),
        builder: (context) => PiggyBankDetailScreen(piggyBank: widget.piggyBank),
      ),
      (route) => route.settings.name == '/dashboard' || route.settings.name == '/',
    );
  }

  void _goToDashboard() {
    // Track navigation to dashboard
    _trackNavigationToDashboard();
    
    Navigator.of(context).popUntil(
      (route) => route.settings.name == '/dashboard' || route.settings.name == '/',
    );
  }

  Future<void> _trackNavigationToPiggyBank() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'navigate_to_piggybank_detail'),
        Tag(key: 'from_screen', value: 'deposit_result'),
        Tag(key: 'piggybank_id', value: widget.piggyBank.id),
      ], 'APPBANK.Deposit.NavigateToPiggyBank');
    } catch (e) {
      debugPrint('Error tracking navigation to piggy bank: $e');
    }
  }

  Future<void> _trackNavigationToDashboard() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'navigate_to_dashboard'),
        Tag(key: 'from_screen', value: 'deposit_result'),
      ], 'APPBANK.Deposit.NavigateToDashboard');
    } catch (e) {
      debugPrint('Error tracking navigation to dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Get updated piggy bank data
        final updatedPiggyBank = appState.getPiggyBankById(widget.piggyBank.id) ?? widget.piggyBank;
        final newProgress = updatedPiggyBank.progressPercentage;
        final isGoalCompleted = updatedPiggyBank.isComplete;

        return WillPopScope(
          onWillPop: () async {
            _goToDashboard();
            return false;
          },
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                    
                    // Success icon with animation
                    AnimatedBuilder(
                      animation: _successAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _successAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green[600],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green[600]!.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Success message
                    Text(
                      isGoalCompleted ? 'Goal Completed! 🎉' : 'Deposit Successful!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      isGoalCompleted 
                          ? 'Congratulations! You\'ve reached your savings goal.'
                          : 'Your money has been successfully added to your piggy bank.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Deposit amount - más compacto
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[50]!, Colors.green[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.euro,
                            color: Colors.green[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount Deposited',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '€${widget.depositData.amount!.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[600],
                                  ),
                                ),
                                Text(
                                  widget.depositData.concept!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Progress section - más compacto
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200]!,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                updatedPiggyBank.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isGoalCompleted 
                                      ? Colors.green[600] 
                                      : Colors.blue[600],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${(newProgress * 100).toInt()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Balance',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '€${updatedPiggyBank.balance.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Target Amount',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '€${updatedPiggyBank.targetAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Animated progress bar
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: newProgress * _progressAnimation.value,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isGoalCompleted ? Colors.green[600]! : Colors.blue[600]!,
                                ),
                                minHeight: 8,
                              );
                            },
                          ),
                          
                          const SizedBox(height: 12),
                          
                          if (!isGoalCompleted)
                            Text(
                              '€${updatedPiggyBank.remainingAmount.toStringAsFixed(2)} remaining to reach your goal',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            )
                          else
                            Text(
                              'Congratulations! You\'ve reached your savings goal! 🎉',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _goToPiggyBankDetail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'View Piggy Bank Details',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _goToDashboard,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Back to Dashboard',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _successAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }
}
