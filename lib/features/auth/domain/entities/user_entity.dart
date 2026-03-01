/// UserEntity — Domain-layer representation of a logged-in user.
///
/// Clean Architecture Rule:
///   Entities live in domain/entities — they are PURE business objects.
///   No fromJson/toJson, no Firebase imports, no UI code.
///   The repository converts UserModel (data) → UserEntity (domain).
class UserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Convenience getter — returns display name or email prefix.
  String get name => displayName ?? email.split('@').first;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserEntity && other.uid == uid);

  @override
  int get hashCode => uid.hashCode;
}
