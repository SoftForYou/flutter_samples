class CreditCard {
  final String id;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String type;
  final double limit;
  final double currentBalance;

  CreditCard({
    required this.id,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.type,
    required this.limit,
    required this.currentBalance,
  });

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'] as String,
      cardNumber: json['cardNumber'] as String,
      cardHolder: json['cardHolder'] as String,
      expiryDate: json['expiryDate'] as String,
      type: json['type'] as String,
      limit: json['limit'] as double,
      currentBalance: json['currentBalance'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
      'type': type,
      'limit': limit,
      'currentBalance': currentBalance,
    };
  }
} 