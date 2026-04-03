import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());

class PaymentState {
  final List<Payment> payments;
  final Payment? selectedPayment;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;

  PaymentState({
    this.payments = const [],
    this.selectedPayment,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  PaymentState copyWith({
    List<Payment>? payments,
    Payment? selectedPayment,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return PaymentState(
      payments: payments ?? this.payments,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Payment> get pendingPayments => payments.where((p) => p.isPending).toList();
  List<Payment> get confirmedPayments => payments.where((p) => p.isConfirmed).toList();
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentService _paymentService;

  PaymentNotifier(this._paymentService) : super(PaymentState());

  Future<void> loadPayments({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payments = await _paymentService.getPayments(status: status);
      state = state.copyWith(payments: payments, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadPaymentById(String paymentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payment = await _paymentService.getPaymentById(paymentId);
      state = state.copyWith(selectedPayment: payment, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await _paymentService.getPaymentStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createPayment({
    required String billId,
    required double amount,
    required String method,
    required DateTime paymentDate,
    String? proofImage,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _paymentService.createPayment(
        billId: billId,
        amount: amount,
        method: method,
        paymentDate: paymentDate,
        proofImage: proofImage,
        notes: notes,
      );
      await loadPayments();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> confirmPayment({
    required String paymentId,
    required String status,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _paymentService.confirmPayment(
        paymentId: paymentId,
        status: status,
        notes: notes,
      );
      await loadPayments();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<String> getReceiptUrl(String paymentId) async {
    try {
      return await _paymentService.getReceiptUrl(paymentId);
    } catch (e) {
      rethrow;
    }
  }

  void clearSelectedPayment() {
    state = state.copyWith(selectedPayment: null);
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return PaymentNotifier(paymentService);
});
