class Contract {
  final String id;
  final String roomId;
  final String? roomNumber;
  final String tenantId;
  final String? tenantName;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyRent;
  final double deposit;
  final String status; // 'active', 'expired', 'terminated'
  final String? terms;
  final String? pdfUrl;
  final DateTime createdAt;

  Contract({
    required this.id,
    required this.roomId,
    this.roomNumber,
    required this.tenantId,
    this.tenantName,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.deposit,
    required this.status,
    this.terms,
    this.pdfUrl,
    required this.createdAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      roomNumber: json['roomNumber'] as String?,
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      deposit: (json['deposit'] as num).toDouble(),
      status: json['status'] as String,
      terms: json['terms'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'monthlyRent': monthlyRent,
      'deposit': deposit,
      'status': status,
      'terms': terms,
      'pdfUrl': pdfUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isTerminated => status == 'terminated';

  int get daysUntilExpiry => endDate.difference(DateTime.now()).inDays;
}
