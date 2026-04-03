class MaintenanceRequest {
  final String id;
  final String roomId;
  final String? roomNumber;
  final String tenantId;
  final String? tenantName;
  final String title;
  final String description;
  final String category; // 'plumbing', 'electrical', 'furniture', 'other'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final List<String> images;
  final String? assignedTo;
  final DateTime? scheduledDate;
  final DateTime? completedAt;
  final String? completionNotes;
  final DateTime createdAt;

  MaintenanceRequest({
    required this.id,
    required this.roomId,
    this.roomNumber,
    required this.tenantId,
    this.tenantName,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.images = const [],
    this.assignedTo,
    this.scheduledDate,
    this.completedAt,
    this.completionNotes,
    required this.createdAt,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      roomNumber: json['roomNumber'] as String?,
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      assignedTo: json['assignedTo'] as String?,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      completionNotes: json['completionNotes'] as String?,
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
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'images': images,
      'assignedTo': assignedTo,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completionNotes': completionNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
