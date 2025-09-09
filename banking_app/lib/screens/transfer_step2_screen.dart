import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/models/transfer.dart';
import 'package:banking_app/models/account.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class TransferStep2Screen extends StatefulWidget {
  final List<Account> accounts;
  final TransferData transferData;
  final Function(TransferData) onNext;
  final VoidCallback onBack;

  const TransferStep2Screen({
    super.key,
    required this.accounts,
    required this.transferData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<TransferStep2Screen> createState() => _TransferStep2ScreenState();
}

class _TransferStep2ScreenState extends State<TransferStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  
  TransferType? _selectedTransferType;
  DateTime? _scheduledDate;
  Account? _originAccount;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupObslyTracking();
  }

  void _initializeData() {
    // Get origin account
    _originAccount = widget.accounts.firstWhere(
      (account) => account.id == widget.transferData.originAccountId,
    );

    // Load existing data if available
    if (widget.transferData.amount != null) {
      _amountController.text = widget.transferData.amount!.toStringAsFixed(2);
    }
    
    if (widget.transferData.concept != null) {
      _conceptController.text = widget.transferData.concept!;
    }
    
    _selectedTransferType = widget.transferData.transferType;
    _scheduledDate = widget.transferData.scheduledDate;
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('transfer_step2');
      await ObslySDK.instance.setOperation('set_amount_schedule');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  void _continue() {
    if (_formKey.currentState!.validate() && _selectedTransferType != null) {
      final updatedData = widget.transferData.copy();
      updatedData.amount = double.parse(_amountController.text);
      updatedData.transferType = _selectedTransferType;
      updatedData.concept = _conceptController.text.trim();
      
      if (_selectedTransferType == TransferType.scheduled) {
        updatedData.scheduledDate = _scheduledDate;
      } else {
        updatedData.scheduledDate = null;
      }

      widget.onNext(updatedData);
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (_originAccount != null && amount > _originAccount!.balance) {
      return 'Insufficient funds';
    }
    
    if (amount > 100000) {
      return 'Amount exceeds transfer limit';
    }
    
    return null;
  }

  String? _validateConcept(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a concept';
    }
    
    if (value.trim().length < 3) {
      return 'Concept must be at least 3 characters';
    }
    
    return null;
  }

  Future<void> _selectDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final maxDate = DateTime.now().add(const Duration(days: 365));
    
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? tomorrow,
      firstDate: tomorrow,
      lastDate: maxDate,
    );
    
    if (date != null) {
      setState(() {
        _scheduledDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount & Scheduling',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter transfer amount and select when to process it',
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
                    // Origin Account Info
                    _buildOriginAccountInfo(),
                    const SizedBox(height: 24),
                    
                    // Amount Section
                    _buildSectionTitle('Transfer Amount'),
                    const SizedBox(height: 12),
                    _buildAmountField(),
                    const SizedBox(height: 24),
                    
                    // Transfer Type Section
                    _buildSectionTitle('Processing Time'),
                    const SizedBox(height: 12),
                    _buildTransferTypeSelector(),
                    const SizedBox(height: 24),
                    
                    // Concept Section
                    _buildSectionTitle('Concept'),
                    const SizedBox(height: 12),
                    _buildConceptField(),
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
                    onPressed: widget.onBack,
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
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildOriginAccountInfo() {
    if (_originAccount == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: ${_originAccount!.type}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Available: ${_originAccount!.currency} ${_originAccount!.balance.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.euro),
        suffixText: _originAccount?.currency ?? 'EUR',
        hintText: '0.00',
      ),
      validator: _validateAmount,
    );
  }

  Widget _buildTransferTypeSelector() {
    return Column(
      children: TransferType.values.map((type) {
        final isSelected = _selectedTransferType == type;
        final requiresDate = type == TransferType.scheduled;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
              ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
              : null,
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedTransferType = type;
                if (type != TransferType.scheduled) {
                  _scheduledDate = null;
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Radio<TransferType>(
                        value: type,
                        groupValue: _selectedTransferType,
                        onChanged: (value) {
                          setState(() {
                            _selectedTransferType = value;
                            if (value != TransferType.scheduled) {
                              _scheduledDate = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.displayName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              type.description,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'FREE',
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  // Date selector for scheduled transfers
                  if (requiresDate && isSelected) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _scheduledDate != null
                                ? 'Execute on: ${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                                : 'Select execution date',
                              style: GoogleFonts.poppins(
                                color: _scheduledDate != null 
                                  ? Colors.black87 
                                  : Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConceptField() {
    return TextFormField(
      controller: _conceptController,
      decoration: InputDecoration(
        labelText: 'Transfer Concept',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.note),
        hintText: 'e.g., Rent payment, Gift, etc.',
      ),
      maxLength: 140,
      validator: _validateConcept,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }
}
