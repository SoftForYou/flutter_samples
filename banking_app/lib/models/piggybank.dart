class PiggyBank {
  final String id;
  final String name;
  final String description;
  final double balance;
  final double targetAmount;
  final String currency;
  final DateTime createdDate;
  final String? imageUrl;
  final String status; // 'active', 'completed', 'paused'

  PiggyBank({
    required this.id,
    required this.name,
    required this.description,
    required this.balance,
    required this.targetAmount,
    required this.currency,
    required this.createdDate,
    this.imageUrl,
    this.status = 'active',
  });

  factory PiggyBank.fromJson(Map<String, dynamic> json) {
    return PiggyBank(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      balance: json['balance'] as double,
      targetAmount: json['targetAmount'] as double,
      currency: json['currency'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'balance': balance,
      'targetAmount': targetAmount,
      'currency': currency,
      'createdDate': createdDate.toIso8601String(),
      'imageUrl': imageUrl,
      'status': status,
    };
  }

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (balance / targetAmount).clamp(0.0, 1.0);
  }

  /// Remaining amount to reach target
  double get remainingAmount {
    return (targetAmount - balance).clamp(0.0, double.infinity);
  }

  /// Whether the piggy bank has reached its target
  bool get isComplete => balance >= targetAmount;

  /// Copy with method for creating modified instances
  PiggyBank copyWith({
    String? id,
    String? name,
    String? description,
    double? balance,
    double? targetAmount,
    String? currency,
    DateTime? createdDate,
    String? imageUrl,
    String? status,
  }) {
    return PiggyBank(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      balance: balance ?? this.balance,
      targetAmount: targetAmount ?? this.targetAmount,
      currency: currency ?? this.currency,
      createdDate: createdDate ?? this.createdDate,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }
}
