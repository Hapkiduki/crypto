import 'package:api/src/dio_manager.dart';
import 'package:api/src/services/services_impl.dart';

void main() {
  setupDioInstances();

  final userService = UserService();
  final authService = AuthService();

  userService.getAllUsers().then((users) {
    print('Users: $users');
  });

  authService.login({'username': 'user', 'password': 'pass'}).then((response) {
    print('Login response: $response');
  });
}
