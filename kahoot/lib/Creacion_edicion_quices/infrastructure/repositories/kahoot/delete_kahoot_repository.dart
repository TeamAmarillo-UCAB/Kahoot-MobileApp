abstract class DeleteKahootRepository {
  /// Delete a Kahoot locally or prepare deletion payload.
  Future<void> deleteKahoot(String id);
}
