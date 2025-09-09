import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/models/card.dart';
import 'package:banking_app/models/transaction.dart';
import 'package:banking_app/screens/transaction_details_screen.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class CardDetailsScreen extends StatelessWidget {
  final CreditCard card;
  final List<Transaction> transactions;

  const CardDetailsScreen({
    super.key,
    required this.card,
    required this.transactions,
  });

  void _setupObslyTracking() async {
    try {
      // Set up tracking for the card details screen
      await ObslySDK.instance.setView('card_details_screen');
      await ObslySDK.instance.setOperation('card_management');
      await ObslySDK.instance.setFunctionalBlock('cards');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _setupObslyTracking();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Card Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardPreview(context),
              const SizedBox(height: 24),
              _buildBalanceInfo(context),
              const SizedBox(height: 24),
              Text(
                'Last Transactions',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...transactions.map(
                  (transaction) => _buildTransactionItem(context, transaction)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).primaryColor,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.type,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  card.type == 'Visa' ? Icons.credit_card : Icons.credit_score,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              card.cardNumber,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.cardHolder,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  card.expiryDate,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBalanceRow(
              'Credit Limit',
              '€${card.limit.toStringAsFixed(2)}',
              Colors.grey[600]!,
            ),
            const SizedBox(height: 8),
            _buildBalanceRow(
              'Current Balance',
              '€${card.currentBalance.toStringAsFixed(2)}',
              Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            _buildBalanceRow(
              'Available',
              '€${(card.limit - card.currentBalance).toStringAsFixed(2)}',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow(String label, String value, Color valueColor) {
    return Row(
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
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == 'expense'
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.green.withValues(alpha: 0.1),
          child: Icon(
            _getTransactionIcon(transaction.category),
            color: transaction.type == 'expense' ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          transaction.description,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _formatDate(transaction.date),
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Text(
          '${transaction.type == 'expense' ? '-' : '+'}${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: transaction.type == 'expense' ? Colors.red : Colors.green,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailsScreen(
                transaction: transaction,
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getTransactionIcon(String category) {
    switch (category) {
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
