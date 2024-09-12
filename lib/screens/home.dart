import 'package:flutter/material.dart';
import './property/property_list_screen.dart';
import 'property/property_registration_screen.dart';
import 'package:safe_realtor_app/constants/role_constants.dart';
import 'package:safe_realtor_app/screens/favorites/favorites_screen.dart';
import 'package:safe_realtor_app/screens/more/more_screen.dart';
import 'package:safe_realtor_app/utils/user_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int? _userRole;
  String? _userId;
  final List<Widget> _pages = []; // 화면 목록 초기화

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // SharedPreferences에서 userId와 role을 불러오는 함수
  Future<void> _loadUserData() async {
    //TEST
    int userRole = UserRoles.user;
    String userId = "test";
    // int userRole = await getUserRole();
    // String userId = await getUserId();

    setState(() {
      _userRole = userRole;
      _userId = userId;

      // 각 탭 화면 초기화 (홈, 찜목록, 더보기)
      _pages.addAll([
        _buildHomeScreen(),
        FavoritesScreen(userId: _userId!),
        MoreScreen(userId: _userId!),
      ]);
    });
  }

  // 하단 탭 클릭시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '찜목록'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: '더보기'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, //선택된 아이템의 색상
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        const SizedBox(height: 70),
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
              if (_userRole == UserRoles.realtor ||
                  _userRole == UserRoles.admin)
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
              else if (_userRole == UserRoles.user)
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
        Expanded(
          child: PropertyListScreen(userId: _userId!), // 매물 목록 화면 호출
        ),
      ],
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
