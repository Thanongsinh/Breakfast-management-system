class Payment {
  final String id;
  final String billId;
  final String tenantId;
  final String? tenantName;
  final double amount;
  final String method; // 'cash', 'bank_transfer', 'e-wallet'
  final String status; // 'pending', 'confirmed', 'rejected'
  final DateTime paymentDate;
  final String? proofImage;
  final String? notes;
  final String? confirmedBy;
  final DateTime? confirmedAt;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.billId,
    required this.tenantId,
    this.tenantName,
    required this.amount,
    required this.method,
    required this.status,
    required this.paymentDate,
    this.proofImage,
    this.notes,
    this.confirmedBy,
    this.confirmedAt,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      billId: json['billId'] as String,
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      status: json['status'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      proofImage: json['proofImage'] as String?,
      notes: json['notes'] as String?,
      confirmedBy: json['confirmedBy'] as String?,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billId': billId,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'amount': amount,
      'method': method,
      'status': status,
      'paymentDate': paymentDate.toIso8601String(),
      'proofImage': proofImage,
      'notes': notes,
      'confirmedBy': confirmedBy,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isRejected => status == 'rejected';
}
