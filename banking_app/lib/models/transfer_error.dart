enum TransferErrorType {
  authentication,
  authorization,
  sessionExpired,
  connectionError,
  serverUnavailable,
  timeout,
  dataValidation,
  accountFormat,
  invalidAmount,
  insufficientFunds,
  limitExceeded,
  accountBlocked,
  invalidBeneficiary,
  duplicateTransaction,
  internalError,
  serviceUnavailable,
}

class TransferError {
  final String code;
  final String title;
  final String message;
  final String description;
  final TransferErrorType type;
  final String icon;
  final String? solution;
  final bool isRetryable;

  const TransferError({
    required this.code,
    required this.title,
    required this.message,
    required this.description,
    required this.type,
    required this.icon,
    this.solution,
    this.isRetryable = false,
  });

  static const Map<String, TransferError> errorCodes = {
    // Error de autenticación
    'AUTH001': TransferError(
      code: 'AUTH001',
      title: 'Authentication Error',
      message: 'Authentication failed',
      description: 'Unable to verify your identity. Please log in again.',
      type: TransferErrorType.authentication,
      icon: '🔐',
      solution: 'Please log out and log back in to continue.',
      isRetryable: false,
    ),

    // Error de autorización
    'AUTH002': TransferError(
      code: 'AUTH002',
      title: 'Authorization Error',
      message: 'Not authorized to perform this operation',
      description: 'You don\'t have sufficient permissions to make this transfer.',
      type: TransferErrorType.authorization,
      icon: '🚫',
      solution: 'Contact your bank to verify your transfer permissions.',
      isRetryable: false,
    ),

    // Error de sesión expirada
    'SES001': TransferError(
      code: 'SES001',
      title: 'Session Expired',
      message: 'Your session has expired',
      description: 'For security reasons, your session has timed out.',
      type: TransferErrorType.sessionExpired,
      icon: '⏰',
      solution: 'Please log in again to continue your transfer.',
      isRetryable: false,
    ),

    // Error de conexión a internet
    'NET001': TransferError(
      code: 'NET001',
      title: 'Connection Error',
      message: 'No internet connection',
      description: 'Unable to connect to the banking servers. Check your internet connection.',
      type: TransferErrorType.connectionError,
      icon: '📶',
      solution: 'Check your internet connection and try again.',
      isRetryable: true,
    ),

    // Error de servidor no disponible
    'SRV001': TransferError(
      code: 'SRV001',
      title: 'Server Unavailable',
      message: 'Banking servers are temporarily unavailable',
      description: 'Our servers are currently experiencing issues. Please try again later.',
      type: TransferErrorType.serverUnavailable,
      icon: '🔧',
      solution: 'Please wait a few minutes and try your transfer again.',
      isRetryable: true,
    ),

    // Error de tiempo de espera (timeout)
    'TIM001': TransferError(
      code: 'TIM001',
      title: 'Request Timeout',
      message: 'The request timed out',
      description: 'The transfer took too long to process and was cancelled.',
      type: TransferErrorType.timeout,
      icon: '⏱️',
      solution: 'Please try your transfer again. If the problem persists, contact support.',
      isRetryable: true,
    ),

    // Error en la validación de datos de entrada
    'VAL001': TransferError(
      code: 'VAL001',
      title: 'Data Validation Error',
      message: 'Invalid data provided',
      description: 'Some of the information you provided is not valid.',
      type: TransferErrorType.dataValidation,
      icon: '❌',
      solution: 'Please review your transfer details and correct any errors.',
      isRetryable: false,
    ),

    // Error en el formato del número de cuenta
    'ACC001': TransferError(
      code: 'ACC001',
      title: 'Invalid Account Format',
      message: 'Account number format is incorrect',
      description: 'The IBAN or account number you provided has an invalid format.',
      type: TransferErrorType.accountFormat,
      icon: '🏦',
      solution: 'Please verify the account number and try again.',
      isRetryable: false,
    ),

    // Error en el monto de la transferencia
    'AMT001': TransferError(
      code: 'AMT001',
      title: 'Invalid Amount',
      message: 'Transfer amount is not valid',
      description: 'The amount you specified cannot be processed.',
      type: TransferErrorType.invalidAmount,
      icon: '💰',
      solution: 'Please enter a valid amount between the allowed limits.',
      isRetryable: false,
    ),

    // Error por saldo insuficiente
    'BAL001': TransferError(
      code: 'BAL001',
      title: 'Insufficient Funds',
      message: 'Not enough funds in your account',
      description: 'Your account balance is insufficient to complete this transfer.',
      type: TransferErrorType.insufficientFunds,
      icon: '💳',
      solution: 'Please add funds to your account or reduce the transfer amount.',
      isRetryable: false,
    ),

    // Error por límites de transferencia superados
    'LIM001': TransferError(
      code: 'LIM001',
      title: 'Transfer Limit Exceeded',
      message: 'Transfer amount exceeds your daily limit',
      description: 'The amount exceeds your daily transfer limit.',
      type: TransferErrorType.limitExceeded,
      icon: '🚧',
      solution: 'Try a smaller amount or contact your bank to increase your limits.',
      isRetryable: false,
    ),

    // Error por cuenta bloqueada
    'ACC002': TransferError(
      code: 'ACC002',
      title: 'Account Blocked',
      message: 'Your account is temporarily blocked',
      description: 'Transfers from your account are currently restricted.',
      type: TransferErrorType.accountBlocked,
      icon: '🔒',
      solution: 'Contact your bank immediately to resolve this issue.',
      isRetryable: false,
    ),

    // Error por beneficiario no válido
    'BEN001': TransferError(
      code: 'BEN001',
      title: 'Invalid Beneficiary',
      message: 'Beneficiary information is not valid',
      description: 'The beneficiary account or details provided are not valid.',
      type: TransferErrorType.invalidBeneficiary,
      icon: '👤',
      solution: 'Please verify the beneficiary details and try again.',
      isRetryable: false,
    ),

    // Error de duplicidad de transacción
    'DUP001': TransferError(
      code: 'DUP001',
      title: 'Duplicate Transaction',
      message: 'This transaction was already processed',
      description: 'A transfer with identical details was recently completed.',
      type: TransferErrorType.duplicateTransaction,
      icon: '📋',
      solution: 'Check your transaction history. If this was intentional, wait a few minutes before trying again.',
      isRetryable: false,
    ),

    // Error interno de la aplicación
    'INT001': TransferError(
      code: 'INT001',
      title: 'Internal Application Error',
      message: 'An unexpected error occurred',
      description: 'The application encountered an internal error while processing your transfer.',
      type: TransferErrorType.internalError,
      icon: '⚠️',
      solution: 'Please try again. If the problem persists, contact technical support.',
      isRetryable: true,
    ),

    // Error de indisponibilidad temporal del servicio de transferencias
    'SRV002': TransferError(
      code: 'SRV002',
      title: 'Transfer Service Unavailable',
      message: 'Transfer service is temporarily unavailable',
      description: 'The transfer service is currently undergoing maintenance.',
      type: TransferErrorType.serviceUnavailable,
      icon: '🛠️',
      solution: 'Please try again later. Service should be restored shortly.',
      isRetryable: true,
    ),
  };

