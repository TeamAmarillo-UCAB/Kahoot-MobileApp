class GroupDetail {
  final String id;
  final String name;
  final String description;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  GroupDetail({
    required this.id,
    required this.name,
    required this.description,
    this.updatedAt,
    this.createdAt,
  });

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    return GroupDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
