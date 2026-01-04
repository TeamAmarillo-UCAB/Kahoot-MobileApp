class GroupMember {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String name;

  GroupMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.name = 'Usuario', // Valor por defecto si la API no lo envía
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['userId'] ?? '',
      role: json['role'] ?? 'MEMBER',
      joinedAt: DateTime.tryParse(json['joinedAt'] ?? '') ?? DateTime.now(),
      // Mapeamos 'name' si viene, sino usamos el userId o un default
      name: json['name'] ?? json['userId'] ?? 'Usuario',
    );
  }
}
