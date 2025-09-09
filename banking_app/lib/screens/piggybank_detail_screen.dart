import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/models/piggybank.dart';
import 'package:banking_app/models/deposit.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:banking_app/screens/deposit_screen.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class PiggyBankDetailScreen extends StatefulWidget {
  final PiggyBank piggyBank;

  const PiggyBankDetailScreen({
    super.key,
    required this.piggyBank,
  });

  @override
  State<PiggyBankDetailScreen> createState() => _PiggyBankDetailScreenState();
}

class _PiggyBankDetailScreenState extends State<PiggyBankDetailScreen> {
  @override
  void initState() {
    super.initState();
    _setupObslyTracking();
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('piggybank_detail_screen');
      await ObslySDK.instance.setOperation('savings_detail_view');
      await ObslySDK.instance.setFunctionalBlock('piggybanks');
      
      // Track piggy bank detail access
      await _trackPiggyBankDetailAccess();
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  /// Track piggy bank detail access
  Future<void> _trackPiggyBankDetailAccess() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'view_piggybank_detail'),
        Tag(key: 'piggybank_id', value: widget.piggyBank.id),
        Tag(key: 'piggybank_name', value: widget.piggyBank.name),
        Tag(key: 'piggybank_balance', value: widget.piggyBank.balance.toString()),
        Tag(key: 'progress_percentage', value: widget.piggyBank.progressPercentage.toString()),
        Tag(key: 'entry_point', value: 'piggybanks_list'),
      ], 'APPBANK.PiggyBank.ViewDetail');

      debugPrint('🐷 Piggy bank detail accessed - tracked in Obsly');
    } catch (e) {
      debugPrint('Error tracking piggy bank detail access: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Get updated piggy bank data
        final updatedPiggyBank = appState.getPiggyBankById(widget.piggyBank.id) ?? widget.piggyBank;
        final deposits = appState.getDepositTransactionsForPiggyBank(updatedPiggyBank.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              updatedPiggyBank.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // For demo purposes, just show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Edit piggy bank feature coming soon!',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.orange[600],
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProgressHeader(context, updatedPiggyBank),
                _buildQuickActions(context, updatedPiggyBank),
                _buildStatsSection(context, updatedPiggyBank),
                _buildDepositHistory(context, deposits),
              ],
            ),
          ),
          floatingActionButton: updatedPiggyBank.isComplete
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/deposit'),
                        builder: (context) => DepositScreen(piggyBank: updatedPiggyBank),
                      ),
                    );
                  },
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_circle),
                  label: Text(
                    'Add Money',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProgressHeader(BuildContext context, PiggyBank piggyBank) {
    final progressPercentage = piggyBank.progressPercentage;
    final progressColor = progressPercentage >= 1.0 
        ? Colors.green 
        : progressPercentage >= 0.5 
            ? Colors.orange 
            : Colors.blue;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [progressColor.withOpacity(0.1), progressColor.withOpacity(0.05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: progressColor, width: 8),
                color: Colors.white,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.savings,
                      size: 40,
                      color: progressColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progressPercentage * 100).toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              piggyBank.description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (piggyBank.isComplete)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🎉 Goal Completed!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, PiggyBank piggyBank) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              context,
              icon: Icons.add_circle,
              title: 'Add Money',
              subtitle: 'Make a deposit',
              color: Colors.green,
              onTap: piggyBank.isComplete 
                  ? null 
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/deposit'),
                          builder: (context) => DepositScreen(piggyBank: piggyBank),
                        ),
                      );
                    },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              context,
              icon: Icons.timeline,
              title: 'Progress',
              subtitle: 'View analytics',
              color: Colors.blue,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Progress analytics coming soon!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.blue[600],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              context,
              icon: Icons.share,
              title: 'Share',
              subtitle: 'Share progress',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Share feature coming soon!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.purple[600],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEnabled 
                      ? color.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isEnabled ? color : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, PiggyBank piggyBank) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Statistics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Current Balance',
                  '€${piggyBank.balance.toStringAsFixed(2)}',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Target Amount',
                  '€${piggyBank.targetAmount.toStringAsFixed(2)}',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Remaining',
                  '€${piggyBank.remainingAmount.toStringAsFixed(2)}',
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Progress',
                  '${(piggyBank.progressPercentage * 100).toInt()}%',
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: piggyBank.progressPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              piggyBank.progressPercentage >= 1.0 
                  ? Colors.green 
                  : piggyBank.progressPercentage >= 0.5 
                      ? Colors.orange 
                      : Colors.blue
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDepositHistory(BuildContext context, List<DepositTransaction> deposits) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deposit History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (deposits.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No deposits yet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start saving by making your first deposit!',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...deposits.take(10).map((deposit) => _buildDepositItem(context, deposit)).toList(),
        ],
      ),
    );
  }

  Widget _buildDepositItem(BuildContext context, DepositTransaction deposit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add_circle,
              color: Colors.green[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deposit.concept,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(deposit.timestamp),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+€${deposit.amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
