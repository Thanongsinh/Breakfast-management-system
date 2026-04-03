import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class AccountState {
  final List<Account> accounts;
  final Account? currentAccount;
  final bool isLoading;
  final String? error;

  AccountState({
    this.accounts = const [],
    this.currentAccount,
    this.isLoading = false,
    this.error,
  });

  AccountState copyWith({
    List<Account>? accounts,
    Account? currentAccount,
    bool? isLoading,
    String? error,
  }) {
    return AccountState(
      accounts: accounts ?? this.accounts,
      currentAccount: currentAccount ?? this.currentAccount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasMultipleAccounts => accounts.length > 1;
  String? get currentRole => currentAccount?.role;
}

class AccountNotifier extends StateNotifier<AccountState> {
  final StorageService _storageService;

  AccountNotifier(this._storageService) : super(AccountState());

  Future<void> loadAccounts() async {
    state = state.copyWith(isLoading: true);
    try {
      final accounts = await _storageService.getAccounts();
      final currentAccount = await _storageService.getCurrentAccount();
      state = state.copyWith(
        accounts: accounts,
        currentAccount: currentAccount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> switchAccount(Account account) async {
    state = state.copyWith(isLoading: true);
    try {
      await _storageService.saveCurrentAccount(account);
      state = state.copyWith(
        currentAccount: account,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> setAccounts(List<Account> accounts) async {
    state = state.copyWith(isLoading: true);
    try {
      await _storageService.saveAccounts(accounts);
      if (accounts.isNotEmpty && state.currentAccount == null) {
        await _storageService.saveCurrentAccount(accounts.first);
        state = state.copyWith(
          accounts: accounts,
          currentAccount: accounts.first,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          accounts: accounts,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> clearAccounts() async {
    await _storageService.clearCurrentAccount();
    state = AccountState();
  }
}

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AccountNotifier(storageService);
});
