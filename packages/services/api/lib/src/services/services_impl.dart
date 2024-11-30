import 'package:api/src/services/services.dart';

class UserService extends Server1Service {
  @override
  String get resourcePath => 'users';

  Future<List<dynamic>> getAllUsers() async {
    return fetchList();
  }
}

class AuthService extends Server2Service {
  @override
  String get resourcePath => 'auth';

  Future<dynamic> login(Map<String, dynamic> credentials) async {
    return create(body: credentials);
  }
}
