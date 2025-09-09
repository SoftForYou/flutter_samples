import 'package:banking_app/models/transfer.dart';
import 'package:banking_app/models/transfer_error.dart';
import 'package:banking_app/screens/transfer_error_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class TransferResultScreen extends StatefulWidget {
  final TransferData transferData;

  const TransferResultScreen({
    super.key,
    required this.transferData,
  });

  @override
  State<TransferResultScreen> createState() => _TransferResultScreenState();
}

class _TransferResultScreenState extends State<TransferResultScreen> with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _successController;
  late Animation<double> _loadingAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successOpacityAnimation;

  bool _isLoading = true;
  bool _showSuccess = false;
  String _transferId = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _processTransfer();
    _setupObslyTracking();
  }

  void _setupAnimations() {
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _successOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _loadingController.repeat();
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('transfer_result');
      await ObslySDK.instance.setOperation('transfer_processing');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  void _processTransfer() async {
    // Simulate transfer processing
    await Future.delayed(const Duration(seconds: 3));

    // Check if beneficiary name matches an error code for simulation
    final beneficiaryName = widget.transferData.beneficiaryName ?? '';
    final simulatedError = TransferError.getErrorByBeneficiaryName(beneficiaryName);

    // si el importe es 200 , llamar al apiservice para invocar al
    if (simulatedError != null) {
      // Transfer failed - navigate to error screen
      _handleTransferError(simulatedError);
      return;
    }

    // Transfer successful - continue with success flow
    _handleTransferSuccess();
  }

  void _handleTransferError(TransferError error) async {
    // Track failed transfer with APPBANK category
    await _trackTransferEnd('KO', error.code);

    // Update transfer data with failed status
    final updatedData = widget.transferData.copy();
    updatedData.status = TransferStatus.failed;
    updatedData.processedAt = DateTime.now();

    _loadingController.stop();

    // Navigate to error screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TransferErrorScreen(
            transferData: updatedData,
            error: error,
          ),
        ),
      );
    }
  }

  void _handleTransferSuccess() async {
    // Generate a transfer ID
    _transferId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Update transfer data
    final updatedData = widget.transferData.copy();
    updatedData.id = _transferId;
    updatedData.status = TransferStatus.completed;
    updatedData.processedAt = DateTime.now();

    // Track successful transfer with APPBANK category
    await _trackTransferEnd('OK', null);

    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });

    _loadingController.stop();
    _successController.forward();
  }

  void _goToHome() {
    Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
  }

  void _makeAnotherTransfer() {
    Navigator.of(context).pop(); // Go back to transfer flow
  }

  /// Track transfer process end with status and reason
  Future<void> _trackTransferEnd(String status, String? reason) async {
    try {
      final tags = [
        Tag(key: 'status', value: status),
        Tag(key: 'transfer_id', value: _transferId.isNotEmpty ? _transferId : 'pending'),
        Tag(key: 'amount', value: widget.transferData.amount?.toString() ?? '0'),
        Tag(key: 'currency', value: widget.transferData.destinationCountry?.code ?? 'unknown'),
        Tag(key: 'transfer_type', value: widget.transferData.transferType?.name ?? 'unknown'),
        Tag(key: 'destination_country', value: widget.transferData.destinationCountry?.name ?? 'unknown'),
        Tag(key: 'user_action', value: 'complete_transfer'),
      ];

      // Add reason only if status is KO
      if (status == 'KO' && reason != null) {
        tags.add(Tag(key: 'reason', value: reason));
      }

      await ObslySDK.instance.addTag(tags, 'APPBANK.Transfer.endProcess');

      debugPrint('✅ Transfer process ended - Status: $status${reason != null ? ', Reason: $reason' : ''}');
    } catch (e) {
      debugPrint('Error tracking transfer end: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading, // Prevent back during loading
      child: Scaffold(
        appBar: _showSuccess
            ? AppBar(
                title: Text(
                  'Transfer Complete',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                automaticallyImplyLeading: false,
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading ? _buildLoadingView() : _buildSuccessView(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          AnimatedBuilder(
            animation: _loadingAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      value: _loadingAnimation.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.send,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Processing Transfer',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait while we process your transfer...',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Do not close the app during processing',
                    style: GoogleFonts.poppins(
                      color: Colors.blue[800],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Success animation
          AnimatedBuilder(
            animation: _successController,
            builder: (context, child) {
              return Transform.scale(
                scale: _successScaleAnimation.value,
                child: Opacity(
                  opacity: _successOpacityAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.green[600],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          Text(
            'Transfer Successful!',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Your transfer has been processed successfully',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Transfer summary card
          _buildTransferSummaryCard(),

          const SizedBox(height: 24),

          // Transfer ID card
          _buildTransferIdCard(),

          const SizedBox(height: 32),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTransferSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Amount', '€${widget.transferData.amount?.toStringAsFixed(2) ?? "0.00"}'),
            _buildSummaryRow('To', widget.transferData.beneficiaryName ?? ''),
            _buildSummaryRow('Country',
                '${widget.transferData.destinationCountry?.flag ?? ""} ${widget.transferData.destinationCountry?.name ?? ""}'),
            _buildSummaryRow('Type', widget.transferData.transferType?.displayName ?? ''),
            _buildSummaryRow('Concept', widget.transferData.concept ?? ''),
            if (widget.transferData.transferType == TransferType.scheduled)
              _buildSummaryRow(
                'Execution Date',
                '${widget.transferData.scheduledDate?.day}/${widget.transferData.scheduledDate?.month}/${widget.transferData.scheduledDate?.year}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildTransferIdCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer ID',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _transferId,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Copy to clipboard functionality could be added here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transfer ID copied to clipboard'),
                  backgroundColor: Colors.green[600],
                ),
              );
            },
            icon: const Icon(
              Icons.copy,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _goToHome,
            style: ElevatedButton.styleFrom(
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _makeAnotherTransfer,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Make Another Transfer',
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
    _loadingController.dispose();
    _successController.dispose();
    super.dispose();
  }
}
