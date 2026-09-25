/// Request body for `POST checkr` — starts a Checkr background verification.
/// Mirrors the native `CheckrRequest`.
class CheckrRequest {
  final String typeId;
  final String firstName;
  final String lastName;
  final String email;

  CheckrRequest({
    required this.typeId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'typeId': typeId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
}
