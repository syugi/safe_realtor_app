import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'sign_up_screen.dart';
import '../../styles/app_styles.dart';
import '../home.dart';
import 'package:safe_realtor_app/utils/http_utils.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _loginMessage = '';

  Future<void> _login() async {
    final response = await _authService.login(
      idController.text,
      passwordController.text,
    );

    if (response.statusCode == HttpStatus.ok) {
      // JSON 응답에서 role 값을 추출
      final decodedResponseBody = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(decodedResponseBody);
      final userId = responseBody['userId']; // 로그인용 문자열 ID
      final userDbId = responseBody['id']; // DB의 숫자형 PK (userDbId로 명명)
      final role = responseBody['role'];
      final phoneNumber = responseBody['phoneNumber'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId); // 로그인용 userId 저장
      await prefs.setInt('userDbId', userDbId); // DB PK 저장
      await prefs.setInt('role', role); // role 저장
      await prefs.setString('phoneNumber', phoneNumber);

      // role 값을 HomeScreen으로 전달
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      final message = extractMessageFromResponse(response);
      setState(() {
        _loginMessage = message;
      });
    }
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '안부',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.home,
                    size: 70,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('로그인')),
              Text(
                _loginMessage,
                style: const TextStyle(color: Colors.red),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
