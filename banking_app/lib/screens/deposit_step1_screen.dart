import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/models/account.dart';
import 'package:banking_app/models/deposit.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class DepositStep1Screen extends StatefulWidget {
  final List<Account> accounts;
  final DepositData depositData;
  final Function(DepositData) onNext;
  final VoidCallback onExit;

  const DepositStep1Screen({
    super.key,
    required this.accounts,
    required this.depositData,
    required this.onNext,
    required this.onExit,
  });

  @override
  State<DepositStep1Screen> createState() => _DepositStep1ScreenState();
}

class _DepositStep1ScreenState extends State<DepositStep1Screen> {
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.depositData.fromAccountId;
    _setupObslyTracking();
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'view_deposit_step1'),
        Tag(key: 'step_name', value: 'select_source_account'),
        Tag(key: 'available_accounts', value: widget.accounts.length.toString()),
      ], 'APPBANK.Deposit.Step1View');
    } catch (e) {
      debugPrint('Error tracking deposit step 1: $e');
    }
  }

  void _selectAccount(String accountId) {
    setState(() {
      _selectedAccountId = accountId;
    });
    
    // Track account selection
    _trackAccountSelection(accountId);
  }

  Future<void> _trackAccountSelection(String accountId) async {
    try {
      final account = widget.accounts.firstWhere((a) => a.id == accountId);
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'select_source_account'),
        Tag(key: 'selected_account_id', value: accountId),
        Tag(key: 'selected_account_type', value: account.type),
        Tag(key: 'account_balance', value: account.balance.toString()),
      ], 'APPBANK.Deposit.SelectAccount');
    } catch (e) {
      debugPrint('Error tracking account selection: $e');
    }
  }

  void _continue() {
    if (_selectedAccountId == null) return;

    final updatedData = widget.depositData.copyWith(
      fromAccountId: _selectedAccountId,
    );

    // Track step completion
    _trackStepCompletion();

    widget.onNext(updatedData);
  }

  Future<void> _trackStepCompletion() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'complete_deposit_step1'),
        Tag(key: 'selected_account_id', value: _selectedAccountId ?? 'none'),
        Tag(key: 'step_result', value: 'success'),
      ], 'APPBANK.Deposit.Step1Complete');
    } catch (e) {
      debugPrint('Error tracking step 1 completion: $e');
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
            'Step 1: Select Source Account',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the account you want to transfer money from',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: widget.accounts.length,
              itemBuilder: (context, index) {
                final account = widget.accounts[index];
                final isSelected = _selectedAccountId == account.id;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.green[600]! 
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected 
                        ? Colors.green[50] 
                        : Colors.white,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _selectAccount(account.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.green[600] 
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: isSelected 
                                    ? Colors.white 
                                    : Colors.grey[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.type,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    account.accountNumber,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '€${account.balance.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? Colors.green[600] 
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Available',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Radio<String>(
                              value: account.id,
                              groupValue: _selectedAccountId,
                              onChanged: (value) {
                                if (value != null) {
                                  _selectAccount(value);
                                }
                              },
                              activeColor: Colors.green[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAccountId != null ? _continue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
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
    );
  }
}
