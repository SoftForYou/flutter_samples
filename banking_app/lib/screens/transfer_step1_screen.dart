import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/models/transfer.dart';
import 'package:banking_app/models/account.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class TransferStep1Screen extends StatefulWidget {
  final List<Account> accounts;
  final TransferData transferData;
  final Function(TransferData) onNext;
  final VoidCallback onExit;

  const TransferStep1Screen({
    super.key,
    required this.accounts,
    required this.transferData,
    required this.onNext,
    required this.onExit,
  });

  @override
  State<TransferStep1Screen> createState() => _TransferStep1ScreenState();
}

class _TransferStep1ScreenState extends State<TransferStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  final _beneficiaryController = TextEditingController();
  
  Account? _selectedAccount;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupObslyTracking();
  }

  void _initializeData() {
    // Load existing data if available
    if (widget.transferData.originAccountId != null) {
      _selectedAccount = widget.accounts.firstWhere(
        (account) => account.id == widget.transferData.originAccountId,
        orElse: () => widget.accounts.first,
      );
    }
    
    if (widget.transferData.destinationIban != null) {
      _ibanController.text = widget.transferData.destinationIban!;
    }
    
    if (widget.transferData.beneficiaryName != null) {
      _beneficiaryController.text = widget.transferData.beneficiaryName!;
    }
    
    _selectedCountry = widget.transferData.destinationCountry;
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.setView('transfer_step1');
      await ObslySDK.instance.setOperation('select_origin_destination');
    } catch (e) {
      debugPrint('Error setting up Obsly tracking: $e');
    }
  }

  void _continue() {
    if (_formKey.currentState!.validate() && 
        _selectedAccount != null && 
        _selectedCountry != null) {
      
      final updatedData = widget.transferData.copy();
      updatedData.originAccountId = _selectedAccount!.id;
      updatedData.destinationIban = _ibanController.text.trim();
      updatedData.destinationCountry = _selectedCountry;
      updatedData.beneficiaryName = _beneficiaryController.text.trim();

      widget.onNext(updatedData);
    }
  }

  String? _validateIban(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an account number';
    }
    
    return null; // No validation - accept any format
  }

  String? _validateBeneficiary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter beneficiary name';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
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
              'Origin & Destination',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your origin account and enter destination details',
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
                    // Origin Account Section
                    _buildSectionTitle('From Account'),
                    const SizedBox(height: 12),
                    _buildAccountSelector(),
                    const SizedBox(height: 24),
                    
                    // Destination Section
                    _buildSectionTitle('To'),
                    const SizedBox(height: 12),
                    _buildCountrySelector(),
                    const SizedBox(height: 16),
                    _buildIbanField(),
                    const SizedBox(height: 16),
                    _buildBeneficiaryField(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
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

  Widget _buildAccountSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: widget.accounts.map((account) {
          final isSelected = _selectedAccount?.id == account.id;
          
          return InkWell(
            onTap: () {
              setState(() {
                _selectedAccount = account;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
                border: Border(
                  bottom: account != widget.accounts.last 
                    ? BorderSide(color: Colors.grey[200]!)
                    : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: account.id,
                    groupValue: _selectedAccount?.id,
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = account;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.type,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.accountNumber,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${account.currency} ${account.balance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCountrySelector() {
    return DropdownButtonFormField<Country>(
      value: _selectedCountry,
      decoration: InputDecoration(
        labelText: 'Destination Country',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.public),
      ),
      items: Country.availableCountries.map((country) {
        return DropdownMenuItem<Country>(
          value: country,
          child: Row(
            children: [
              Text(
                country.flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Text(
                country.name,
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (country) {
        setState(() {
          _selectedCountry = country;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a country';
        }
        return null;
      },
    );
  }

  Widget _buildIbanField() {
    return TextFormField(
      controller: _ibanController,
      decoration: InputDecoration(
        labelText: 'Account Number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.account_balance),
        hintText: 'Enter account number or IBAN',
      ),
      textCapitalization: TextCapitalization.characters,
      validator: _validateIban,
    );
  }

  Widget _buildBeneficiaryField() {
    return TextFormField(
      controller: _beneficiaryController,
      decoration: InputDecoration(
        labelText: 'Beneficiary Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.person),
        hintText: 'Full name of the recipient',
      ),
      textCapitalization: TextCapitalization.words,
      validator: _validateBeneficiary,
    );
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _beneficiaryController.dispose();
    super.dispose();
  }
}
