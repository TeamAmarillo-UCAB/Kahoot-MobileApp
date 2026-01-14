class Group {
  final String id;
  final String name;
  final String description;
  final String role; // 'ADMIN' o 'MEMBER'
  final int memberCount;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.role,
    required this.memberCount,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? '',
      role: json['role'] ?? 'MEMBER',
      memberCount: json['memberCount'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
