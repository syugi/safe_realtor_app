import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:safe_realtor_app/models/Property.dart';
import 'api_service.dart';
import 'package:safe_realtor_app/utils/user_utils.dart';
import 'package:safe_realtor_app/services/paging_service.dart';

class PropertyService {
  final ApiService _apiService = ApiService();

  // 매물등록
  Future<http.Response> sendPropertyData(
      Map<String, dynamic> property, List<File> imageFiles) async {
    final response = await _apiService.postPropertyMultipartRequest(
        '/api/properties/register', property, imageFiles);
    return response;
  }

  // 매물 목록 조회
  Future<PagingResult<Property>> fetchProperties(int page, int perPage) async {
    return await fetchPagedData<Property>(
      '/api/properties/list',
      {'page': page.toString(), 'perPage': perPage.toString()},
      (json) => Property.fromJson(json),
    );
  }

  // 찜 목록 조회
  Future<PagingResult<Property>> fetchFavoriteProperties(
      int page, int perPage) async {
    final userId = await getUserId();
    return await fetchPagedData<Property>(
      '/api/favorites/$userId',
      {'page': page.toString(), 'perPage': perPage.toString()},
      (json) => Property.fromJson(json), // JSON을 Property로 변환하는 함수
    );
  }

  // 찜 추가
  Future<http.Response> addFavorite(int propertyId) async {
    final userId = await getUserId();
    final response = await _apiService.postRequest(
      '/api/favorites/add',
      {'userId': userId, 'propertyId': propertyId},
    );
    return response;
  }

  // 찜 삭제
  Future<http.Response> removeFavorite(int propertyId) async {
    final userId = await getUserId();
    final response = await _apiService.deleteRequest(
      '/api/favorites/remove',
      {'userId': userId, 'propertyId': propertyId},
    );
    return response;
  }
}
