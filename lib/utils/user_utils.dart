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
