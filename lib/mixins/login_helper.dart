import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_realtor_app/screens/auth/login_screen.dart';

mixin LoginHelper<T extends StatefulWidget> on State<T> {
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }

  // 로그인 모달 창 표시 함수
  void showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 스크롤 가능 여부 설정
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6, // 화면의 60% 높이로 시작
          maxChildSize: 0.9, // 최대 높이는 화면의 90%
          minChildSize: 0.4, // 최소 높이는 화면의 40%
          builder: (BuildContext context, ScrollController scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // 키보드 대응
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const LoginScreen(), // 로그인 화면
                ),
              ),
            );
          },
        );
      },
    );
  }
}
