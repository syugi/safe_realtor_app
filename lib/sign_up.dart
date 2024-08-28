import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safe_realtor_app/config.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isCodeSent = false;
  bool isCodeVerified = false;
  bool isUsernameAvailable = false;
  String usernameCheckMessage = "";

  Future<void> _sendCode() async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/auth/sendVerificationCode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phoneNumber': phoneController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isCodeSent = true;
      });
    } else {
      // 오류 처리
      print('인증번호 발송 실패: ${response.body}');
    }
  }

  Future<void> _verifyCode() async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/auth/verifyCode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phoneNumber': phoneController.text,
        'verificationCode': codeController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isCodeVerified = true;
      });
    } else {
      // 오류 처리
      print('인증번호 확인 실패: ${response.body}');
    }
  }

  Future<void> _checkUsernameAvailability() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/auth/checkUsername')
          .replace(queryParameters: {'username': usernameController.text}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isUsernameAvailable = true;
        usernameCheckMessage = "사용 가능한 아이디입니다.";
      });
    } else {
      setState(() {
        isUsernameAvailable = false;
        usernameCheckMessage = "이미 사용 중인 아이디입니다.";
      });
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: isCodeVerified ? _buildSignUpForm() : _buildPhoneAuthForm(),
      ),
    );
  }

  Widget _buildPhoneAuthForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: '핸드폰 번호',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _sendCode,
          child: Text(isCodeSent ? '재발송' : '인증번호 발송'),
        ),
        if (isCodeSent) ...[
          const SizedBox(height: 20),
          TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: '인증번호 입력',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _verifyCode,
            child: const Text('인증번호 확인'),
          ),
        ],
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: '아이디',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _checkUsernameAvailability,
          child: const Text('아이디 중복 확인'),
        ),
        if (usernameCheckMessage.isNotEmpty)
          Text(
            usernameCheckMessage,
            style: TextStyle(
              color: isUsernameAvailable ? Colors.green : Colors.red,
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
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '비밀번호 확인',
            border: OutlineInputBorder(),
          ),
        ),
        if (passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty &&
            passwordController.text != confirmPasswordController.text)
          const Text(
            '비밀번호가 일치하지 않습니다.',
            style: TextStyle(color: Colors.red),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // 회원가입 로직 추가
            String username = usernameController.text;
            String password = passwordController.text;
            print('아이디: $username, 비밀번호: $password');
          },
          child: const Text('회원가입'),
        ),
      ],
    );
  }
}
