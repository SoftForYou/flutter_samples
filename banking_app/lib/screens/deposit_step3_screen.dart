import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/models/piggybank.dart';
import 'package:banking_app/models/deposit.dart';
import 'package:banking_app/services/app_state.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

class DepositStep3Screen extends StatefulWidget {
  final DepositData depositData;
  final PiggyBank piggyBank;
  final Function(DepositData) onConfirm;
  final VoidCallback onBack;

  const DepositStep3Screen({
    super.key,
    required this.depositData,
    required this.piggyBank,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  State<DepositStep3Screen> createState() => _DepositStep3ScreenState();
}

class _DepositStep3ScreenState extends State<DepositStep3Screen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupObslyTracking();
  }

  void _setupObslyTracking() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'view_deposit_step3'),
        Tag(key: 'step_name', value: 'confirm_deposit'),
        Tag(key: 'deposit_amount', value: widget.depositData.amount?.toString() ?? '0'),
        Tag(key: 'piggybank_id', value: widget.piggyBank.id),
      ], 'APPBANK.Deposit.Step3View');
    } catch (e) {
      debugPrint('Error tracking deposit step 3: $e');
    }
  }

  Future<void> _confirmDeposit() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Track confirmation start
      await _trackConfirmationStart();

      // 🎯 INICIO DE MEDICIÓN DE PERFORMANCE
      final transactionName = 'piggybank_deposit_confirmation';
      
      await ObslySDK.instance.performance.startTransaction(
        transactionName, 
        'PiggyBank Deposit Confirmation Process'
      );

      // PASO 1: Petición de permisos (1-3 segundos)
      await _performStep1_Permissions(transactionName);
      
      // PASO 2: Petición de confirmación (2-4 segundos)
      await _performStep2_Confirmation(transactionName);
      
      // PASOS 3 y 4: Concurrentes
      // Paso 3: Envío de métricas (1-2 segundos)
      // Paso 4: Petición de validación (2-3 segundos)
      await _performConcurrentSteps34(transactionName);

      // Realizar el depósito real (esto ya existía)
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.depositToPiggyBank(
        fromAccountId: widget.depositData.fromAccountId!,
        piggyBankId: widget.depositData.piggyBankId!,
        amount: widget.depositData.amount!,
        concept: widget.depositData.concept!,
      );

      if (success) {
        // 🎯 FIN DE MEDICIÓN DE PERFORMANCE - ÉXITO
        await ObslySDK.instance.performance.endTransaction(transactionName, 'Deposit confirmed successfully');
        
        // Mark deposit data as complete
        final completedData = widget.depositData.copyWith(isComplete: true);
        
        // Track successful confirmation
        await _trackConfirmationSuccess();
        
        widget.onConfirm(completedData);
      } else {
        // 🎯 FIN DE MEDICIÓN DE PERFORMANCE - ERROR
        await ObslySDK.instance.performance.endTransaction(transactionName, 'Deposit failed');
        
        // Track failed confirmation
        await _trackConfirmationError(appState.errorMessage ?? 'Unknown error');
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appState.errorMessage ?? 'Failed to process deposit. Please try again.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      }
    } catch (e) {
      // Track error
      await _trackConfirmationError(e.toString());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred. Please try again.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _trackConfirmationStart() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'start_deposit_confirmation'),
        Tag(key: 'deposit_amount', value: widget.depositData.amount?.toString() ?? '0'),
        Tag(key: 'from_account_id', value: widget.depositData.fromAccountId ?? 'unknown'),
        Tag(key: 'piggybank_id', value: widget.piggyBank.id),
      ], 'APPBANK.Deposit.ConfirmStart');
    } catch (e) {
      debugPrint('Error tracking confirmation start: $e');
    }
  }

  Future<void> _trackConfirmationSuccess() async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'successful_deposit_confirmation'),
        Tag(key: 'deposit_amount', value: widget.depositData.amount?.toString() ?? '0'),
        Tag(key: 'step_result', value: 'success'),
      ], 'APPBANK.Deposit.Step3Complete');
    } catch (e) {
      debugPrint('Error tracking confirmation success: $e');
    }
  }

  Future<void> _trackConfirmationError(String error) async {
    try {
      await ObslySDK.instance.addTag([
        Tag(key: 'user_action', value: 'failed_deposit_confirmation'),
        Tag(key: 'error_message', value: error),
        Tag(key: 'step_result', value: 'error'),
      ], 'APPBANK.Deposit.ConfirmError');
    } catch (e) {
      debugPrint('Error tracking confirmation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final sourceAccount = appState.getAccountById(widget.depositData.fromAccountId!);
        
        if (sourceAccount == null) {
          return const Center(
            child: Text('Error: Source account not found'),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'Step 3: Confirm Deposit',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please review the details and confirm your deposit',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              
              // Deposit summary card - más compacto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.savings,
                      size: 32,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deposit Amount',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '€${widget.depositData.amount!.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Details section
              _buildDetailItem(
                'From Account',
                '${sourceAccount.type}\n${sourceAccount.accountNumber}',
                Icons.account_balance,
              ),
              
              const SizedBox(height: 12),
              
              _buildDetailItem(
                'To Piggy Bank',
                '${widget.piggyBank.name}\n${widget.piggyBank.description}',
                Icons.savings,
              ),
              
              const SizedBox(height: 12),
              
              _buildDetailItem(
                'Concept',
                widget.depositData.concept!,
                Icons.note,
              ),
              
              const SizedBox(height: 16),
              
              // Progress after deposit - más compacto
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'After deposit: €${(widget.piggyBank.balance + widget.depositData.amount!).toStringAsFixed(2)} (${(((widget.piggyBank.balance + widget.depositData.amount!) / widget.piggyBank.targetAmount) * 100).toInt()}%)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : widget.onBack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _confirmDeposit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Confirm Deposit',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.green[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                                      style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============== MÉTODOS DE SIMULACIÓN DE PERFORMANCE ==============

  /// PASO 1: Simulación de petición de permisos (1-3 segundos)
  Future<void> _performStep1_Permissions(String transactionName) async {
    const stepName = 'request_permissions';
    
    // Iniciar el paso
    await ObslySDK.instance.performance.startStep(
      stepName, 
      transactionName, 
      'Request user permissions for deposit'
    );
    
    // Simular tiempo de petición de permisos (1-3 segundos)
    final randomDelay = 1000 + (DateTime.now().millisecondsSinceEpoch % 2000); // 1-3 segundos
    
    debugPrint('🔐 Paso 1: Solicitando permisos... (${randomDelay}ms)');
    await Future.delayed(Duration(milliseconds: randomDelay));
    
    // Finalizar el paso
    await ObslySDK.instance.performance.finishStep(
      stepName, 
      transactionName, 
      'Permissions granted successfully'
    );
    
    debugPrint('✅ Paso 1: Permisos concedidos');
  }

  /// PASO 2: Simulación de petición de confirmación (2-4 segundos)
  Future<void> _performStep2_Confirmation(String transactionName) async {
    const stepName = 'process_confirmation';
    
    // Iniciar el paso
    await ObslySDK.instance.performance.startStep(
      stepName, 
      transactionName, 
      'Process deposit confirmation'
    );
    
    // Simular tiempo de petición de confirmación (2-4 segundos)
    final randomDelay = 2000 + (DateTime.now().millisecondsSinceEpoch % 2000); // 2-4 segundos
    
    debugPrint('✔️ Paso 2: Procesando confirmación... (${randomDelay}ms)');
    await Future.delayed(Duration(milliseconds: randomDelay));
    
    // Finalizar el paso
    await ObslySDK.instance.performance.finishStep(
      stepName, 
      transactionName, 
      'Confirmation processed successfully'
    );
    
    debugPrint('✅ Paso 2: Confirmación procesada');
  }

  /// PASOS 3 y 4: Simulación de pasos concurrentes
  /// Paso 3: Envío de métricas (1-2 segundos)
  /// Paso 4: Petición de validación (2-3 segundos)
  Future<void> _performConcurrentSteps34(String transactionName) async {
    debugPrint('🔄 Pasos 3 y 4: Ejecutando en paralelo...');
    
    // Ejecutar ambos pasos en paralelo
    await Future.wait([
      _performStep3_SendMetrics(transactionName),
      _performStep4_Validation(transactionName),
    ]);
    
    debugPrint('✅ Pasos 3 y 4: Completados en paralelo');
  }

  /// PASO 3: Simulación de envío de métricas (1-2 segundos) - Concurrente
  Future<void> _performStep3_SendMetrics(String transactionName) async {
    const stepName = 'send_metrics';
    
    // Iniciar el paso
    await ObslySDK.instance.performance.startStep(
      stepName, 
      transactionName, 
      'Send analytics metrics (concurrent with validation)'
    );
    
    // Simular tiempo de envío de métricas (1-2 segundos)
    final randomDelay = 1000 + (DateTime.now().millisecondsSinceEpoch % 1000); // 1-2 segundos
    
    debugPrint('📊 Paso 3: Enviando métricas... (${randomDelay}ms)');
    await Future.delayed(Duration(milliseconds: randomDelay));
    
    // Finalizar el paso
    await ObslySDK.instance.performance.finishStep(
      stepName, 
      transactionName, 
      'Metrics sent successfully'
    );
    
    debugPrint('✅ Paso 3: Métricas enviadas');
  }

  /// PASO 4: Simulación de petición de validación (2-3 segundos) - Concurrente
  Future<void> _performStep4_Validation(String transactionName) async {
    const stepName = 'transaction_validation';
    
    // Iniciar el paso
    await ObslySDK.instance.performance.startStep(
      stepName, 
      transactionName, 
      'Validate transaction (concurrent with metrics)'
    );
    
    // Simular tiempo de validación (2-3 segundos)
    final randomDelay = 2000 + (DateTime.now().millisecondsSinceEpoch % 1000); // 2-3 segundos
    
    debugPrint('🔍 Paso 4: Validando transacción... (${randomDelay}ms)');
    await Future.delayed(Duration(milliseconds: randomDelay));
    
    // Finalizar el paso
    await ObslySDK.instance.performance.finishStep(
      stepName, 
      transactionName, 
      'Transaction validated successfully'
    );
    
    debugPrint('✅ Paso 4: Validación completada');
  }
}
