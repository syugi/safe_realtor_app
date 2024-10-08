import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

String extractMessageFromResponse(http.Response response) {
  try {
    // 응답 바디를 UTF-8로 디코딩
    final decodedResponseBody = utf8.decode(response.bodyBytes);

    // JSON 파싱
    final responseBody = jsonDecode(decodedResponseBody);

    // 메시지 추출
    final message = responseBody['message'] ?? '알 수 없는 오류가 발생했습니다.';

    // 로그 메시지 출력
    log('Response Code: ${response.statusCode}', name: 'HTTP');
    log('Response Body: $decodedResponseBody', name: 'HTTP');
    log('Extracted Message: $message', name: 'HTTP');

    return message;
  } catch (e) {
    // 예외 발생 시 로그 출력 및 기본 메시지 반환
    log('Error parsing response: $e', name: 'HTTP', level: 1000);
    return '알 수 없는 오류가 발생했습니다.';
  }
}

String extractErrorCodeFromResponse(http.Response response) {
  // 응답 바디를 UTF-8로 디코딩
  final decodedResponseBody = utf8.decode(response.bodyBytes);

  // JSON 파싱
  final responseBody = jsonDecode(decodedResponseBody);

  // 메시지 추출
  final code = responseBody['code'] ?? '';

  return code;
}

class HttpStatus {
  static const int ok = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;
}
