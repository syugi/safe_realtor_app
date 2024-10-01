import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_realtor_app/screens/home.dart';
import 'package:safe_realtor_app/constants/role_constants.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('더보기'),
      ),
      body: ListView(
        children: [
          // 계정 정보 메뉴
          FutureBuilder<Map<String, String>>(
            future: _getAccountInfo(), // 계정 정보를 가져오는 비동기 함수 호출
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('계정 정보'),
                  subtitle: Text('로딩 중...'),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('계정 정보'),
                  subtitle: Text('계정 정보를 불러올 수 없습니다.'),
                );
              } else {
                // 계정 정보가 있을 경우 표시
                final data = snapshot.data!;
                final roleDescription =
                    UserRoles.getRoleDescription(data['role']!);

                return ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('계정 정보'),
                  subtitle: Text(
                    'ID: ${data['userId']} ${roleDescription.isNotEmpty ? '($roleDescription)' : ''}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountScreen()),
                    );
                  },
                );
              }
            },
          ),

          // 설정 메뉴
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),

          // 로그아웃 메뉴
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              _logout(context);
            },
          ),

          // 앱 정보 메뉴 (버전 정보 바로 표시)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 정보'),
            subtitle: const Text('버전 1.0.0'), // 여기서 버전 정보를 바로 표시
            onTap: () {
              _showAppInfo(context);
            },
          ),
        ],
      ),
    );
  }

  // 사용자 ID와 역할(중개사 또는 관리자)을 가져오는 함수
  Future<Map<String, String>> _getAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '알 수 없음';
    String role = prefs.getString('role') ?? 'ROLE_USER'; // 기본값을 ROLE_USER로 설정
    return {'userId': userId, 'role': role};
  }

  // 앱 정보 다이얼로그 표시 함수
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

  // 로그아웃 처리 함수
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
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

// 예시용 설정 페이지
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: const Center(
        child: Text('설정 페이지 내용'),
      ),
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
