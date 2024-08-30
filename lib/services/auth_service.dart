import 'api_service.dart';
import '../utils/http_status.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> sendCode(String phoneNumber) async {
    final response = await _apiService.postRequest(
      '/api/auth/sendVerificationCode',
      {'phoneNumber': phoneNumber},
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<bool> verifyCode(String phoneNumber, String code) async {
    final response = await _apiService.postRequest(
      '/api/auth/verifyCode',
      {
        'phoneNumber': phoneNumber,
        'verificationCode': code,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final response = await _apiService.getRequest(
      '/api/auth/checkUsername',
      {'username': username},
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<String> login(String username, String password) async {
    final response = await _apiService.postRequest(
      '/api/auth/login',
      {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return '로그인 성공!';
    } else {
      return '로그인 실패: ${response.body}';
    }
  }

  Future<String> signup(String username, String password, String phon)
}
