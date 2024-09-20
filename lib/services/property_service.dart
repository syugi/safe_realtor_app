import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:safe_realtor_app/models/Property.dart';
import 'api_service.dart';
import 'dart:convert';

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
  Future<List<Property>> fetchProperties(String userId,
      {int page = 1, int perPage = 10}) async {
    final response = await _apiService.getRequest('/api/properties', {
      'userId': userId,
      'page': page.toString(),
      'perPage': perPage.toString()
    });
    if (response.statusCode == HttpStatus.ok) {
      final decodedResponseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedResponseBody);
      return data.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }

  // 찜 목록 조회
  Future<List<Property>> getFavoriteProperties(String userId) async {
    final response = await _apiService.getRequest('/api/favorites/$userId', {});
    if (response.statusCode == HttpStatus.ok) {
      final decodedResponseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedResponseBody);
      return data.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  // 찜 추가
  Future<http.Response> addFavorite(String userId, int propertyId) async {
    final response = await _apiService.postRequest(
      '/api/favorites/add',
      {'userId': userId, 'propertyId': propertyId},
    );
    return response;
  }

  // 찜 삭제
  Future<http.Response> removeFavorite(String userId, int propertyId) async {
    final response = await _apiService.deleteRequest(
      '/api/favorites/remove',
      {'userId': userId, 'propertyId': propertyId},
    );
    return response;
  }
}
