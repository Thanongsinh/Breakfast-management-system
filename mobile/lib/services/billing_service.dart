import '../models/bill.dart';
import 'api_client.dart';

class BillingService {
  final _apiClient = ApiClient();

  Future<List<Bill>> getBills({
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
        '/bills',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final billsList = data['bills'] as List;
      return billsList
          .map((item) => Bill.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Bill> getBillById(String billId) async {
    try {
      final response = await _apiClient.get('/bills/$billId');
      final data = response.data as Map<String, dynamic>;
      return Bill.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBillStats() async {
    try {
      final response = await _apiClient.get('/bills/stats');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Bill> createBill({
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
    try {
      final response = await _apiClient.post(
        '/bills',
        data: {
          'roomId': roomId,
          'amount': amount,
          'dueDate': dueDate.toIso8601String(),
          'billingPeriod': billingPeriod.toIso8601String(),
          'rentAmount': rentAmount,
          'electricityAmount': electricityAmount,
          'waterAmount': waterAmount,
          'otherAmount': otherAmount,
          'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return Bill.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Bill> updateBill({
    required String billId,
    double? amount,
    DateTime? dueDate,
    String? status,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/bills/$billId',
        data: {
          'amount': amount,
          'dueDate': dueDate?.toIso8601String(),
          'status': status,
          'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return Bill.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
