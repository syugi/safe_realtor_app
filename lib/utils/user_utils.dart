import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_realtor_app/constants/role_constants.dart';

Future<String> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId') ?? '';
}

Future<String> getUserRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('role') ?? UserRoles.user.roleName;
}

Future<String?> getAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

// 로그인 여부를 체크하는 공통 함수
Future<bool> isLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  String? accessToken = prefs.getString('accessToken');

  // userId와 accessToken이 모두 존재하면 로그인 상태로 간주
  return userId != null &&
      userId.isNotEmpty &&
      accessToken != null &&
      accessToken.isNotEmpty;
}
