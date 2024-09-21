import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'package:safe_realtor_app/utils/user_utils.dart';

class InquiryService {
  final ApiService _apiService = ApiService();

  // 문의 하기
  Future<http.Response> submitInquiry(String inquiryContent,
      String detailRequest, List<String> propertyNumbers) async {
    final userId = await getUserId();
    final response = await _apiService.postRequest(
      '/api/inquiry/submit',
      {
        'userId': userId,
        'inquiryContent': inquiryContent,
        'detailRequest': detailRequest,
        'propertyNumbers': propertyNumbers
      },
    );
    return response;
  }
}
