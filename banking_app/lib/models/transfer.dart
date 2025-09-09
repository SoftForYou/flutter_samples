enum TransferType {
  immediate,
  normal,
  scheduled,
}

enum TransferStatus {
  draft,
  processing,
  completed,
  failed,
  cancelled,
}

class Country {
  final String code;
  final String name;
  final String flag;
  final bool requiresSwift;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
    this.requiresSwift = false,
  });

  static const List<Country> availableCountries = [
    Country(code: 'ES', name: 'Spain', flag: '🇪🇸', requiresSwift: false),
    Country(code: 'FR', name: 'France', flag: '🇫🇷', requiresSwift: false),
    Country(code: 'DE', name: 'Germany', flag: '🇩🇪', requiresSwift: false),
    Country(code: 'IT', name: 'Italy', flag: '🇮🇹', requiresSwift: false),
    Country(code: 'PT', name: 'Portugal', flag: '🇵🇹', requiresSwift: false),
    Country(code: 'GB', name: 'United Kingdom', flag: '🇬🇧', requiresSwift: false),
    Country(code: 'US', name: 'United States', flag: '🇺🇸', requiresSwift: false),
    Country(code: 'CH', name: 'Switzerland', flag: '🇨🇭', requiresSwift: false),
    Country(code: 'NO', name: 'Norway', flag: '🇳🇴', requiresSwift: false),
    Country(code: 'SE', name: 'Sweden', flag: '🇸🇪', requiresSwift: false),
  ];

  static Country? findByCode(String code) {
    try {
      return availableCountries.firstWhere((country) => country.code == code);
    } catch (e) {
      return null;
    }
  }
}

class TransferData {
  // Step 1: Account and Destination
  String? originAccountId;
  String? destinationIban;
  Country? destinationCountry;
  String? beneficiaryName;

  // Step 2: Amount and Scheduling
  double? amount;
  TransferType? transferType;
  DateTime? scheduledDate;
  String? concept;

  // Step 3: Additional Information
  String? swiftBic;
  String? additionalInfo;

  // Metadata
  String? id;
  TransferStatus status;
  DateTime? createdAt;
  DateTime? processedAt;

  TransferData({
    this.originAccountId,
    this.destinationIban,
    this.destinationCountry,
    this.beneficiaryName,
    this.amount,
    this.transferType,
    this.scheduledDate,
    this.concept,
    this.swiftBic,
    this.additionalInfo,
    this.id,
    this.status = TransferStatus.draft,
    this.createdAt,
    this.processedAt,
  });

  bool get isStep1Complete => 
    originAccountId != null &&
    destinationIban != null &&
    destinationCountry != null &&
    beneficiaryName != null &&
    beneficiaryName!.trim().isNotEmpty;

  bool get isStep2Complete =>
    amount != null &&
    amount! > 0 &&
    transferType != null &&
    concept != null &&
    concept!.trim().isNotEmpty &&
    (transferType != TransferType.scheduled || scheduledDate != null);

  bool get isComplete => isStep1Complete && isStep2Complete;

  TransferData copy() {
    return TransferData(
      originAccountId: originAccountId,
      destinationIban: destinationIban,
      destinationCountry: destinationCountry,
      beneficiaryName: beneficiaryName,
      amount: amount,
      transferType: transferType,
      scheduledDate: scheduledDate,
      concept: concept,
      swiftBic: swiftBic,
      additionalInfo: additionalInfo,
      id: id,
      status: status,
      createdAt: createdAt,
      processedAt: processedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originAccountId': originAccountId,
      'destinationIban': destinationIban,
      'destinationCountry': destinationCountry?.code,
      'beneficiaryName': beneficiaryName,
      'amount': amount,
      'transferType': transferType?.name,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'concept': concept,
      'swiftBic': swiftBic,
      'additionalInfo': additionalInfo,
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
    };
  }

  factory TransferData.fromJson(Map<String, dynamic> json) {
    return TransferData(
      id: json['id'],
      originAccountId: json['originAccountId'],
      destinationIban: json['destinationIban'],
      destinationCountry: json['destinationCountry'] != null 
        ? Country.findByCode(json['destinationCountry'])
        : null,
      beneficiaryName: json['beneficiaryName'],
      amount: json['amount'],
      transferType: json['transferType'] != null
        ? TransferType.values.firstWhere((e) => e.name == json['transferType'])
        : null,
      scheduledDate: json['scheduledDate'] != null
        ? DateTime.parse(json['scheduledDate'])
        : null,
      concept: json['concept'],
      swiftBic: json['swiftBic'],
      additionalInfo: json['additionalInfo'],
      status: TransferStatus.values.firstWhere(
        (e) => e.name == json['status'], 
        orElse: () => TransferStatus.draft,
      ),
      createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
      processedAt: json['processedAt'] != null
        ? DateTime.parse(json['processedAt'])
        : null,
    );
  }
}

extension TransferTypeExtension on TransferType {
  String get displayName {
    switch (this) {
      case TransferType.immediate:
        return 'Immediate';
      case TransferType.normal:
        return 'Normal (1-2 business days)';
      case TransferType.scheduled:
        return 'Scheduled';
    }
  }

  String get description {
    switch (this) {
      case TransferType.immediate:
        return 'Transfer processed instantly';
      case TransferType.normal:
        return 'Transfer processed within 1-2 business days';
      case TransferType.scheduled:
        return 'Transfer processed on specified date';
    }
  }
}

extension TransferStatusExtension on TransferStatus {
  String get displayName {
    switch (this) {
      case TransferStatus.draft:
        return 'Draft';
      case TransferStatus.processing:
        return 'Processing';
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.failed:
        return 'Failed';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }
}
