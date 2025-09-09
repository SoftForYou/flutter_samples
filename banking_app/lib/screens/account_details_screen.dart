import 'dart:math';

import 'package:banking_app/models/account.dart';
import 'package:banking_app/models/transaction.dart';
import 'package:banking_app/screens/transaction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class AccountDetailsScreen extends StatelessWidget {
  final Account account;
  final List<Transaction> transactions;

  const AccountDetailsScreen({
    super.key,
    required this.account,
    required this.transactions,
  });

  void _setupObslyTracking() async {
    try {
      // Set up tracking for the account details screen
      await ObslySDK.instance.setView('account_details_screen');
      await ObslySDK.instance.setOperation('account_management');
      await ObslySDK.instance.setFunctionalBlock('accounts');
      await ObslySDK.instance.startHistogramTimer('operation_duration');
      await ObslySDK.instance.incCounter('attempt');
      final durationMs = Random().nextDouble() * 1.8 + 0.2;
      await Future.delayed(Duration(milliseconds: (durationMs * 1000).toInt()));
      if (account.type == "Savings Account") {
        await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'success');
      } else if (account.type == "Checking Account") {
        await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'failure');
      } else if (account.type == "Investment Account") {
        await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'crash');
      }
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
      await ObslySDK.instance.endHistogramTimer('operation_duration', state: 'failure');
    }
  }

  @override
  Widget build(BuildContext context) {
    _setupObslyTracking();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          account.type,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildBalanceCard(context),
          Expanded(
            child: _buildTransactionsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${account.currency} ${account.balance.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Account number: ${account.accountNumber}',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(context, transaction);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red : Colors.green;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/transaction-details'),
            builder: (context) => TransactionDetailsScreen(
              transaction: transaction,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTransactionIcon(transaction.category),
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.date),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'}${transaction.currency} ${transaction.amount.abs().toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'salary':
        return Icons.work;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
