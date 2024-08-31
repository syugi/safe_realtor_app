import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/password_field.dart';
import 'package:safe_realtor_app/utils/http_status.dart';
import 'phone_auth_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();

  bool _isUsernameAvailable = false;
  bool _isPasswordMatched = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String _usernameCheckMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(usernameFocusNode);
    });
    passwordController.addListener(_validatePasswords);
    confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameFocusNode.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      _isPasswordMatched =
          passwordController.text == confirmPasswordController.text &&
              passwordController.text.isNotEmpty &&
              confirmPasswordController.text.isNotEmpty;
    });
  }

  Future<void> _checkUsernameAvailability() async {
    final response =
        await _authService.checkUsernameAvailability(usernameController.text);
    setState(() {
      _isUsernameAvailable = response.statusCode == HttpStatus.ok;
      _usernameCheckMessage = response.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isUsernameAvailable
            ? _buildSignUpForm()
            : PhoneAuthScreen(onCodeVerified: _onCodeVerified),
      ),
    );
  }

  void _onCodeVerified() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _buildSignUpFormScreen()),
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
      if (_usernameCheckMessage.isNotEmpty)
        Text(
          _usernameCheckMessage,
          style: TextStyle(
            color: _isUsernameAvailable ? Colors.green : Colors.red,
          ),
        ),
      if (_isUsernameAvailable) ...[
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
        if (!_isPasswordMatched)
          const Text(
            '비밀번호가 일치하지 않습니다.',
            style: TextStyle(color: Colors.red),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              _isUsernameAvailable && _isPasswordMatched ? _signUp : null,
          child: const Text('회원가입'),
        ),
      ],
    ]);
  }

  Widget _buildSignUpFormScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildSignUpForm(),
      ),
    );
  }

  void _signUp() {
    // 회원가입 로직
    print(
        '회원가입 완료: 아이디=${usernameController.text}, 비밀번호=${passwordController.text}');
  }
}
