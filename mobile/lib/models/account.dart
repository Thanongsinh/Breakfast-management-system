class Account {
  final String id;
  final String name;
  final String role; // 'owner' or 'tenant'
  final String? room;
  final String? building;
  final String? email;
  final String? phone;

  Account({
    required this.id,
    required this.name,
    required this.role,
    this.room,
    this.building,
    this.email,
    this.phone,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      room: json['room'] as String?,
      building: json['building'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'room': room,
      'building': building,
      'email': email,
      'phone': phone,
    };
  }

  bool get isOwner => role == 'owner';
  bool get isTenant => role == 'tenant';

  Account copyWith({
    String? id,
    String? name,
    String? role,
    String? room,
    String? building,
    String? email,
    String? phone,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      room: room ?? this.room,
      building: building ?? this.building,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
