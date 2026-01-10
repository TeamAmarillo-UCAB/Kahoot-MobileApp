class LiveSession {
  final String sessionPin;
  final String sessionId;
  final String qrToken;

  LiveSession({
    required this.sessionPin,
    required this.sessionId,
    required this.qrToken,
  });

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      sessionPin: json['sessionPin']?.toString() ?? '',
      sessionId: json['sessionId'] ?? '',
      qrToken: json['qrToken'] ?? '',
    );
  }
}
