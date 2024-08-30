import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AuthService {
  Future<bool> sendCode(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/auth/sendVerificationCode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'phoneNumber': phoneNumber}),
    );

    return response.statusCode == 200;
  }

  Future<bool> verifyCode(String phoneNumber, String code) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/auth/verifyCode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phoneNumber': phoneNumber,
        'verificationCode': code,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/auth/checkUsername')
          .replace(queryParameters: {'username': username}),
    );

    return response.statusCode == 200;
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return '로그인 성공!';
    } else {
      return '로그인 실패: ${response.body}';
    }
  }
}
