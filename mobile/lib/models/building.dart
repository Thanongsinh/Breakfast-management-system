class Building {
  final int id;
  final String name;
  final String address;
  final int ownerId;
  final int totalRooms;
  final int occupiedRooms;
  final DateTime createdAt;
  final DateTime updatedAt;

  Building({
    required this.id,
    required this.name,
    required this.address,
    required this.ownerId,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      ownerId: json['ownerId'] as int,
      totalRooms: json['totalRooms'] as int,
      occupiedRooms: json['occupiedRooms'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'ownerId': ownerId,
      'totalRooms': totalRooms,
      'occupiedRooms': occupiedRooms,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get availableRooms => totalRooms - occupiedRooms;
  double get occupancyRate => totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0;
}
