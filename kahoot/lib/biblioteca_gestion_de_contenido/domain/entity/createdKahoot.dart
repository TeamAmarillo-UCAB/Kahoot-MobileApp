class CreatedKahoot{
  final String createdKahootId;
  final String kahootId;
  final DateTime createdAt;
  final DateTime lastModified;
  

  CreatedKahoot({
    required this.createdKahootId,
    required this.kahootId,
    required this.createdAt,
    required this.lastModified,
  });

  factory CreatedKahoot.fromJson(Map<String, dynamic> json) {
    return CreatedKahoot(
      createdKahootId: json['createdKahootId'] as String,
      kahootId: json['kahootId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  static List<CreatedKahoot> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CreatedKahoot.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
