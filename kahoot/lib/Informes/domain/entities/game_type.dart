
enum GameType {
  singleplayer,
  multiplayerHost,
  multiplayerPlayer,
  unknown;

  static GameType fromString(String value) {
    switch (value) {
      case 'Singleplayer':
        return GameType.singleplayer;
      case 'Multiplayer_host':
        return GameType.multiplayerHost;
      case 'Multiplayer_player':
        return GameType.multiplayerPlayer;
      default:
        return GameType.unknown;
    }
  }

  // Útil para lógica de UI si es necesario
  bool get isHost => this == GameType.multiplayerHost;
}