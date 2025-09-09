import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:banking_app/models/account.dart';
import 'package:banking_app/models/card.dart';
import 'package:banking_app/models/transaction.dart';
import 'package:banking_app/models/piggybank.dart';
import 'package:banking_app/models/deposit.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class AppState extends ChangeNotifier {
  // User information
  String _userName = '';
  String _userEmail = '';

  // Financial data
  List<Account> _accounts = [];
  List<CreditCard> _cards = [];
  List<Transaction> _recentTransactions = [];
  List<PiggyBank> _piggyBanks = [];
  List<DepositTransaction> _depositTransactions = [];

  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDarkMode = false;

  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  List<Account> get accounts => List.unmodifiable(_accounts);
  List<CreditCard> get cards => List.unmodifiable(_cards);
  List<Transaction> get recentTransactions => List.unmodifiable(_recentTransactions);
  List<PiggyBank> get piggyBanks => List.unmodifiable(_piggyBanks);
  List<DepositTransaction> get depositTransactions => List.unmodifiable(_depositTransactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDarkMode => _isDarkMode;

  // Computed properties
  double get totalBalance => _accounts.fold(0.0, (sum, account) => sum + account.balance);
  double get totalCreditUsed => _cards.fold(0.0, (sum, card) => sum + card.currentBalance);
  double get totalCreditLimit => _cards.fold(0.0, (sum, card) => sum + card.limit);
  double get totalPiggyBankSavings => _piggyBanks.fold(0.0, (sum, piggyBank) => sum + piggyBank.balance);

  // Singleton pattern
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  /// Initialize app state with user data
  void initializeUserData(String email) {
    _userEmail = email;
    // Extract name from email for demo purposes
    _userName = email.split('@').first.split('.').map((part) {
      return part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : '';
    }).join(' ');

    _loadDemoData();
    
    // Track initial app settings
    _trackInitialAppSettings();
    
    notifyListeners();
  }

  /// Load demo data for the banking app
  void _loadDemoData() {
    _accounts = [
      Account(
        id: '1',
        accountNumber: '****1234',
        type: 'Checking Account',
        balance: 5000.0,
        currency: 'EUR',
      ),
      Account(
        id: '2',
        accountNumber: '****5678',
        type: 'Savings Account',
        balance: 15000.0,
        currency: 'EUR',
      ),
      Account(
        id: '3',
        accountNumber: '****9876',
        type: 'Investment Account',
        balance: 25000.0,
        currency: 'EUR',
      ),
    ];

    _cards = [
      CreditCard(
        id: '1',
        cardNumber: '**** **** **** 1234',
        cardHolder: _userName,
        expiryDate: '12/25',
        type: 'Visa',
        limit: 5000.0,
        currentBalance: 1500.0,
      ),
      CreditCard(
        id: '2',
        cardNumber: '**** **** **** 5678',
        cardHolder: _userName,
        expiryDate: '06/26',
        type: 'Mastercard',
        limit: 3000.0,
        currentBalance: 500.0,
      ),
    ];

    _recentTransactions = [
      Transaction(
        id: '1',
        description: 'Monthly Salary',
        amount: 3500.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'income',
        category: 'salary',
        reference: 'SAL001',
      ),
      Transaction(
        id: '2',
        description: 'Supermarket Shopping',
        amount: 150.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'expense',
        category: 'food',
        reference: 'EXP001',
      ),
      Transaction(
        id: '3',
        description: 'Coffee Shop',
        amount: 4.50,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'expense',
        category: 'food',
        reference: 'EXP002',
      ),
      Transaction(
        id: '4',
        description: 'Gas Station',
        amount: 60.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: 'expense',
        category: 'transport',
        reference: 'EXP003',
      ),
      Transaction(
        id: '5',
        description: 'Online Transfer',
        amount: 200.0,
        date: DateTime.now().subtract(const Duration(days: 4)),
        type: 'transfer',
        category: 'transfer',
        reference: 'TRF001',
      ),
    ];

    // Initialize demo piggy banks
    _piggyBanks = [
      PiggyBank(
        id: '1',
        name: 'Vacation Fund',
        description: 'Saving for summer vacation in Greece',
        balance: 0.0,
        targetAmount: 3000.0,
        currency: 'EUR',
        createdDate: DateTime.now().subtract(const Duration(days: 30)),
        status: 'active',
      ),
      PiggyBank(
        id: '2',
        name: 'Emergency Fund',
        description: 'Emergency savings for unexpected expenses',
        balance: 0.0,
        targetAmount: 5000.0,
        currency: 'EUR',
        createdDate: DateTime.now().subtract(const Duration(days: 15)),
        status: 'active',
      ),
      PiggyBank(
        id: '3',
        name: 'New Car',
        description: 'Saving for a new electric car',
        balance: 0.0,
        targetAmount: 25000.0,
        currency: 'EUR',
        createdDate: DateTime.now().subtract(const Duration(days: 60)),
        status: 'active',
      ),
    ];

    _depositTransactions = [];
  }

  /// Clear all user data (used on logout)
  void clearUserData() {
    _userName = '';
    _userEmail = '';
    _accounts.clear();
    _cards.clear();
    _recentTransactions.clear();
    _piggyBanks.clear();
    _depositTransactions.clear();
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user name
  void updateUserName(String newName) {
    _userName = newName;
    // Update card holder names
    for (int i = 0; i < _cards.length; i++) {
      _cards[i] = CreditCard(
        id: _cards[i].id,
        cardNumber: _cards[i].cardNumber,
        cardHolder: newName,
        expiryDate: _cards[i].expiryDate,
        type: _cards[i].type,
        limit: _cards[i].limit,
        currentBalance: _cards[i].currentBalance,
      );
    }
    notifyListeners();
  }

  /// Add a new transaction
  void addTransaction(Transaction transaction) {
    _recentTransactions.insert(0, transaction);
    
    // Update account balance if it's a transfer or payment
    if (transaction.type == 'transfer' || transaction.type == 'expense') {
      // Find the account and update balance (for demo, use first account)
      if (_accounts.isNotEmpty) {
        final account = _accounts[0];
        final newBalance = account.balance - transaction.amount;
        _accounts[0] = Account(
          id: account.id,
          accountNumber: account.accountNumber,
          type: account.type,
          balance: newBalance,
          currency: account.currency,
        );
      }
    } else if (transaction.type == 'income') {
      // Add to first account for income
      if (_accounts.isNotEmpty) {
        final account = _accounts[0];
        final newBalance = account.balance + transaction.amount;
        _accounts[0] = Account(
          id: account.id,
          accountNumber: account.accountNumber,
          type: account.type,
          balance: newBalance,
          currency: account.currency,
        );
      }
    }
    
    notifyListeners();
  }

  /// Transfer money between accounts
  void transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
  }) {
    setLoading(true);

    try {
      // Find accounts
      final fromAccountIndex = _accounts.indexWhere((a) => a.id == fromAccountId);
      final toAccountIndex = _accounts.indexWhere((a) => a.id == toAccountId);

      if (fromAccountIndex == -1 || toAccountIndex == -1) {
        throw Exception('Account not found');
      }

      final fromAccount = _accounts[fromAccountIndex];
      final toAccount = _accounts[toAccountIndex];

      if (fromAccount.balance < amount) {
        throw Exception('Insufficient funds');
      }

      // Update balances
      _accounts[fromAccountIndex] = Account(
        id: fromAccount.id,
        accountNumber: fromAccount.accountNumber,
        type: fromAccount.type,
        balance: fromAccount.balance - amount,
        currency: fromAccount.currency,
      );

      _accounts[toAccountIndex] = Account(
        id: toAccount.id,
        accountNumber: toAccount.accountNumber,
        type: toAccount.type,
        balance: toAccount.balance + amount,
        currency: toAccount.currency,
      );

      // Add transaction record
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: description,
        amount: amount,
        date: DateTime.now(),
        type: 'transfer',
        category: 'transfer',
        reference: 'TRF${DateTime.now().millisecondsSinceEpoch}',
      );

      _recentTransactions.insert(0, transaction);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setLoading(false);
    }
  }

  /// Update account balance (for demo purposes)
  void updateAccountBalance(String accountId, double newBalance) {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      final account = _accounts[index];
      _accounts[index] = Account(
        id: account.id,
        accountNumber: account.accountNumber,
        type: account.type,
        balance: newBalance,
        currency: account.currency,
      );
      notifyListeners();
    }
  }

  /// Update card balance
  void updateCardBalance(String cardId, double newBalance) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final card = _cards[index];
      _cards[index] = CreditCard(
        id: card.id,
        cardNumber: card.cardNumber,
        cardHolder: card.cardHolder,
        expiryDate: card.expiryDate,
        type: card.type,
        limit: card.limit,
        currentBalance: newBalance,
      );
      notifyListeners();
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get account by ID
  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get card by ID
  CreditCard? getCardById(String id) {
    try {
      return _cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get transactions for specific account
  List<Transaction> getTransactionsForAccount(String accountId) {
    // For demo purposes, return all recent transactions
    // In a real app, you'd filter by account
    return _recentTransactions;
  }

  /// Get transactions for specific card
  List<Transaction> getTransactionsForCard(String cardId) {
    // For demo purposes, return expense transactions
    return _recentTransactions.where((t) => t.type == 'expense').toList();
  }

  /// Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    
    // Track theme change with Obsly
    _trackThemeChange(_isDarkMode);
    
    notifyListeners();
  }

  /// Set dark mode state
  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      
      // Track theme change with Obsly
      _trackThemeChange(_isDarkMode);
      
      notifyListeners();
    }
  }

  /// Track theme changes with Obsly SDK
  void _trackThemeChange( bool newMode) async {
    try {
      // Get current locale from platform
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final localeString = '${locale.languageCode}_${locale.countryCode ?? 'Unknown'}';
      
      await ObslySDK.instance.addTag([
        Tag(key: 'theme_mode', value: newMode ? 'dark' : 'light'),
        Tag(key: 'app_locale', value: localeString),
      ], 'APP_SETTINGS');
    } catch (e) {
      debugPrint('Error tracking theme change: $e');
    }
  }

  /// Track initial app settings when user logs in
  void _trackInitialAppSettings() async {
    try {
      // Get current locale from platform
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final localeString = '${locale.languageCode}_${locale.countryCode ?? 'Unknown'}';
      
      await ObslySDK.instance.addTag([
        Tag(key: 'initial_theme_mode', value: _isDarkMode ? 'dark' : 'light'),
        Tag(key: 'app_locale', value: localeString),
        Tag(key: 'language_code', value: locale.languageCode),
        Tag(key: 'country_code', value: locale.countryCode ?? 'unknown'),
        Tag(key: 'user_preference_init', value: 'app_settings'),
        Tag(key: 'session_start', value: 'true'),
        Tag(key: 'timestamp', value: DateTime.now().toIso8601String()),
      ], 'APP_SETTINGS');

      debugPrint('🎯 Initial app settings tracked: theme=${_isDarkMode ? 'dark' : 'light'}, locale=$localeString');
    } catch (e) {
      debugPrint('Error tracking initial app settings: $e');
    }
  }

  // ============== PIGGY BANK METHODS ==============

  /// Get piggy bank by ID
  PiggyBank? getPiggyBankById(String id) {
    try {
      return _piggyBanks.firstWhere((piggyBank) => piggyBank.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Deposit money into a piggy bank
  Future<bool> depositToPiggyBank({
    required String fromAccountId,
    required String piggyBankId,
    required double amount,
    required String concept,
  }) async {
    setLoading(true);

    try {
      // Find account and piggy bank
      final accountIndex = _accounts.indexWhere((a) => a.id == fromAccountId);
      final piggyBankIndex = _piggyBanks.indexWhere((pb) => pb.id == piggyBankId);

      if (accountIndex == -1) {
        throw Exception('Source account not found');
      }

      if (piggyBankIndex == -1) {
        throw Exception('Piggy bank not found');
      }

      final fromAccount = _accounts[accountIndex];
      final piggyBank = _piggyBanks[piggyBankIndex];

      if (fromAccount.balance < amount) {
        throw Exception('Insufficient funds in source account');
      }

      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }

      // Track deposit start
      await _trackDepositStart(fromAccountId, piggyBankId, amount, concept);

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Update account balance (subtract amount)
      _accounts[accountIndex] = Account(
        id: fromAccount.id,
        accountNumber: fromAccount.accountNumber,
        type: fromAccount.type,
        balance: fromAccount.balance - amount,
        currency: fromAccount.currency,
      );

      // Update piggy bank balance (add amount)
      _piggyBanks[piggyBankIndex] = piggyBank.copyWith(
        balance: piggyBank.balance + amount,
      );

      // Create deposit transaction record
      final depositTransaction = DepositTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fromAccountId: fromAccountId,
        piggyBankId: piggyBankId,
        amount: amount,
        concept: concept,
        timestamp: DateTime.now(),
        status: 'completed',
        reference: 'DEP${DateTime.now().millisecondsSinceEpoch}',
      );

      _depositTransactions.insert(0, depositTransaction);

      // Create a general transaction record
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: 'Deposit to ${piggyBank.name}: $concept',
        amount: amount,
        date: DateTime.now(),
        type: 'piggybank_deposit',
        category: 'savings',
        reference: depositTransaction.reference ?? '',
      );

      _recentTransactions.insert(0, transaction);

      // Track successful deposit
      await _trackDepositSuccess(fromAccountId, piggyBankId, amount, concept);

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      
      // Track failed deposit
      await _trackDepositError(fromAccountId, piggyBankId, amount, concept, e.toString());
      
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Get deposit transactions for a specific piggy bank
  List<DepositTransaction> getDepositTransactionsForPiggyBank(String piggyBankId) {
    return _depositTransactions
        .where((transaction) => transaction.piggyBankId == piggyBankId)
        .toList();
  }

  /// Update piggy bank details
  void updatePiggyBank(String id, {
    String? name,
    String? description,
    double? targetAmount,
    String? status,
  }) {
    final index = _piggyBanks.indexWhere((pb) => pb.id == id);
    if (index != -1) {
      final piggyBank = _piggyBanks[index];
      _piggyBanks[index] = piggyBank.copyWith(
        name: name,
        description: description,
        targetAmount: targetAmount,
        status: status,
      );
      notifyListeners();
    }
  }

  // ============== OBSLY TRACKING METHODS FOR PIGGY BANKS ==============

  /// Track deposit process start
  Future<void> _trackDepositStart(String fromAccountId, String piggyBankId, double amount, String concept) async {
    try {
      final piggyBank = getPiggyBankById(piggyBankId);
      final account = getAccountById(fromAccountId);
      
      await ObslySDK.instance.addTag([
        Tag(key: 'process_id', value: DateTime.now().millisecondsSinceEpoch.toString()),
        Tag(key: 'user_action', value: 'start_piggybank_deposit'),
        Tag(key: 'from_account_id', value: fromAccountId),
        Tag(key: 'from_account_type', value: account?.type ?? 'unknown'),
        Tag(key: 'piggybank_id', value: piggyBankId),
        Tag(key: 'piggybank_name', value: piggyBank?.name ?? 'unknown'),
        Tag(key: 'deposit_amount', value: amount.toString()),
        Tag(key: 'deposit_concept', value: concept),
        Tag(key: 'entry_point', value: 'piggybank_deposit_flow'),
      ], 'APPBANK.PiggyBank.StartDeposit');

      debugPrint('🐷 Piggy bank deposit started - tracked in Obsly');
    } catch (e) {
      debugPrint('Error tracking deposit start: $e');
    }
  }

  /// Track successful deposit
  Future<void> _trackDepositSuccess(String fromAccountId, String piggyBankId, double amount, String concept) async {
    try {
      final piggyBank = getPiggyBankById(piggyBankId);
      final account = getAccountById(fromAccountId);
      
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'complete_piggybank_deposit'),
        Tag(key: 'from_account_id', value: fromAccountId),
        Tag(key: 'from_account_type', value: account?.type ?? 'unknown'),
        Tag(key: 'piggybank_id', value: piggyBankId),
        Tag(key: 'piggybank_name', value: piggyBank?.name ?? 'unknown'),
        Tag(key: 'deposit_amount', value: amount.toString()),
        Tag(key: 'deposit_concept', value: concept),
        Tag(key: 'new_piggybank_balance', value: piggyBank?.balance.toString() ?? '0'),
        Tag(key: 'progress_percentage', value: (piggyBank?.progressPercentage ?? 0).toString()),
        Tag(key: 'status', value: 'success'),
      ], 'APPBANK.PiggyBank.DepositComplete');

      debugPrint('✅ Piggy bank deposit completed - tracked in Obsly');
    } catch (e) {
      debugPrint('Error tracking deposit success: $e');
    }
  }

  /// Track deposit error
  Future<void> _trackDepositError(String fromAccountId, String piggyBankId, double amount, String concept, String error) async {
    try {
      final piggyBank = getPiggyBankById(piggyBankId);
      final account = getAccountById(fromAccountId);
      
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'failed_piggybank_deposit'),
        Tag(key: 'from_account_id', value: fromAccountId),
        Tag(key: 'from_account_type', value: account?.type ?? 'unknown'),
        Tag(key: 'piggybank_id', value: piggyBankId),
        Tag(key: 'piggybank_name', value: piggyBank?.name ?? 'unknown'),
        Tag(key: 'deposit_amount', value: amount.toString()),
        Tag(key: 'deposit_concept', value: concept),
        Tag(key: 'error_message', value: error),
        Tag(key: 'status', value: 'failed'),
      ], 'APPBANK.PiggyBank.DepositError');

      debugPrint('❌ Piggy bank deposit failed - tracked in Obsly: $error');
    } catch (e) {
      debugPrint('Error tracking deposit error: $e');
    }
  }
}
