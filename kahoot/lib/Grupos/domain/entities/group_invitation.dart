class GroupInvitation {
  final String groupId;
  final String invitationLink;
  final DateTime expiresAt;

  GroupInvitation({
    required this.groupId,
    required this.invitationLink,
    required this.expiresAt,
  });

  factory GroupInvitation.fromJson(Map<String, dynamic> json) {
    return GroupInvitation(
      groupId: json['groupId'] ?? '',
      invitationLink: json['invitationLink'] ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
    );
  }
}
