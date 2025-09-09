class DepositData {
  String? fromAccountId;
  String? piggyBankId;
  double? amount;
  String? concept;
  bool isComplete = false;

  DepositData({
    this.fromAccountId,
    this.piggyBankId,
    this.amount,
    this.concept,
  });

  /// Check if all required fields are filled
  bool get isValid => 
    fromAccountId != null && 
    fromAccountId!.isNotEmpty &&
    piggyBankId != null &&
    piggyBankId!.isNotEmpty &&
    amount != null &&
    amount! > 0 &&
    concept != null &&
    concept!.isNotEmpty;

  /// Copy with method for creating modified instances
  DepositData copyWith({
    String? fromAccountId,
    String? piggyBankId,
    double? amount,
    String? concept,
    bool? isComplete,
  }) {
    return DepositData(
      fromAccountId: fromAccountId ?? this.fromAccountId,
      piggyBankId: piggyBankId ?? this.piggyBankId,
      amount: amount ?? this.amount,
      concept: concept ?? this.concept,
    )..isComplete = isComplete ?? this.isComplete;
  }

  /// Convert to JSON for tracking/logging
  Map<String, dynamic> toJson() {
    return {
      'fromAccountId': fromAccountId,
      'piggyBankId': piggyBankId,
      'amount': amount,
      'concept': concept,
      'isComplete': isComplete,
    };
  }

  /// Create from JSON
  factory DepositData.fromJson(Map<String, dynamic> json) {
    return DepositData(
      fromAccountId: json['fromAccountId'] as String?,
      piggyBankId: json['piggyBankId'] as String?,
      amount: json['amount'] as double?,
      concept: json['concept'] as String?,
    )..isComplete = json['isComplete'] as bool? ?? false;
  }
}

class DepositTransaction {
  final String id;
  final String fromAccountId;
  final String piggyBankId;
  final double amount;
  final String concept;
  final DateTime timestamp;
  final String status; // 'pending', 'completed', 'failed'
  final String? reference;

  DepositTransaction({
    required this.id,
    required this.fromAccountId,
    required this.piggyBankId,
    required this.amount,
    required this.concept,
    required this.timestamp,
    this.status = 'completed',
    this.reference,
  });

  factory DepositTransaction.fromJson(Map<String, dynamic> json) {
    return DepositTransaction(
      id: json['id'] as String,
      fromAccountId: json['fromAccountId'] as String,
      piggyBankId: json['piggyBankId'] as String,
      amount: json['amount'] as double,
      concept: json['concept'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'completed',
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromAccountId': fromAccountId,
      'piggyBankId': piggyBankId,
      'amount': amount,
      'concept': concept,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'reference': reference,
    };
  }
}
