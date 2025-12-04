class MediaResource {
  final List<int> bytes;

  final String name;

  final String? mimeType;

  MediaResource({required this.bytes, required this.name, this.mimeType});
}
