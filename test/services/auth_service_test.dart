import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cooked/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AuthService correctly retrieves token from SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'test_token_123');

    final token = await AuthService.instance.getToken();
    expect(token, 'test_token_123');
    expect(AuthService.instance.isLoggedIn, true);
  });
}
