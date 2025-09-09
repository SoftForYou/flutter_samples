import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/models/transaction.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  void _setupObslyTracking() async {
    try {
      // Set up tracking for the transaction details screen
      await ObslySDK.instance.setView('transaction_details_screen');
      await ObslySDK.instance.setOperation('transaction_review');
      await ObslySDK.instance.setFunctionalBlock('transactions');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _setupObslyTracking();

    // final isExpense = transaction.type == 'expense';
    // final amountColor = isExpense ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountCard(context),
            const SizedBox(height: 24),
            _buildDetailItem(
              context,
              'Description',
              transaction.description,
            ),
            _buildDetailItem(
              context,
              'Date',
              _formatDate(transaction.date),
            ),
            _buildDetailItem(
              context,
              'Category',
              transaction.category,
            ),
            if (transaction.reference != null)
              _buildDetailItem(
                context,
                'Reference',
                transaction.reference!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isExpense ? 'Expense' : 'Income',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isExpense ? '-' : '+'}${transaction.currency} ${transaction.amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
