import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _loginMessage = '';

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://192.168.0.19:8080/api/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': idController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _loginMessage = '로그인 성공!';
      });
    } else {
      setState(() {
        _loginMessage = '로그인 실패: ${response.body}';
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
                      color: Colors.blue,
                    ),
                  ),
                  Icon(
                    Icons.home,
                    size: 70,
                    color: Colors.blue,
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
              TextButton(onPressed: () {}, child: const Text('회원가입')),
            ],
          ),
        ),
      ),
    );
  }
}
