String buildDeleteKahootPath(String kahootId) => '/kahoots/$kahootId';

Map<String, dynamic> buildDeleteKahootRequestBody({
  String? reason,
}) => {
  if (reason != null) 'reason': reason,
};
