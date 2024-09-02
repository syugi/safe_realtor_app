import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class ApiService {
  // 공통 HTTP POST 요청 처리 메서드
  Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  // 공통 HTTP GET 요청 처리 메서드
  Future<http.Response> getRequest(
      String endpoint, Map<String, String> queryParams) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint')
        .replace(queryParameters: queryParams);
    final response = await http.get(url);

    return response;
  }
}
