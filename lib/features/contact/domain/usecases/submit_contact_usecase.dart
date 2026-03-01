import '../repositories/i_contact_repository.dart';

/// SubmitContactUseCase — submits contact form data.
class SubmitContactUseCase {
  final IContactRepository _repository;
  const SubmitContactUseCase(this._repository);

  Future<void> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) =>
      _repository.submit(
        firstName: firstName,
        lastName:  lastName,
        email:     email,
        phone:     phone,
      );
}
