import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/account.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static const _keyAccountsList = 'accounts_list';
  static const _keyActiveUserId = 'active_user_id';

  // Token keys use userId suffix
  static String _tokenKey(String userId) => 'token_$userId';
  static String _refreshKey(String userId) => 'refresh_$userId';

  // Token management per user
  Future<void> saveTokens({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _tokenKey(userId), value: accessToken);
    await _storage.write(key: _refreshKey(userId), value: refreshToken);
  }

  Future<String?> getAccessToken(String userId) async {
    return await _storage.read(key: _tokenKey(userId));
  }

  Future<String?> getRefreshToken(String userId) async {
    return await _storage.read(key: _refreshKey(userId));
  }

  Future<void> clearTokens(String userId) async {
    await _storage.delete(key: _tokenKey(userId));
    await _storage.delete(key: _refreshKey(userId));
  }

  // Active user management
  Future<void> setActiveUserId(String userId) async {
    await _storage.write(key: _keyActiveUserId, value: userId);
  }

  Future<String?> getActiveUserId() async {
    return await _storage.read(key: _keyActiveUserId);
  }

  Future<void> clearActiveUserId() async {
    await _storage.delete(key: _keyActiveUserId);
  }

  // Active user token shortcuts
  Future<String?> getActiveAccessToken() async {
    final userId = await getActiveUserId();
    if (userId == null) return null;
    return getAccessToken(userId);
  }

  Future<String?> getActiveRefreshToken() async {
    final userId = await getActiveUserId();
    if (userId == null) return null;
    return getRefreshToken(userId);
  }

  // Account list management
  Future<void> saveAccounts(List<Account> accounts) async {
    final json = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _storage.write(key: _keyAccountsList, value: json);
  }

  Future<List<Account>> getAccounts() async {
    final json = await _storage.read(key: _keyAccountsList);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((item) => Account.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAccount(Account account) async {
    final accounts = await getAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await saveAccounts(accounts);
  }

  Future<void> removeAccount(String accountId) async {
    final accounts = await getAccounts();
    accounts.removeWhere((a) => a.id == accountId);
    await saveAccounts(accounts);
    await clearTokens(accountId);

    final activeId = await getActiveUserId();
    if (activeId == accountId) {
      await clearActiveUserId();
    }
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Current account shortcuts (for compatibility)
  Future<Account?> getCurrentAccount() async {
    final userId = await getActiveUserId();
    if (userId == null) return null;

    final accounts = await getAccounts();
    try {
      return accounts.firstWhere((a) => a.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCurrentAccount(Account account) async {
    await addAccount(account);
    await setActiveUserId(account.id);
  }

  Future<void> clearCurrentAccount() async {
    await clearActiveUserId();
  }
}
