class Bill {
  final String id;
  final String roomId;
  final String? roomNumber;
  final String tenantId;
  final String? tenantName;
  final double amount;
  final double? rentAmount;
  final double? electricityAmount;
  final double? waterAmount;
  final double? otherAmount;
  final DateTime dueDate;
  final DateTime billingPeriod;
  final String status; // 'pending', 'paid', 'overdue', 'cancelled'
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;

  Bill({
    required this.id,
    required this.roomId,
    this.roomNumber,
    required this.tenantId,
    this.tenantName,
    required this.amount,
    this.rentAmount,
    this.electricityAmount,
    this.waterAmount,
    this.otherAmount,
    required this.dueDate,
    required this.billingPeriod,
    required this.status,
    this.paidAt,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      roomNumber: json['roomNumber'] as String?,
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      rentAmount: json['rentAmount'] != null
          ? (json['rentAmount'] as num).toDouble()
          : null,
      electricityAmount: json['electricityAmount'] != null
          ? (json['electricityAmount'] as num).toDouble()
          : null,
      waterAmount: json['waterAmount'] != null
          ? (json['waterAmount'] as num).toDouble()
          : null,
      otherAmount: json['otherAmount'] != null
          ? (json['otherAmount'] as num).toDouble()
          : null,
      dueDate: DateTime.parse(json['dueDate'] as String),
      billingPeriod: DateTime.parse(json['billingPeriod'] as String),
      status: json['status'] as String,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
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
      'amount': amount,
      'rentAmount': rentAmount,
      'electricityAmount': electricityAmount,
      'waterAmount': waterAmount,
      'otherAmount': otherAmount,
      'dueDate': dueDate.toIso8601String(),
      'billingPeriod': billingPeriod.toIso8601String(),
      'status': status,
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';
  bool get isCancelled => status == 'cancelled';
}
