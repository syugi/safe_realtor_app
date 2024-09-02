import 'package:http/http.dart' as http;
import 'api_service.dart';

class PropertyService {
  final ApiService _apiService = ApiService();

  Future<http.Response> sendPropertyData(Map<String, dynamic> property) async {
    final response =
        await _apiService.postRequest('/api/properties/register', property);
    return response;
  }
}
