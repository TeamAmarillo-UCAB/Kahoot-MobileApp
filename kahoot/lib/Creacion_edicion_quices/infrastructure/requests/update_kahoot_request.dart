import 'create_kahoot_request.dart';

Map<String, dynamic> buildUpdateKahootRequest({
  required String id,
  required String authorId,
  required String title,
  required String description,
  String? coverImageId,
  required String visibility,
  String? themeId,
  required String status,
  required List<Map<String, dynamic>> questions,
}) {
  final body = buildCreateKahootRequest(
    authorId: authorId,
    title: title,
    description: description,
    coverImageId: coverImageId,
    visibility: visibility,
    themeId: themeId,
    status: status,
    questions: questions,
  );

  body['id'] = id;
  return body;
}

// Reuse create helper
