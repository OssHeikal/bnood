import 'package:bnood/features/auth/models/user.dart';

import '../../account/auth_office_payload.dart';

class AuthMePayload {
  const AuthMePayload({required this.user, this.office});

  final User user;
  final AuthOfficePayload? office;

  factory AuthMePayload.fromData(Map<String, dynamic>? data) {
    final userJson = (data?['user'] as Map<String, dynamic>?) ?? data!;
    final officeRaw = data?['office'];
    AuthOfficePayload? office;
    if (officeRaw is Map<String, dynamic>) {
      office = AuthOfficePayload.fromJson(officeRaw);
    }
    return AuthMePayload(user: User.fromJson(userJson), office: office);
  }
}