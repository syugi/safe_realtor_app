import 'dart:io';
import 'api_service.dart';
import 'dart:convert';
import 'package:safe_realtor_app/utils/user_utils.dart';

class PagingResult<T> {
  final List<T> items;
  final int totalPages;
  final int currentPage;
  final int totalItems;

  PagingResult({
    required this.items,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
  });
}

final ApiService _apiService = ApiService();

Future<PagingResult<T>> fetchPagedData<T>(
  String endpoint,
  Map<String, String> queryParams,
  T Function(Map<String, dynamic>) fromJson, // JSON 변환 함수
) async {
  final userId = await getUserId(); // userId를 공통으로 추가
  queryParams['userId'] = userId; // userId를 쿼리 매개변수에 포함
  final response =
      await _apiService.getRequest(endpoint, queryParams); // API 호출

  if (response.statusCode == HttpStatus.ok) {
    final decodedResponseBody = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> responseData = jsonDecode(decodedResponseBody);

    // items 필드에서 리스트 데이터 추출
    final List<dynamic> itemsJson = responseData['items'] ?? [];
    final List<T> items = itemsJson.map((json) => fromJson(json)).toList();

    // 페이지 관련 정보 추출
    final int totalPages = responseData['totalPages'] ?? 0;
    final int currentPage = responseData['currentPage'] ?? 0;
    final int totalItems = responseData['totalItems'] ?? 0;

    return PagingResult<T>(
      items: items,
      totalPages: totalPages,
      currentPage: currentPage,
      totalItems: totalItems,
    );
  } else {
    throw Exception('Failed to load data');
  }
}
