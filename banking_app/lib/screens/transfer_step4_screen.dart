import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/models/transfer.dart';
import 'package:banking_app/models/account.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class TransferStep4Screen extends StatefulWidget {
  final List<Account> accounts;
  final TransferData transferData;
  final Function(TransferData) onConfirm;
  final VoidCallback onBack;

  const TransferStep4Screen({
    super.key,
    required this.accounts,
    required this.transferData,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  State<TransferStep4Screen> createState() => _TransferStep4ScreenState();
}

class _TransferStep4ScreenState extends State<TransferStep4Screen> {
  bool _isProcessing = false;
  Account? _originAccount;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupObslyTracking();
  }

  void _initializeData() {
    _originAccount = widget.accounts.firstWhere(
      (account) => account.id == widget.transferData.originAccountId,
    );
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('transfer_step4');
      await ObslySDK.instance.setOperation('confirm_transfer');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  void _confirmTransfer() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Track confirmation attempt
      await ObslySDK.instance.addTag([
        Tag(
            key: 'transfer_amount',
            value: widget.transferData.amount.toString()),
        Tag(
            key: 'transfer_type',
            value: widget.transferData.transferType?.name ?? ''),
        Tag(
            key: 'destination_country',
            value: widget.transferData.destinationCountry?.code ?? ''),
      ], 'transfers');

      // Small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onConfirm(widget.transferData);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming transfer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Transfer',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all details before confirming your transfer',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transfer Amount Card
                  _buildAmountCard(),
                  const SizedBox(height: 20),

                  // Transfer Details
                  _buildDetailsCard(),
                  const SizedBox(height: 20),

                  // Important Notice
                  _buildImportantNotice(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmTransfer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Confirm Transfer',
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

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Transfer Amount',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '€${widget.transferData.amount?.toStringAsFixed(2) ?? "0.00"}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.transferData.transferType?.displayName ?? '',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      key: const Key('transfer_details_card'), // ✅ FIX ISSUE #198
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              key: const Key('transfer_details_title'), // ✅ FIX ISSUE #198
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // From Account
            _buildDetailRow(
              'From Account',
              '${_originAccount?.type ?? ""}\n${_originAccount?.accountNumber ?? ""}',
              Icons.account_balance_wallet,
            ),

            const Divider(height: 24),

            // To Beneficiary
            _buildDetailRow(
              'To',
              '${widget.transferData.beneficiaryName ?? ""}\n${widget.transferData.destinationIban ?? ""}',
              Icons.person,
            ),

            const Divider(height: 24),

            // Country
            _buildDetailRow(
              'Country',
              '${widget.transferData.destinationCountry?.flag ?? ""} ${widget.transferData.destinationCountry?.name ?? ""}',
              Icons.public,
            ),

            const Divider(height: 24),

            // Concept
            _buildDetailRow(
              'Concept',
              widget.transferData.concept ?? '',
              Icons.note,
            ),

            // Execution Date (if scheduled)
            if (widget.transferData.transferType == TransferType.scheduled) ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Execution Date',
                '${widget.transferData.scheduledDate?.day}/${widget.transferData.scheduledDate?.month}/${widget.transferData.scheduledDate?.year}',
                Icons.calendar_today,
              ),
            ],

            // SWIFT (if required)
            if (widget.transferData.swiftBic != null &&
                widget.transferData.swiftBic!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailRow(
                'SWIFT/BIC',
                widget.transferData.swiftBic!,
                Icons.account_balance,
              ),
            ],

            // Additional Info (if provided)
            if (widget.transferData.additionalInfo != null &&
                widget.transferData.additionalInfo!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Additional Information',
                widget.transferData.additionalInfo!,
                Icons.info_outline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    // Generate specific key for each detail row - FIX ISSUE #198
    final keyString =
        'transfer_detail_${label.toLowerCase().replaceAll(' ', '_').replaceAll('/', '_')}';
    final rowKey = Key(keyString);

    return Row(
      key: rowKey, // ✅ FIX ISSUE #198
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                key: Key('${keyString}_label'), // ✅ FIX ISSUE #198 - Specific key for label
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                key: Key('${keyString}_text'), // ✅ FIX ISSUE #198 - Specific key for text value
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportantNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Text(
                'Important Notice',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Please verify all details are correct before confirming\n'
            '• Transfers cannot be cancelled once processed\n'
            '• Processing times may vary depending on destination\n'
            '• Additional fees may apply from receiving bank',
            style: GoogleFonts.poppins(
              color: Colors.amber[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
