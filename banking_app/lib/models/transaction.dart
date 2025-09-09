class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String type; // 'income' o 'expense'
  final String category;
  final String? reference;
  final String currency;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.reference,
    this.currency = 'EUR',  // Valor por defecto
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      category: json['category'] as String,
      reference: json['reference'] as String?,
      currency: json['currency'] ?? 'EUR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'reference': reference,
      'currency': currency,
    };
  }
} 