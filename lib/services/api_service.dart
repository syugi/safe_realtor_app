import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import 'package:safe_realtor_app/utils/http_utils.dart';

class ApiService {
  // 공통 HTTP POST 요청 처리 메서드
  Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      await refreshAccessToken();
      return await http.post(url,
          headers: await _headers(), body: jsonEncode(body));
    }

    return response;
  }

  // 공통 HTTP GET 요청 처리 메서드
  Future<http.Response> getRequest(
      String endpoint, Map<String, String> queryParams) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint')
        .replace(queryParameters: queryParams);
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == HttpStatus.unauthorized) {
      await refreshAccessToken();
      return await http.get(url, headers: await _headers());
    }

    return response;
  }

  // 공통 HTTP DELETE 요청 처리 메서드
  Future<http.Response> deleteRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint');
    final response = await http.delete(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      await refreshAccessToken();
      return await http.delete(
        url,
        headers: await _headers(),
        body: jsonEncode(body),
      );
    }

    return response;
  }

  // [매물 사진] HTTP POST 요청 처리 메서드 (multipart/form-data 전송)
  Future<http.Response> postPropertyMultipartRequest(
      String endpoint, Map<String, dynamic> fields, List<File> files) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint');

    // 멀티파트 요청 생성
    var request = http.MultipartRequest('POST', url);

    // Access Token을 포함한 헤더 추가
    request.headers.addAll(await _headers());

    // 'property' 필드를 JSON으로 변환하여 추가
    request.fields['property'] = jsonEncode(fields); // property 필드를 JSON으로 변환

    // 파일 추가
    for (File file in files) {
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'images', // 서버에서 받는 파라미터 이름
        stream,
        length,
        filename: basename(file.path),
      );
      request.files.add(multipartFile);
    }

    // 요청 전송 및 응답 받기
    var response = await request.send();

    if (response.statusCode == HttpStatus.unauthorized) {
      await refreshAccessToken();
      // 새로운 Access Token으로 다시 요청 시도
      request.headers.addAll(await _headers());
      response = await request.send();
    }

    // 응답을 http.Response 형태로 변환하여 반환
    return await http.Response.fromStream(response);
  }

  // 공통 요청 헤더 설정
  Future<Map<String, String>> _headers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken =
        prefs.getString('accessToken'); // 저장된 Access Token 불러오기

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (accessToken != null)
        'Authorization': 'Bearer $accessToken', // JWT 토큰 추가
    };
  }

  //토큰 재발급
  Future<void> refreshAccessToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      String? refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Refresh Token을 사용해 새로운 Access Token 요청
      final response = await postRequest('/api/auth/refreshToken',
          {'userId': userId, 'refreshToken': refreshToken});

      // 새로운 Access Token 저장
      final decodedResponseBody = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(decodedResponseBody);
      String newAccessToken = responseBody['accessToken'];
      await prefs.setString('accessToken', newAccessToken);

      print('Access Token 갱신 성공');
    } catch (e) {
      // 토큰 갱신 실패 처리 (예: Refresh Token 만료)
      print('토큰 갱신 실패: $e');

      // 로그아웃 처리 (SharedPreferences 초기화)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }
}
