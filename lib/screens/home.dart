import 'package:flutter/material.dart';
import './property/property_list_screen.dart';
import 'property/property_registration_screen.dart';
import 'package:safe_realtor_app/constants/role_constants.dart';
import 'package:safe_realtor_app/screens/favorites/favorites_screen.dart';
import 'package:safe_realtor_app/screens/more/more_screen.dart';
import 'package:safe_realtor_app/utils/user_utils.dart';
import 'package:safe_realtor_app/mixins/login_helper.dart';
import 'package:safe_realtor_app/screens/inquiry/inquiry_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with LoginHelper {
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
    int userRole = await getUserRole();
    String userId = await getUserId();

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
  void _onItemTapped(int index) async {
    if (index == 1) {
      // 찜목록 클릭 시 로그인 여부 확인
      _handleLoginRequired(() {
        setState(() {
          _selectedIndex = index;
        });
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.isNotEmpty ? _pages[_selectedIndex] : const SizedBox(),
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

  // 로그인 여부를 확인하여 로그인하지 않았다면 로그인 창 모달을 띄우는 함수
  void _handleLoginRequired(VoidCallback onLoggedIn) async {
    bool loggedIn = await isLoggedIn();

    if (loggedIn) {
      onLoggedIn();
    } else {
      showLoginBottomSheet(context);
    }
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
                    _handleLoginRequired(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PropertyRegistrationScreen()),
                      );
                    });
                  },
                  child: const Text('매물 등록'),
                )
              else if (_userRole == UserRoles.user)
                ElevatedButton(
                  onPressed: () {
                    _handleLoginRequired(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                InquiryFormScreen(userId: _userId!)),
                      );
                    });
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
}
