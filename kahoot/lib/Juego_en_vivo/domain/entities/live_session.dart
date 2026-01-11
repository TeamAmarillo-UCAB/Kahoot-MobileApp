class LiveSession {
  final String sessionPin;
  final String sessionId;
  final String qrToken;
  final String? themeUrl;

  LiveSession({
    required this.sessionPin,
    required this.sessionId,
    required this.qrToken,
    this.themeUrl,
  });

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      sessionPin: json['sessionPin']?.toString() ?? '',
      sessionId: json['sessionId'] ?? '',
      qrToken: json['qrToken'] ?? '',
      themeUrl: json['theme'] != null ? json['theme']['url'] : null,
    );
  }
}
