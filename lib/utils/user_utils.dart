import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_realtor_app/constants/role_constants.dart';

Future<int> getUserDbId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userDbId') ?? 0; // userDbId 불러오기
}

Future<String> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId') ?? '';
}

Future<int> getUserRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('role') ?? UserRoles.user;
}

// 로그인 여부를 체크하는 공통 함수
Future<bool> isLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  // userId가 있으면 로그인 상태, 없으면 로그아웃 상태
  return userId != null && userId.isNotEmpty;
}
