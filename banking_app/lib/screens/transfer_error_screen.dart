import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/models/transfer.dart';
import 'package:banking_app/models/transfer_error.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class TransferErrorScreen extends StatefulWidget {
  final TransferData transferData;
  final TransferError error;

  const TransferErrorScreen({
    super.key,
    required this.transferData,
    required this.error,
  });

  @override
  State<TransferErrorScreen> createState() => _TransferErrorScreenState();
}

class _TransferErrorScreenState extends State<TransferErrorScreen>
    with TickerProviderStateMixin {
  late AnimationController _errorController;
  late Animation<double> _errorScaleAnimation;
  late Animation<double> _errorOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupObslyTracking();
    _showErrorAnimation();
  }

  void _setupAnimations() {
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _errorScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.elasticOut,
    ));

    _errorOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('transfer_error');
      await ObslySDK.instance.setOperation('transfer_failed');
      
      // Track specific error details
      await ObslySDK.instance.addTag([
        Tag(key: 'error_code', value: widget.error.code),
        Tag(key: 'error_type', value: widget.error.type.displayName),
        Tag(key: 'transfer_amount', value: widget.transferData.amount.toString()),
        Tag(key: 'beneficiary_name', value: widget.transferData.beneficiaryName ?? ''),
        Tag(key: 'is_retryable', value: widget.error.isRetryable.toString()),
      ], 'transfers');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  void _showErrorAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _errorController.forward();
  }

  void _goToHome() {
    Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
  }

  void _retryTransfer() {
    if (widget.error.isRetryable) {
      Navigator.of(context).pop(); // Go back to transfer flow
    }
  }

  void _contactSupport() {
    // In a real app, this would open support chat, email, or phone
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contact Support',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help with error ${widget.error.code}?',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              _buildSupportOption(Icons.phone, 'Call Support', '+1 (555) 123-4567'),
              const SizedBox(height: 12),
              _buildSupportOption(Icons.email, 'Email Support', 'support@bank.com'),
              const SizedBox(height: 12),
              _buildSupportOption(Icons.chat, 'Live Chat', 'Available 24/7'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getErrorColor() {
    switch (widget.error.type) {
      case TransferErrorType.authentication:
      case TransferErrorType.authorization:
      case TransferErrorType.accountBlocked:
        return Colors.red[600]!;
      case TransferErrorType.connectionError:
      case TransferErrorType.serverUnavailable:
      case TransferErrorType.timeout:
      case TransferErrorType.serviceUnavailable:
        return Colors.orange[600]!;
      case TransferErrorType.insufficientFunds:
      case TransferErrorType.limitExceeded:
        return Colors.amber[600]!;
      default:
        return Colors.red[500]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transfer Failed',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: _getErrorColor(),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Error animation
                AnimatedBuilder(
                  animation: _errorController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _errorScaleAnimation.value,
                      child: Opacity(
                        opacity: _errorOpacityAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _getErrorColor().withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.error.icon,
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  widget.error.title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getErrorColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  widget.error.message,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Error details card
                _buildErrorDetailsCard(),
                
                const SizedBox(height: 24),
                
                // Transfer summary card
                _buildTransferSummaryCard(),
                
                if (widget.error.solution != null) ...[
                  const SizedBox(height: 24),
                  _buildSolutionCard(),
                ],
                
                const SizedBox(height: 32),
                
                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getErrorColor().withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: _getErrorColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Error Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getErrorColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow('Error Code', widget.error.code),
            _buildDetailRow('Category', widget.error.type.displayName),
            _buildDetailRow('Description', widget.error.description),
            _buildDetailRow('Can Retry', widget.error.isRetryable ? 'Yes' : 'No'),
            _buildDetailRow('Timestamp', DateTime.now().toString().substring(0, 19)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Failed Transfer Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow('Amount', '€${widget.transferData.amount?.toStringAsFixed(2) ?? "0.00"}'),
            _buildDetailRow('To', widget.transferData.beneficiaryName ?? ''),
            _buildDetailRow('Country', '${widget.transferData.destinationCountry?.flag ?? ""} ${widget.transferData.destinationCountry?.name ?? ""}'),
            _buildDetailRow('Type', widget.transferData.transferType?.displayName ?? ''),
            _buildDetailRow('Concept', widget.transferData.concept ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'How to Resolve',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.error.solution!,
            style: GoogleFonts.poppins(
              color: Colors.blue[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.error.isRetryable) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _retryTransfer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _contactSupport,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: _getErrorColor()),
            ),
            child: Text(
              'Contact Support',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getErrorColor(),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _goToHome,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Back to Home',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _errorController.dispose();
    super.dispose();
  }
}
