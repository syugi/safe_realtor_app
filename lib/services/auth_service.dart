import 'package:http/http.dart' as http;
import 'api_service.dart';

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

  Future<http.Response> checkUserIdAvailability(String userId) async {
    final response = await _apiService.getRequest(
      '/api/auth/checkUserId',
      {'userId': userId},
    );

    return response;
  }

  Future<http.Response> login(String userId, String password) async {
    final response = await _apiService.postRequest(
      '/api/auth/login',
      {
        'userId': userId,
        'password': password,
      },
    );

    return response;
  }

  Future<http.Response> register(
      String userId, String password, String phoneNumber) async {
    final response = await _apiService.postRequest('/api/auth/register', {
      'userId': userId,
      'password': password,
      'phoneNumber': phoneNumber,
    });

    return response;
  }
}
