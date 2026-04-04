class Room {
  final int id;
  final int buildingId;
  final String buildingName;
  final String roomNumber;
  final double monthlyRate;
  final String status;
  final int? tenantId;
  final String? tenantName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.buildingId,
    required this.buildingName,
    required this.roomNumber,
    required this.monthlyRate,
    required this.status,
    this.tenantId,
    this.tenantName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      buildingId: json['buildingId'] as int,
      buildingName: json['buildingName'] as String,
      roomNumber: json['roomNumber'] as String,
      monthlyRate: (json['monthlyRate'] as num).toDouble(),
      status: json['status'] as String,
      tenantId: json['tenantId'] as int?,
      tenantName: json['tenantName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingId': buildingId,
      'buildingName': buildingName,
      'roomNumber': roomNumber,
      'monthlyRate': monthlyRate,
      'status': status,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isUnderMaintenance => status == 'maintenance';
}
