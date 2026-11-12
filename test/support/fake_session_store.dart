import 'package:bnood/core/storage/session_store.dart';

class FakeSessionStore extends SessionStore {
  FakeSessionStore({this.token});

  String? token;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async => token = value;

  @override
  Future<void> clearToken() async => token = null;
}
