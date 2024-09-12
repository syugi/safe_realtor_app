import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';
import '../config.dart';

class ApiService {
  // 공통 HTTP POST 요청 처리 메서드
  Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode(body),
    );

    return response;
  }

  // 공통 HTTP GET 요청 처리 메서드
  Future<http.Response> getRequest(
      String endpoint, Map<String, String> queryParams) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint')
        .replace(queryParameters: queryParams);
    final response = await http.get(url, headers: _headers());

    return response;
  }

  // 공통 HTTP DELETE 요청 처리 메서드
  Future<http.Response> deleteRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint');
    final response = await http.delete(
      url,
      headers: _headers(),
      body: jsonEncode(body),
    );

    return response;
  }

  // [매물 사진] HTTP POST 요청 처리 메서드 (multipart/form-data 전송)
  Future<http.Response> postPropertyMultipartRequest(
      String endpoint, Map<String, dynamic> fields, List<File> files) async {
    final url = Uri.parse('${Config.apiBaseUrl}$endpoint');

    // 멀티파트 요청 생성
    var request = http.MultipartRequest('POST', url);

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

    // 응답을 http.Response 형태로 변환하여 반환
    return await http.Response.fromStream(response);
  }

  // 공통 요청 헤더 설정
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }
}
