abstract class IContactRepository {
  Future<void> submit({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  });
}
