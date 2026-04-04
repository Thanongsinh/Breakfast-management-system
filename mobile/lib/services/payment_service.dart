import '../models/payment.dart';
import 'api_client.dart';

class PaymentService {
  final _apiClient = ApiClient();

  Future<List<Payment>> getPayments({
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/payments',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final paymentsList = data['payments'] as List;
      return paymentsList
          .map((item) => Payment.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Payment> getPaymentById(String paymentId) async {
    try {
      final response = await _apiClient.get('/payments/$paymentId');
      final data = response.data as Map<String, dynamic>;
      return Payment.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Payment> createPayment({
    required String billId,
    required double amount,
    required String method,
    required DateTime paymentDate,
    String? proofImage,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/payments',
        data: {
          'billId': billId,
          'amount': amount,
          'method': method,
          'paymentDate': paymentDate.toIso8601String(),
          'proofImage': proofImage,
          'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return Payment.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Payment> confirmPayment({
    required String paymentId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/payments/$paymentId/confirm',
        data: {
          'status': status,
          'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return Payment.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getReceiptUrl(String paymentId) async {
    try {
      final response = await _apiClient.get('/payments/$paymentId/receipt');
      final data = response.data as Map<String, dynamic>;
      return data['url'] as String;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      final response = await _apiClient.get('/payments/stats');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Owner: Confirm cash payment
  Future<Payment> confirmCashPayment({
    required int billId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/owner/payments/confirm-cash',
        data: {'billId': billId},
      );
      final data = response.data as Map<String, dynamic>;
      return Payment.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to confirm cash payment: $e');
    }
  }
}
