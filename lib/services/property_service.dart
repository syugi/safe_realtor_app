import 'package:http/http.dart' as http;
import 'package:safe_realtor_app/models/Property.dart';
import 'api_service.dart';
import 'package:safe_realtor_app/utils/http_status.dart';
import 'dart:convert';

class PropertyService {
  final ApiService _apiService = ApiService();

  Future<http.Response> sendPropertyData(Map<String, dynamic> property) async {
    final response =
        await _apiService.postRequest('/api/properties/register', property);
    return response;
  }

  Future<List<Property>> fetchProperties() async {
    final response = await _apiService.getRequest('/api/properties', {});
    if (response.statusCode == HttpStatus.ok) {
      final decodedResponseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedResponseBody);
      return data.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }
}
