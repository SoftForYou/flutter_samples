import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/models/piggybank.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:banking_app/screens/piggybank_detail_screen.dart';
import 'package:banking_app/screens/deposit_screen.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class PiggyBanksScreen extends StatefulWidget {
  const PiggyBanksScreen({super.key});

  @override
  State<PiggyBanksScreen> createState() => _PiggyBanksScreenState();
}

class _PiggyBanksScreenState extends State<PiggyBanksScreen> {
  @override
  void initState() {
    super.initState();
    _setupObslyTracking();
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('piggybanks_screen');
      await ObslySDK.instance.setOperation('savings_management');
      await ObslySDK.instance.setFunctionalBlock('piggybanks');
      
      // Track piggy banks screen access
      await _trackPiggyBanksAccess();
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  /// Track piggy banks screen access
  Future<void> _trackPiggyBanksAccess() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'view_piggybanks'),
        Tag(key: 'entry_point', value: 'dashboard_quick_action'),
        Tag(key: 'timestamp', value: DateTime.now().toIso8601String()),
      ], 'APPBANK.PiggyBank.ViewList');

      debugPrint('🐷 Piggy banks screen accessed - tracked in Obsly');
    } catch (e) {
      debugPrint('Error tracking piggy banks access: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final piggyBanks = appState.piggyBanks;
        final totalSavings = appState.totalPiggyBankSavings;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'My Piggy Banks',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(context, totalSavings, piggyBanks.length),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'My Savings Goals'),
                  const SizedBox(height: 16),
                  if (piggyBanks.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...piggyBanks.map((piggyBank) => 
                      _buildPiggyBankCard(context, piggyBank)
                    ).toList(),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // For demo purposes, just show a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Create new piggy bank feature coming soon!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green[600],
                ),
              );
            },
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(
              'New Goal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, double totalSavings, int totalGoals) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.savings,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Total Savings',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '€${totalSavings.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$totalGoals active savings goals',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPiggyBankCard(BuildContext context, PiggyBank piggyBank) {
    final progressPercentage = piggyBank.progressPercentage;
    final progressColor = progressPercentage >= 1.0 
        ? Colors.green 
        : progressPercentage >= 0.5 
            ? Colors.orange 
            : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/piggybank-detail'),
                builder: (context) => PiggyBankDetailScreen(piggyBank: piggyBank),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            piggyBank.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            piggyBank.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(progressPercentage * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: progressColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '€${piggyBank.balance.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Target',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '€${piggyBank.targetAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 6,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      piggyBank.isComplete 
                          ? 'Goal completed! 🎉' 
                          : '€${piggyBank.remainingAmount.toStringAsFixed(2)} remaining',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: piggyBank.isComplete 
                            ? Colors.green[600] 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: piggyBank.isComplete 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                    ),
                    if (!piggyBank.isComplete)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: '/deposit'),
                              builder: (context) => DepositScreen(piggyBank: piggyBank),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle, size: 16),
                        label: Text(
                          'Add Money',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.savings_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Savings Goals Yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your savings journey by creating your first piggy bank!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Create new piggy bank feature coming soon!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.green[600],
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Create Your First Goal',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
