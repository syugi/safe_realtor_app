import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'package:safe_realtor_app/utils/http_status.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<http.Response> sendCode(String phoneNumber) async {
    final response = await _apiService.postRequest(
      '/api/auth/sendVerificationCode',
      {'phoneNumber': phoneNumber},
    );
    return response;
  }

  Future<http.Response> verifyCode(String phoneNumber, String code) async {
    final response = await _apiService.postRequest(
      '/api/auth/verifyCode',
      {
        'phoneNumber': phoneNumber,
        'code': code,
      },
    );

    return response;
  }

  Future<http.Response> checkUsernameAvailability(String username) async {
    final response = await _apiService.getRequest(
      '/api/auth/checkUsername',
      {'username': username},
    );

    return response;
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
}
