class Account {
  final String id;
  final String accountNumber;
  final String type;
  final double balance;
  final String currency;

  Account({
    required this.id,
    required this.accountNumber,
    required this.type,
    required this.balance,
    required this.currency,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      accountNumber: json['accountNumber'] as String,
      type: json['type'] as String,
      balance: json['balance'] as double,
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'type': type,
      'balance': balance,
      'currency': currency,
    };
  }
} 