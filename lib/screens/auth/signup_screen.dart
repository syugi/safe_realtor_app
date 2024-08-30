import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/password_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();

  bool isCodeSent = false;
  bool isCodeVerified = false;
  bool isUsernameAvailable = false;
  bool isPasswordMatched = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String usernameCheckMessage = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(usernameFocusNode);
    });

    passwordController.addListener(_validatePasswords);
    confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      isPasswordMatched = passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          passwordController.text == confirmPasswordController.text;
    });
  }

  Future<void> _sendCode() async {
    final success = await _authService.sendCode(phoneController.text);
    if (success) {
      setState(() {
        isCodeSent = true;
      });
    } else {
      print('인증번호 발송 실패');
    }
  }

  Future<void> _verifyCode() async {
    final success = await _authService.verifyCode(
        phoneController.text, codeController.text);
    if (success) {
      setState(() {
        isCodeVerified = true;
      });
    } else {
      print('인증번호 확인 실패');
    }
  }

  Future<void> _checkUsernameAvailability() async {
    final available =
        await _authService.checkUsernameAvailability(usernameController.text);
    setState(() {
      isUsernameAvailable = available;
      usernameCheckMessage = available ? "사용 가능한 아이디입니다." : "이미 사용 중인 아이디입니다.";
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameFocusNode.dispose();
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
        child: _buildSignUpForm(),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      TextField(
        controller: usernameController,
        focusNode: usernameFocusNode,
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
      if (isUsernameAvailable) ...[
        const SizedBox(height: 20),
        PasswordField(
          controller: passwordController,
          isPasswordVisible: _passwordVisible,
          onToggleVisibility: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          labelText: '비밀번호',
        ),
        const SizedBox(height: 20),
        PasswordField(
          controller: confirmPasswordController,
          isPasswordVisible: _confirmPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _confirmPasswordVisible = !_confirmPasswordVisible;
            });
          },
          labelText: '비밀번호 확인',
        ),
        if (passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty &&
            !isPasswordMatched)
          const Text(
            '비밀번호가 일치하지 않습니다.',
            style: TextStyle(color: Colors.red),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isUsernameAvailable && isPasswordMatched
              ? () {
                  print(
                      '회원가입 완료: 아이디=${usernameController.text}, 비밀번호=${passwordController.text}');
                }
              : null,
          child: const Text('회원가입'),
        ),
      ],
    ]);
  }
}
