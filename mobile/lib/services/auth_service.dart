import '../models/account.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final _apiClient = ApiClient();
  final _storageService = StorageService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Extract data from response (backend returns {success: true, data: {...}})
      final responseData = response.data as Map<String, dynamic>;
      print('DEBUG: Login response = $responseData');
      final data = responseData['data'] as Map<String, dynamic>;
      print('DEBUG: Login data = $data');

      // Parse user
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      print('DEBUG: User parsed = ${user.email}');

      // Parse accounts
      final accountsList = data['accounts'] as List;
      final accounts = accountsList
          .map((item) => Account.fromJson(item as Map<String, dynamic>))
          .toList();

      // Save accounts
      print('DEBUG: Accounts to save = $accounts');
      await _storageService.saveAccounts(accounts);
      print('DEBUG: Accounts saved');

      // Set first account as current if available
      if (accounts.isNotEmpty) {
        print('DEBUG: Saving current account = ${accounts.first.email}');
        await _storageService.saveCurrentAccount(accounts.first);
        print('DEBUG: Current account saved');

        // Save tokens with user ID
        print('DEBUG: Saving tokens for user ${accounts.first.id}');
        await _storageService.saveTokens(
          userId: accounts.first.id,
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );
        print('DEBUG: Tokens saved');
      }

      print('DEBUG: Login complete, returning data');
      return {
        'user': user,
        'accounts': accounts,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _storageService.clearAll();
    }
  }

  Future<String?> refreshToken() async {
    try {
      final userId = await _storageService.getActiveUserId();
      if (userId == null) return null;

      final refreshToken = await _storageService.getActiveRefreshToken();
      if (refreshToken == null) return null;

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      // Extract data from response wrapper
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String;

      // Refresh endpoint only returns new access token, keep old refresh token
      await _storageService.saveTokens(
        userId: userId,
        accessToken: newAccessToken,
        refreshToken: refreshToken,
      );

      return newAccessToken;
    } catch (e) {
      await _storageService.clearAll();
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      // Extract data from response wrapper
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storageService.getActiveAccessToken();
    return token != null;
  }
}