  // Método para obtener un error por código
  static TransferError? getErrorByCode(String code) {
    return errorCodes[code.toUpperCase()];
  }

  // Método para simular error basado en el nombre del beneficiario
  static TransferError? getErrorByBeneficiaryName(String beneficiaryName) {
    final cleanName = beneficiaryName.trim().toUpperCase();
    return errorCodes[cleanName];
  }

  // Lista de códigos de error disponibles para testing
  static List<String> get availableErrorCodes => errorCodes.keys.toList();
}

extension TransferErrorTypeExtension on TransferErrorType {
  String get displayName {
    switch (this) {
      case TransferErrorType.authentication:
        return 'Authentication';
      case TransferErrorType.authorization:
        return 'Authorization';
      case TransferErrorType.sessionExpired:
        return 'Session';
      case TransferErrorType.connectionError:
        return 'Connection';
      case TransferErrorType.serverUnavailable:
        return 'Server';
      case TransferErrorType.timeout:
        return 'Timeout';
      case TransferErrorType.dataValidation:
        return 'Validation';
      case TransferErrorType.accountFormat:
        return 'Account Format';
      case TransferErrorType.invalidAmount:
        return 'Amount';
      case TransferErrorType.insufficientFunds:
        return 'Insufficient Funds';
      case TransferErrorType.limitExceeded:
        return 'Limit Exceeded';
      case TransferErrorType.accountBlocked:
        return 'Account Blocked';
      case TransferErrorType.invalidBeneficiary:
        return 'Beneficiary';
      case TransferErrorType.duplicateTransaction:
        return 'Duplicate';
      case TransferErrorType.internalError:
        return 'Internal Error';
      case TransferErrorType.serviceUnavailable:
        return 'Service Unavailable';
    }
  }
}
