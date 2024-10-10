import 'package:flutter/material.dart';
import 'package:safe_realtor_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_realtor_app/screens/home.dart';
import 'package:safe_realtor_app/constants/role_constants.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _isLoggedIn = false;
  Map<String, String>? _accountInfo;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      setState(() {
        _isLoggedIn = true;
        _accountInfo = {
          'userId': userId,
          'role': prefs.getString('role') ?? 'ROLE_USER',
        };
      });
    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('더보기'),
      ),
      body: ListView(
        children: _isLoggedIn
            ? _buildLoggedInMenu(context)
            : _buildLoggedOutMenu(context),
      ),
    );
  }

  // 로그인한 상태의 메뉴 항목들
  List<Widget> _buildLoggedInMenu(BuildContext context) {
    return [
      _buildAccountInfoTile(),
      _buildMenuTile(
        icon: Icons.logout,
        title: '로그아웃',
        onTap: () => _logout(context),
      ),
      _buildAppInfoTile(context),
    ];
  }

  // 로그인하지 않은 상태의 메뉴 항목들
  List<Widget> _buildLoggedOutMenu(BuildContext context) {
    return [
      _buildMenuTile(
        icon: Icons.login,
        title: '로그인',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen())),
      ),
      _buildAppInfoTile(context),
    ];
  }

  // 계정 정보 표시
  Widget _buildAccountInfoTile() {
    final roleDescription =
        UserRoles.getRoleDescription(_accountInfo?['role'] ?? '');
    return ListTile(
      leading: const Icon(Icons.account_circle),
      title: const Text('계정 정보'),
      subtitle: Text(
          'ID: ${_accountInfo?['userId']} ${roleDescription.isNotEmpty ? '($roleDescription)' : ''}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AccountScreen()),
        );
      },
    );
  }

  // 공통 메뉴 항목 생성 함수
  Widget _buildMenuTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  // 앱 정보 메뉴
  Widget _buildAppInfoTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('앱 정보'),
      subtitle: const Text('버전 1.0.0'),
      onTap: () {
        _showAppInfo(context);
      },
    );
  }

  // 앱 정보 다이얼로그 표시
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('앱 정보'),
          content: const Text('이 앱은 안전한 부동산 거래를 위한 앱입니다.\n버전 1.0.0'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 로그아웃 처리
  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기

                // 로그아웃 처리 (SharedPreferences 초기화)
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // 모든 저장된 정보 삭제

                // 로그인 화면으로 이동
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false, // 이전 모든 라우트 제거
                );

                // 로그아웃 성공 알림
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃 되었습니다.')),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

// 예시용 계정 정보 페이지
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 정보'),
      ),
      body: const Center(
        child: Text('사용자 ID'),
      ),
    );
  }
}
