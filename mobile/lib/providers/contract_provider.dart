import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contract.dart';
import '../services/api_client.dart';

final contractServiceProvider = Provider<ApiClient>((ref) => ApiClient());

class ContractState {
  final List<Contract> contracts;
  final Contract? selectedContract;
  final bool isLoading;
  final String? error;

  ContractState({
    this.contracts = const [],
    this.selectedContract,
    this.isLoading = false,
    this.error,
  });

  ContractState copyWith({
    List<Contract>? contracts,
    Contract? selectedContract,
    bool? isLoading,
    String? error,
  }) {
    return ContractState(
      contracts: contracts ?? this.contracts,
      selectedContract: selectedContract ?? this.selectedContract,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Contract> get activeContracts =>
      contracts.where((c) => c.isActive).toList();
  List<Contract> get expiredContracts =>
      contracts.where((c) => c.isExpired).toList();
}

class ContractNotifier extends StateNotifier<ContractState> {
  final ApiClient _apiClient;

  ContractNotifier(this._apiClient) : super(ContractState());

  Future<void> loadContracts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get('/contracts');
      final data = response.data as Map<String, dynamic>;
      final contractsList = data['contracts'] as List;
      final contracts = contractsList
          .map((item) => Contract.fromJson(item as Map<String, dynamic>))
          .toList();
      state = state.copyWith(contracts: contracts, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadContractById(String contractId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get('/contracts/$contractId');
      final data = response.data as Map<String, dynamic>;
      final contract = Contract.fromJson(data);
      state = state.copyWith(selectedContract: contract, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSelectedContract() {
    state = state.copyWith(selectedContract: null);
  }
}

final contractProvider = StateNotifierProvider<ContractNotifier, ContractState>((ref) {
  final apiClient = ref.watch(contractServiceProvider);
  return ContractNotifier(apiClient);
});
