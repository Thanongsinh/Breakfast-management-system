import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bill.dart';
import '../services/billing_service.dart';

final billingServiceProvider = Provider<BillingService>((ref) => BillingService());

class BillingState {
  final List<Bill> bills;
  final Bill? selectedBill;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;

  BillingState({
    this.bills = const [],
    this.selectedBill,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  BillingState copyWith({
    List<Bill>? bills,
    Bill? selectedBill,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return BillingState(
      bills: bills ?? this.bills,
      selectedBill: selectedBill ?? this.selectedBill,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Bill> get pendingBills => bills.where((b) => b.isPending).toList();
  List<Bill> get paidBills => bills.where((b) => b.isPaid).toList();
  List<Bill> get overdueBills => bills.where((b) => b.isOverdue).toList();
}

class BillingNotifier extends StateNotifier<BillingState> {
  final BillingService _billingService;

  BillingNotifier(this._billingService) : super(BillingState());

  Future<void> loadBills({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bills = await _billingService.getBills(status: status);
      state = state.copyWith(bills: bills, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBillById(String billId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bill = await _billingService.getBillById(billId);
      state = state.copyWith(selectedBill: bill, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await _billingService.getBillStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createBill({
    required String roomId,
    required double amount,
    required DateTime dueDate,
    required DateTime billingPeriod,
    double? rentAmount,
    double? electricityAmount,
    double? waterAmount,
    double? otherAmount,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _billingService.createBill(
        roomId: roomId,
        amount: amount,
        dueDate: dueDate,
        billingPeriod: billingPeriod,
        rentAmount: rentAmount,
        electricityAmount: electricityAmount,
        waterAmount: waterAmount,
        otherAmount: otherAmount,
        notes: notes,
      );
      await loadBills();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearSelectedBill() {
    state = state.copyWith(selectedBill: null);
  }
}

final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  final billingService = ref.watch(billingServiceProvider);
  return BillingNotifier(billingService);
});
