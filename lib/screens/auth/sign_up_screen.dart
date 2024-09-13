import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safe_realtor_app/screens/auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/password_field.dart';
import 'package:safe_realtor_app/utils/http_status.dart';
import '../home.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode userIdFocusNode = FocusNode();

  bool _isCodeSent = false;
  bool _isTimerActive = false;
  bool _isCodeVerified = false;
  bool _isUserIdAvailable = false;
  bool _isPasswordMatched = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isSubmitting = false;
  int _timerCountdown = 60 * 3;
  Timer? _timer;
  String _userIdCheckMessage = '';
  String _registrationMessage = '';
  String _verificationMessage = '';

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePasswords);
    confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    codeController.dispose();
    userIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    userIdFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerCountdown > 0) {
          _timerCountdown--;
        } else {
          _timer?.cancel();
          _isTimerActive = false;
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _sendCode() async {
    final response = await _authService.sendCode(phoneNumberController.text);

    setState(() {
      if (response.statusCode == HttpStatus.ok) {
        _verificationMessage = "";
        setState(() {
          _isCodeSent = true;
          _isTimerActive = true;
          _timerCountdown = 60 * 3;
        });
        _startTimer();
      } else {
        _isTimerActive = false;
        _timer?.cancel();
        _verificationMessage = response.body;
      }
    });
  }

  Future<void> _verifyCode() async {
    final response = await _authService.verifyCode(
        phoneNumberController.text, codeController.text);

    setState(() {
      if (response.statusCode == HttpStatus.ok) {
        _isCodeVerified = true;
        FocusScope.of(context).requestFocus(userIdFocusNode);
      } else {
        _verificationMessage = '인증 실패: ${response.body}';
      }
    });
  }

  void _validatePasswords() {
    setState(() {
      _isPasswordMatched =
          passwordController.text == confirmPasswordController.text &&
              passwordController.text.isNotEmpty &&
              confirmPasswordController.text.isNotEmpty;
    });
  }

  Future<void> _checkUserIdAvailability() async {
    final response =
        await _authService.checkUserIdAvailability(userIdController.text);
    setState(() {
      _isUserIdAvailable = response.statusCode == HttpStatus.ok;
      _userIdCheckMessage = response.body;
    });
  }

  Future<void> _register() async {
    setState(() {
      _isSubmitting = true; //버튼 비활성화
    });

    final response = await _authService.register(
      userIdController.text,
      passwordController.text,
      phoneNumberController.text, // 인증된 핸드폰 번호 사용
    );

    if (response.statusCode == HttpStatus.created) {
      final loginResponse = await _authService.login(
        userIdController.text,
        passwordController.text,
      );

      if (loginResponse.statusCode == HttpStatus.ok) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false, // 이전 라우트 제거
        );
      } else {
        setState(() {
          _registrationMessage = '자동 로그인 실패: ${loginResponse.body}';
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false, // 이전 라우트 제거
          );
        });
      }
    } else {
      setState(() {
        _registrationMessage = '회원가입 실패: ${response.body}';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isCodeVerified ? _buildSignUpForm() : _buildPhoneAuthForm(),
      ),
    );
  }

  Widget _buildPhoneAuthForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: phoneNumberController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: '핸드폰 번호',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: _sendCode,
              child: Text(_isCodeSent ? '재발송' : '인증번호 발송'),
            ),
            if (_isTimerActive)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  _formatTime(_timerCountdown),
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (_isCodeSent) ...[
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
        const SizedBox(height: 20),
        Text(
          _verificationMessage,
          style: const TextStyle(color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: userIdController,
          focusNode: userIdFocusNode,
          decoration: const InputDecoration(
            labelText: '아이디',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _checkUserIdAvailability,
          child: const Text('아이디 중복 확인'),
        ),
        if (_userIdCheckMessage.isNotEmpty)
          Text(
            _userIdCheckMessage,
            style: TextStyle(
              color: _isUserIdAvailable ? Colors.green : Colors.red,
            ),
          ),
        if (_isUserIdAvailable) ...[
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
                _isSubmitting || !_isUserIdAvailable || !_isPasswordMatched
                    ? null
                    : _register,
            child: const Text('회원가입'),
          ),
          if (_registrationMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                _registrationMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ],
    );
  }
}
