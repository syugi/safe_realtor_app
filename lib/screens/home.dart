import 'package:flutter/material.dart';
import './property/property_list_screen.dart';
import 'property/property_registration_screen.dart';
import 'package:safe_realtor_app/constants/role_constants.dart';

class HomeScreen extends StatelessWidget {
  final int userRole; // 사용자 역할을 전달받기 위한 필드 (0: 관리자, 1: 중개사, 2: 일반 사용자)

  const HomeScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
      ),
      body: Column(
        children: [
          // 상단에 텍스트 및 역할에 따라 버튼 표시
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  '안전한 중개사에게 안전한 집구하기!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // 중개사와 일반 사용자 구분
                if (userRole == UserRoles.realtor ||
                    userRole == UserRoles.admin)
                  ElevatedButton(
                    onPressed: () {
                      // 중개사일 경우 매물 등록 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PropertyRegistrationScreen(),
                        ),
                      );
                    },
                    child: const Text('매물 등록'),
                  )
                else if (userRole == UserRoles.user)
                  ElevatedButton(
                    onPressed: () {
                      // 일반 사용자일 경우 문의하기 다이얼로그
                      _showInquiryDialog(context);
                    },
                    child: const Text('바로 문의하기'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 매물 목록을 표시하는 부분
          const Expanded(
            child: PropertyListScreen(), // 매물 목록 화면 호출
          ),
        ],
      ),
    );
  }

  // 일반 사용자용 문의하기 다이얼로그 함수
  void _showInquiryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('문의하기'),
          content: const Text('중개사에게 문의하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 닫기
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('문의가 완료되었습니다.')),
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
