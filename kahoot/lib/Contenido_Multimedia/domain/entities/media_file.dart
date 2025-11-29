class MediaFile {
  /// Los bytes del archivo. Es el contenido binario.
  final List<int> bytes;

  /// El nombre original del archivo con extensión (ej: 'imagen.png').
  final String name;

  /// El tipo MIME (opcional, pero útil para validaciones).
  final String? mimeType;

  MediaFile({required this.bytes, required this.name, this.mimeType});
}
